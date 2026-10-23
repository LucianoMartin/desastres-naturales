import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'location_service.dart';

const double kCell = 0.25;

const String _kVapidKey = 'BAAvLLOVKrHmkQL3rLHDs5slbdzdNBLV-mq3aD2kzWGN9UGmZSNFbpfVtF0_I6nQaBhNbPHEwqWJJ35pdmltbZA';

const String _kWorkerSubscribe = 'https://urgent-api.sistemalaertasptr.workers.dev/subscribe';

String temaDeCelda(LatLng p) {
  final i = ((p.latitude + 90) / kCell).floor();
  final j = ((p.longitude + 180) / kCell).floor();
  return 'cell_${i}_$j';
}

// dart:io no existe en web, así que se usa defaultTargetPlatform con kIsWeb.
bool get _esAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
bool get _esIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

class NotificacionService {
  final LocationService _location;
  final FirebaseMessaging _fm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  NotificacionService({LocationService? locationService})
    : _location = locationService ?? LocationService();

  static const _prefsKey = 'subscribed_cell_topic';
  static const _prefsTokenKey = 'subscribed_fcm_token'; // solo web
  static const _canal = AndroidNotificationChannel(
    'urgent',
    'Alertas urgentes',
    description: 'Alertas de emergencia en tu zona',
    importance: Importance.max,
  );

  bool _ocupado = false;
  DateTime? _ultimaComprobacion;

  final _mensajes = StreamController<RemoteMessage>.broadcast();

  /// Mensajes recibidos con la app abierta. En web el navegador no muestra
  /// nada en ese caso, así que la UI debe escuchar este stream
  /// (SnackBar, diálogo, banner...). En móvil también está disponible.
  Stream<RemoteMessage> get mensajes => _mensajes.stream;

  /// Permiso de notificaciones, canal Android y notificaciones con la app abierta.
  Future<void> init() async {
    await _fm.requestPermission(alert: true, badge: true, sound: true);

    if (!kIsWeb) {
      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      await _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_canal);

      // iOS: banner aunque la app esté abierta
      await _fm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    FirebaseMessaging.onMessage.listen((m) {
      _mensajes.add(m);

      final n = m.notification;
      if (n == null || !_esAndroid) return;
      // Android no muestra notificaciones FCM con la app en primer plano
      _local.show(
        id: m.hashCode,
        title: n.title,
        body: n.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _canal.id,
            _canal.name,
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    });
  }

  /// Compara la celda actual con la guardada y cambia la suscripción si hace falta.
  /// [force] ignora el límite de una comprobación cada 5 minutos.
  Future<void> actualizarSuscripcion({bool force = false}) async {
    if (_ocupado) return;
    final ultima = _ultimaComprobacion;
    if (!force &&
        ultima != null &&
        DateTime.now().difference(ultima) < const Duration(minutes: 5)) {
      return;
    }

    _ocupado = true;
    try {
      final ubicacion = await _location.obtenerUbicacionActual().timeout(
        const Duration(seconds: 15),
      );
      if (ubicacion == null) return; // sin permiso o servicio apagado

      final tema = temaDeCelda(ubicacion);
      final prefs = await SharedPreferences.getInstance();
      final anterior = prefs.getString(_prefsKey);

      if (kIsWeb) {
        // El token del navegador puede cambiar aunque la celda sea la misma
        final token = await _fm.getToken(vapidKey: _kVapidKey);
        if (token == null) throw Exception('Sin token FCM (¿permiso denegado?)');

        if (anterior == tema && prefs.getString(_prefsTokenKey) == token) {
          _ultimaComprobacion = DateTime.now();
          return;
        }
        await _suscribirWeb(token, tema, anterior);
        await prefs.setString(_prefsKey, tema);
        await prefs.setString(_prefsTokenKey, token);
      } else {
        if (anterior == tema) {
          _ultimaComprobacion = DateTime.now();
          return;
        }
        await _esperarApns();
        await _fm.subscribeToTopic(tema);
        await prefs.setString(_prefsKey, tema); // solo si tuvo éxito
        if (anterior != null) await _fm.unsubscribeFromTopic(anterior);
      }

      _ultimaComprobacion = DateTime.now();
      dev.log('Suscrito a $tema (antes: $anterior)', name: 'alertas');
    } catch (e) {
      dev.log('actualizarSuscripcion falló: $e', name: 'alertas');
    } finally {
      _ocupado = false;
    }
  }

  /// Al cerrar sesión: este dispositivo deja de recibir alertas.
  Future<void> cancelarSuscripcion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final anterior = prefs.getString(_prefsKey);
      if (anterior == null) return;

      if (kIsWeb) {
        // Desde el navegador no se puede desuscribir de un tema:
        // invalidar el token elimina todas sus suscripciones.
        await _fm.deleteToken();
        await prefs.remove(_prefsTokenKey);
      } else {
        await _fm.unsubscribeFromTopic(anterior);
      }

      await prefs.remove(_prefsKey);
      _ultimaComprobacion = null;
    } catch (e) {
      dev.log('cancelarSuscripcion falló: $e', name: 'alertas');
    }
  }

  /// Web: la suscripción la hace el Worker (POST /subscribe).
  Future<void> _suscribirWeb(
    String fcmToken,
    String tema,
    String? anterior,
  ) async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) throw Exception('Sin sesión');

    final res = await http.post(
      Uri.parse(_kWorkerSubscribe),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'token': fcmToken, 'topic': tema, 'previous': anterior}),
    );
    if (res.statusCode != 200) {
      throw Exception('subscribe ${res.statusCode}: ${res.body}');
    }
  }

  // iOS: subscribeToTopic falla si el token APNs aún no está listo.
  Future<void> _esperarApns() async {
    if (!_esIOS) return;
    for (var i = 0; i < 10; i++) {
      if (await _fm.getAPNSToken() != null) return;
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}

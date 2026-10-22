import 'dart:developer' as dev;
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'location_service.dart';

/// Debe ser IGUAL a CELL en el Worker.
const double kCell = 0.25;

String temaDeCelda(LatLng p) {
  final i = ((p.latitude + 90) / kCell).floor();
  final j = ((p.longitude + 180) / kCell).floor();
  return 'cell_${i}_$j';
}

class NotificacionService {
  final LocationService _location;
  final FirebaseMessaging _fm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  NotificacionService({LocationService? locationService})
    : _location = locationService ?? LocationService();

  static const _prefsKey = 'subscribed_cell_topic';
  static const _canal = AndroidNotificationChannel(
    'urgent',
    'Alertas urgentes',
    description: 'Alertas de emergencia en tu zona',
    importance: Importance.max,
  );

  bool _ocupado = false;
  DateTime? _ultimaComprobacion;

  /// Permiso de notificaciones, canal Android y notificaciones con la app abierta.
  Future<void> init() async {
    await _fm.requestPermission(alert: true, badge: true, sound: true);

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

    // Android no muestra notificaciones FCM con la app en primer plano
    FirebaseMessaging.onMessage.listen((m) {
      final n = m.notification;
      if (n == null || !Platform.isAndroid) return;
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

      if (anterior == tema) {
        _ultimaComprobacion = DateTime.now();
        return;
      }

      await _esperarApns();
      await _fm.subscribeToTopic(tema);
      await prefs.setString(_prefsKey, tema); // solo si tuvo éxito
      if (anterior != null) await _fm.unsubscribeFromTopic(anterior);

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
      await _fm.unsubscribeFromTopic(anterior);
      await prefs.remove(_prefsKey);
      _ultimaComprobacion = null;
    } catch (e) {
      dev.log('cancelarSuscripcion falló: $e', name: 'alertas');
    }
  }

  // iOS: subscribeToTopic falla si el token APNs aún no está listo.
  Future<void> _esperarApns() async {
    if (!Platform.isIOS) return;
    for (var i = 0; i < 10; i++) {
      if (await _fm.getAPNSToken() != null) return;
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}

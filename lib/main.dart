import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'repositories/auth_repository.dart';
import 'screens/auth_gate.dart';
import 'services/notificacion_service.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const DesastresNaturalesApp());
}

class DesastresNaturalesApp extends StatefulWidget {
  const DesastresNaturalesApp({super.key});

  @override
  State<DesastresNaturalesApp> createState() => _DesastresNaturalesAppState();
}

class _DesastresNaturalesAppState extends State<DesastresNaturalesApp>
    with WidgetsBindingObserver {
  final _auth = AuthRepository();
  StreamSubscription<User?>? _sesionSub;
  StreamSubscription? _mensajesSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _iniciar();
  }

  Future<void> _iniciar() async {
    await notificaciones.init();

    // Aviso en la interfaz con la app/pestaña abierta
    _mensajesSub = notificaciones.mensajes.listen((m) {
      final n = m.notification;
      if (n == null) return;
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('${n.title ?? 'Alerta'}: ${n.body ?? ''}'),
          duration: const Duration(seconds: 10),
        ),
      );
    });

    // Se dispara al abrir la app (con la sesión guardada) y en cada login/logout
    _sesionSub = _auth.cambiosUsuario.listen((usuario) {
      if (usuario != null) {
        notificaciones.actualizarSuscripcion(force: true);
      } else {
        notificaciones.cancelarSuscripcion();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _auth.usuarioActual != null) {
      notificaciones.actualizarSuscripcion(); // máx. una vez cada 5 min
    }
  }

  @override
  void dispose() {
    _sesionSub?.cancel();
    _mensajesSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlertApp',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFED3424)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

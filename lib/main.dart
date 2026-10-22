import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'repositories/auth_repository.dart';
import 'screens/auth_gate.dart';
import 'services/notificacion_service.dart';

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
  final _notificaciones = NotificacionService();
  final _auth = AuthRepository();
  StreamSubscription<User?>? _sesionSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _iniciar();
  }

  Future<void> _iniciar() async {
    await _notificaciones.init();

    // Se dispara al abrir la app (con la sesión guardada) y en cada login/logout
    _sesionSub = _auth.cambiosUsuario.listen((usuario) {
      if (usuario != null) {
        _notificaciones.actualizarSuscripcion(force: true);
      } else {
        _notificaciones.cancelarSuscripcion();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _auth.usuarioActual != null) {
      _notificaciones.actualizarSuscripcion(); // máx. una vez cada 5 min
    }
  }

  @override
  void dispose() {
    _sesionSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desastres Naturales',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00796B)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../repositories/auth_repository.dart';
import '../repositories/usuario_repository.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();

    return StreamBuilder<User?>(
      stream: authRepository.cambiosUsuario,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _PantallaCarga();
        }

        final usuarioFirebase = snapshot.data;

        if (usuarioFirebase == null) {
          return const LoginScreen();
        }

        return _PerfilGate(
          key: ValueKey(usuarioFirebase.uid),
          usuarioFirebase: usuarioFirebase,
        );
      },
    );
  }
}

class _PerfilGate extends StatefulWidget {
  final User usuarioFirebase;

  const _PerfilGate({super.key, required this.usuarioFirebase});

  @override
  State<_PerfilGate> createState() => _PerfilGateState();
}

class _PerfilGateState extends State<_PerfilGate> {
  final UsuarioRepository _usuarioRepository = UsuarioRepository();

  late Future<Usuario> _perfilFuture;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  void _cargarPerfil() {
    final usuario = widget.usuarioFirebase;

    _perfilFuture = _usuarioRepository.asegurarPerfil(
      uid: usuario.uid,
      email: usuario.email ?? '',
    );
  }

  void _reintentar() {
    setState(_cargarPerfil);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Usuario>(
      future: _perfilFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _PantallaCarga();
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'No se pudo cargar tu perfil.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Revisá tu conexión y los permisos de Firestore.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _reintentar,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final perfil = snapshot.data;

        if (perfil == null) {
          return const _PantallaCarga();
        }

        return HomeScreen(perfil: perfil);
      },
    );
  }
}

class _PantallaCarga extends StatelessWidget {
  const _PantallaCarga();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

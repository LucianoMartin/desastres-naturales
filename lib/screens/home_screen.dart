import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desastres Naturales'),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await AuthService().cerrarSesion();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.public, size: 72, color: Color(0xFF00796B)),
              SizedBox(height: 20),
              Text(
                '¡Bienvenido!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Iniciaste sesión correctamente.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

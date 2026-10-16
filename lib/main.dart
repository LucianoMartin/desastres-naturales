import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const DesastresNaturalesApp());
}

class DesastresNaturalesApp extends StatelessWidget {
  const DesastresNaturalesApp({super.key});

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

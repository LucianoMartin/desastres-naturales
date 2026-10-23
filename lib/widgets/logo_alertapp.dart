import 'package:flutter/material.dart';

class LogoAlertApp extends StatelessWidget {
  final double size;
  final BoxFit fit;
  final Alignment alignment;

  const LogoAlertApp({
    super.key,
    this.size = 120,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/AlertApp-Icon-Transparent.png',
      width: size,
      height: size,
      fit: fit,
      alignment: alignment,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import '../models/alerta.dart';
import '../theme/app_colors.dart';

class BannerAlertas extends StatelessWidget {
  final List<Alerta> alertas;

  const BannerAlertas({super.key, required this.alertas});

  @override
  Widget build(BuildContext context) {
    String marqueeText = 'Sin alertas activas';

    final List<String> textos = alertas
        .map((alerta) {
          final tipo = alerta.tipo.trim();

          if (tipo.isEmpty) {
            return '';
          }

          return '⚠️ Alerta $tipo';
        })
        .where((texto) => texto.isNotEmpty)
        .toList();

    if (textos.isNotEmpty) {
      marqueeText = textos.join(' - ');
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 44,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warningOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Marquee(
                  text: marqueeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  blankSpace: 40,
                  velocity: 45,
                  pauseAfterRound: const Duration(seconds: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:desastres_naturales/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../models/alerta.dart';

class MarcadorAlerta {
  static List<CircleMarker> construir({
    required Alerta alerta,
    required double valorAnimacion,
  }) {
    final tipo = alerta.tipo.trim().toLowerCase();

    final double radioSeguro =
        (alerta.radio.isNaN || alerta.radio <= 0)
            ? 1000.0
            : alerta.radio;

    final double opacidad =
        (1.0 - valorAnimacion).clamp(0.0, 1.0);

    late final Color color;
    late final Color colorBorde;

    switch (tipo) {
      case 'misil':
        color = AppColors.textoRojo;
        colorBorde = AppColors.contenedorRojo;
        break;

      case 'terremoto':
        color = AppColors.textoNaranja;
        colorBorde = AppColors.contenedorNaranja;
        break;

      case 'inundación':
      case 'inundacion':
        color = AppColors.textoAzul;
        colorBorde = AppColors.contenedorAzul;
        break;

      case 'gas tóxico':
      case 'gas toxico':
        color = AppColors.textoAmarillo;
        colorBorde = AppColors.contenedorAmarillo;
        break;

      default:
        color = AppColors.textoMasClaro;
        colorBorde = AppColors.contenedorGris;
    }

    final List<CircleMarker> circulos = [
      // Círculo exterior estático
      CircleMarker(
        point: alerta.ubicacion,
        radius: radioSeguro,
        useRadiusInMeter: true,
        color: color.withValues(alpha: 0.125),
        borderColor: colorBorde.withValues(alpha: 0.45),
        borderStrokeWidth: 1.5,
      ),

      // Círculo interior animado
      CircleMarker(
        point: alerta.ubicacion,
        radius: radioSeguro * valorAnimacion,
        useRadiusInMeter: true,
        color: color.withValues(
          alpha: (tipo == 'inundación' || tipo == 'inundacion'
                  ? 0.3
                  : tipo == 'misil'
                      ? 0.5
                      : tipo == 'terremoto'
                          ? 0.5
                          : 0.4) *
              opacidad,
        ),
        borderColor: colorBorde.withValues(alpha: opacidad),
        borderStrokeWidth: 2.5,
      ),
    ];

    return circulos;
  }
}
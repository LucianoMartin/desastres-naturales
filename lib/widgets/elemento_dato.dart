
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ElementoDato extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String contenido;
  final bool mostrarDivisor;

  const ElementoDato({
    super.key,
    required this.icono,
    required this.titulo,
    required this.contenido,
    this.mostrarDivisor = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.fondoClaro,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icono,
                  color: AppColors.textoRojo,
                  size: 21,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: AppColors.textoClaro,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      contenido.isEmpty ? 'Sin información' : contenido,
                      style: const TextStyle(
                        color: AppColors.textoMasClaro,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (mostrarDivisor)
          const Divider(
            height: 1,
            color: AppColors.fondoClaro,
          ),
      ],
    );
  }
}
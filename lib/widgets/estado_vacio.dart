import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class EstadoVacio extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final IconData icono;

  const EstadoVacio({
    super.key,
    this.titulo = 'No hay alertas todavía',
    this.mensaje = 'Cuando se registren alertas, aparecerán aquí.',
    this.icono = Icons.notifications_none,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              color: AppColors.textoOscuro,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textoMasClaro,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textoClaro,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
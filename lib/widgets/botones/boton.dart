
import 'package:desastres_naturales/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Boton extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final Color? colorFondo;
  final Color? colorTexto;
  final double? ancho;
  final double alto;
  final double radioBorde;
  final double fuenteSize;
  final FontWeight fuenteWeight;
  final IconData? icono;
  final double iconoSize;
  final bool isLoading;

  const Boton({
    super.key,
    required this.texto,
    required this.onPressed,
    this.colorFondo,
    this.colorTexto,
    this.ancho,
    this.alto = 40,
    this.radioBorde = 15,
    this.fuenteSize = 16,
    this.fuenteWeight = FontWeight.w600,
    this.icono,
    this.iconoSize = 20,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color buttonColor =
        colorFondo ?? AppColors.contenedorGris;

    final Color foregroundColor =
        colorTexto ?? AppColors.textoMasClaro;

    return SizedBox(
      width: ancho ?? double.infinity,
      height: alto,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor:
              buttonColor.withValues(alpha: 0.6),
          disabledForegroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radioBorde),
          ),
          textStyle: TextStyle(
            fontSize: fuenteSize,
            fontWeight: fuenteWeight,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icono != null) ...[
                    Icon(icono, size: iconoSize),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      texto,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
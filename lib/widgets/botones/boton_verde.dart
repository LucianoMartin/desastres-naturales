import 'package:flutter/material.dart';
import 'package:desastres_naturales/theme/app_colors.dart';
import 'package:desastres_naturales/widgets/botones/boton.dart';

class BotonVerde extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final double? ancho;
  final double alto;
  final IconData? icono;
  final bool isLoading;

  const BotonVerde({
    super.key,
    required this.texto,
    required this.onPressed,
    this.ancho,
    this.alto = 40,
    this.icono,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Boton(
      texto: texto,
      onPressed: onPressed,
      ancho: ancho,
      alto: alto,
      icono: icono,
      isLoading: isLoading,
      colorFondo: AppColors.contenedorVerde,
      colorTexto: AppColors.textoVerde,
    );
  }
}
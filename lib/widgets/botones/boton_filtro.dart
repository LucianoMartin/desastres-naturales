import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class BotonFiltro extends StatelessWidget {
  final String tipo;
  final bool seleccionado;
  final ValueChanged<bool> onSelected;

  const BotonFiltro({
    super.key,
    required this.tipo,
    required this.seleccionado,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        tipo.isEmpty ? tipo : '${tipo[0].toUpperCase()}${tipo.substring(1)}',
      ),
      selected: seleccionado,
      onSelected: onSelected,
      backgroundColor: AppColors.fondoNormal,
      selectedColor: AppColors.contenedorRojo,
      side: const BorderSide(width: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      labelStyle: TextStyle(
        color: seleccionado
            ? AppColors.textoRojo
            : AppColors.textoClaro,
        fontWeight:
            seleccionado ? FontWeight.bold : FontWeight.normal,
      ),
      showCheckmark: false,
    );
  }
}
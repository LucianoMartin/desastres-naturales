import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ControlesMapa extends StatelessWidget {
  final VoidCallback onCentrarUbicacion;

  const ControlesMapa({super.key, required this.onCentrarUbicacion});

  Widget _miniAvatar(Color color, IconData icon) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: color,
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.fondoNormal.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _miniAvatar(Colors.teal, Icons.person),
                const SizedBox(width: 6),
                _miniAvatar(Colors.indigo, Icons.person_outline),
                const SizedBox(width: 6),
                _miniAvatar(Colors.deepOrange, Icons.person),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.fondoClaro,
                    child: const Icon(
                      Icons.add,
                      size: 18,
                      color: AppColors.textoClaro,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            
            onPressed: onCentrarUbicacion,
            backgroundColor: AppColors.fondoNormal.withValues(alpha: 0.5),
            hoverColor: AppColors.fondoNormal.withValues(alpha: 0.5),
            foregroundColor: AppColors.textoClaro,
            tooltip: 'Centrar ubicación',
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}

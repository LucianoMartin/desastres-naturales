import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/usuario.dart';
import '../theme/app_colors.dart';

class ControlesMapa extends StatelessWidget {
  final VoidCallback onCentrarUbicacion;
  final MapController mapController;
  final List<Usuario> usuarios;

  const ControlesMapa({
    super.key,
    required this.onCentrarUbicacion,
    required this.mapController,
    this.usuarios = const [],
  });

  Widget _construirAvatarUsuario(Usuario usuario) {
    final String urlLimpia = usuario.avatarUrl.trim();
    final bool tieneUrlValida =
        urlLimpia.isNotEmpty &&
        urlLimpia != 'null' &&
        (urlLimpia.startsWith('http://') || urlLimpia.startsWith('https://'));

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () {
          if (usuario.latitud != null && usuario.longitud != null) {
            mapController.move(
              LatLng(usuario.latitud!, usuario.longitud!),
              14.5,
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Tooltip(
          message: usuario.nombre.isNotEmpty ? usuario.nombre : 'Usuario',
          child: tieneUrlValida
              ? CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.fondoClaro,
                  backgroundImage: NetworkImage(urlLimpia),
                  onBackgroundImageError: (_, _) {},
                )
              : const CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.fondoClaro,
                  child: Icon(Icons.person, size: 18, color: Colors.white),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuariosConUbicacion = usuarios
        .where((u) => u.latitud != null && u.longitud != null)
        .toList();

    return Stack(
      children: [
        Positioned(
          left: 16,
          bottom: 16,
          right: 88,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.fondoNormal.withValues(alpha: 0.3),
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
                  if (usuariosConUbicacion.isNotEmpty)
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: usuariosConUbicacion
                              .map(_construirAvatarUsuario)
                              .toList(),
                        ),
                      ),
                    ),
                  if (usuariosConUbicacion.isNotEmpty) const SizedBox(width: 2),
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(16),
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.fondoClaro,
                      child: Icon(
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
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: onCentrarUbicacion,
            backgroundColor: AppColors.fondoNormal.withValues(alpha: 0.3),
            hoverColor: AppColors.fondoNormal.withValues(alpha: 0.4),
            foregroundColor: AppColors.textoClaro,
            tooltip: 'Centrar ubicación',
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}

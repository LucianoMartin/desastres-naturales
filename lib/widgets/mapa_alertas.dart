import 'package:desastres_naturales/widgets/marcador_alerta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/alerta.dart';
import '../models/usuario.dart';
import '../theme/app_colors.dart';

class MapaAlertas extends StatefulWidget {
  final MapController mapController;
  final List<Alerta> alertas;
  final LatLng? miUbicacion;
  final Usuario perfil;
  final List<Usuario> otrosUsuarios;

  const MapaAlertas({
    super.key,
    required this.mapController,
    required this.alertas,
    required this.miUbicacion,
    required this.perfil,
    this.otrosUsuarios = const [],
  });

  @override
  State<MapaAlertas> createState() => _MapaAlertasState();
}

class _MapaAlertasState extends State<MapaAlertas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  static const LatLng _initialCenter = LatLng(-34.6037, -58.3816);

  static const double _initialZoom = 5.0;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Widget _construirAvatarUsuario({
    required String? avatarUrl,
    required double radius,
    required Color borderColor,
    required double borderWidth,
    required double iconSize,
  }) {
    final String urlLimpia = (avatarUrl ?? '').trim();
    final bool tieneUrlValida =
        urlLimpia.isNotEmpty &&
        urlLimpia != 'null' &&
        (urlLimpia.startsWith('http://') || urlLimpia.startsWith('https://'));

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: tieneUrlValida
          ? CircleAvatar(
              radius: radius,
              backgroundColor: AppColors.fondoClaro,
              backgroundImage: NetworkImage(urlLimpia),
              onBackgroundImageError: (_, _) {},
            )
          : CircleAvatar(
              radius: radius,
              backgroundColor: AppColors.fondoClaro,
              child: Icon(Icons.person, size: iconSize, color: Colors.white),
            ),
    );
  }

  List<Marker> _crearMarcadoresAlertas() {
    return widget.alertas.map((alerta) {
      return Marker(
        point: alerta.ubicacion,
        width: 120,
        height: 36,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              alerta.tipo,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Marker> _crearMarcadoresUsuarios() {
    final List<Marker> marcadores = [];

    for (final usuario in widget.otrosUsuarios) {
      if (usuario.uid == widget.perfil.uid) continue;
      if (usuario.latitud == null || usuario.longitud == null) continue;

      marcadores.add(
        Marker(
          point: LatLng(usuario.latitud!, usuario.longitud!),
          width: 36,
          height: 36,
          child: Center(
            child: _construirAvatarUsuario(
              avatarUrl: usuario.avatarUrl,
              radius: 14,
              borderColor: Colors.white,
              borderWidth: 2,
              iconSize: 16,
            ),
          ),
        ),
      );
    }

    final LatLng? ubicacionPropia =
        widget.miUbicacion ??
        (widget.perfil.tieneUbicacionValida
            ? LatLng(widget.perfil.latitud!, widget.perfil.longitud!)
            : null);

    if (ubicacionPropia != null) {
      marcadores.add(
        Marker(
          point: ubicacionPropia,
          width: 46,
          height: 46,
          child: Center(
            child: _construirAvatarUsuario(
              avatarUrl: widget.perfil.avatarUrl,
              radius: 19,
              borderColor: AppColors.colorApp,
              borderWidth: 3,
              iconSize: 22,
            ),
          ),
        ),
      );
    }

    return marcadores;
  }

  List<CircleMarker> _crearCirculos(double animValue) {
    return widget.alertas
        .expand(
          (alerta) => MarcadorAlerta.construir(
            alerta: alerta,
            valorAnimacion: animValue,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.mapController,
      options: const MapOptions(
        initialCenter: _initialCenter,
        initialZoom: _initialZoom,
        minZoom: 4.5,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.unaj.desastres_naturales',
        ),

        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return CircleLayer(circles: _crearCirculos(_waveController.value));
          },
        ),

        MarkerLayer(markers: _crearMarcadoresAlertas()),

        MarkerLayer(markers: _crearMarcadoresUsuarios()),
      ],
    );
  }
}

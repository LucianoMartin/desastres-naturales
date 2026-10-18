import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/alerta.dart';

class MapaAlertas extends StatefulWidget {
  final MapController mapController;
  final List<Alerta> alertas;
  final LatLng? miUbicacion;

  const MapaAlertas({
    super.key,
    required this.mapController,
    required this.alertas,
    required this.miUbicacion,
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

  List<Marker> _crearMarcadores() {
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

  List<CircleMarker> _crearCirculos(double animValue) {
    final double opacity = (1.0 - animValue).clamp(0.0, 1.0);

    final List<CircleMarker> circles = [];

    for (final alerta in widget.alertas) {
      final String tipo = alerta.tipo.toLowerCase();

      if (tipo == 'misil') {
        circles.add(
          CircleMarker(
            point: alerta.ubicacion,
            radius: alerta.radio * animValue,
            useRadiusInMeter: true,
            color: Colors.red.withValues(alpha: 0.5 * opacity),
            borderColor: Colors.red.withValues(alpha: opacity),
            borderStrokeWidth: 2.5,
          ),
        );
      } else if (tipo == 'terremoto') {
        circles.add(
          CircleMarker(
            point: alerta.ubicacion,
            radius: alerta.radio * animValue,
            useRadiusInMeter: true,
            color: Colors.orange.withValues(alpha: 0.5 * opacity),
            borderColor: Colors.deepOrange.withValues(alpha: opacity),
            borderStrokeWidth: 2.5,
          ),
        );

        circles.add(
          CircleMarker(
            point: alerta.ubicacion,
            radius: 7,
            useRadiusInMeter: false,
            color: Colors.deepOrange,
            borderColor: Colors.white,
            borderStrokeWidth: 2,
          ),
        );
      }
    }

    return circles;
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

        MarkerLayer(markers: _crearMarcadores()),

        if (widget.miUbicacion != null)
          MarkerLayer(
            markers: [
              Marker(
                point: widget.miUbicacion!,
                width: 24,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

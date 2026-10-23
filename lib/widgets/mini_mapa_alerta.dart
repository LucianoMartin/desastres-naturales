import 'dart:math' as math;

import 'package:desastres_naturales/widgets/marcador_alerta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../models/alerta.dart';
import '../theme/app_colors.dart';

class MiniMapaAlerta extends StatefulWidget {
  final Alerta alerta;
  final VoidCallback onTap;

  const MiniMapaAlerta({super.key, required this.alerta, required this.onTap});

  @override
  State<MiniMapaAlerta> createState() => _MiniMapaAlertaState();
}

class _MiniMapaAlertaState extends State<MiniMapaAlerta>
    with SingleTickerProviderStateMixin {
  bool _mouseEncima = false;

  late final AnimationController _waveController;

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

  double _calcularZoom() {
    // Si el radio no es válido, usamos un zoom cercano
    if (widget.alerta.radio <= 0) return 13.5;

    // Calcula un zoom que permita ver aproximadamente todo el círculo
    final latitudRad = widget.alerta.latitud * math.pi / 180;
    final metrosPorPixel = 156543.03392 * math.cos(latitudRad);

    final zoom =
        math.log((metrosPorPixel * 120) / (2 * widget.alerta.radio)) / math.ln2;

    return zoom.clamp(3.0, 17.0).toDouble();
  }

  Color _colorAlerta() {
    switch (widget.alerta.tipo.toLowerCase()) {
      case 'misil':
        return AppColors.rojoSecundario;
      case 'terremoto':
        return AppColors.textoNaranja;
      case 'inundación':
        return AppColors.textoAzul;
      default:
        return AppColors.rojoPrimario;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorAlerta();
    final zoom = _calcularZoom();

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 160,
          width: double.infinity,
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: widget.alerta.ubicacion,
                  initialZoom: zoom,
                  minZoom: 3,
                  maxZoom: 18,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.unaj.desastres_naturales',
                  ),
                  AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return CircleLayer(
                        circles: MarcadorAlerta.construir(
                          alerta: widget.alerta,
                          valorAnimacion: _waveController.value,
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Detecta los clicks en toda la superficie del mapa.
              Positioned.fill(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _mouseEncima = true),
                  onExit: (_) => setState(() => _mouseEncima = false),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onTap,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),

              Positioned(
                right: 8,
                bottom: 8,
                child: IgnorePointer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _mouseEncima
                          ? AppColors.fondoNormal.withValues(alpha: 0.75)
                          : AppColors.fondoNormal.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.open_in_full,
                          size: 14,
                          color: AppColors.textoMasClaro,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Ver en el mapa',
                          style: TextStyle(
                            color: AppColors.textoMasClaro,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

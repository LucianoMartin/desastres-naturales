import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/alerta.dart';
import '../theme/app_colors.dart';

const distanciaMaxima = 10000;

class BannerAlertas extends StatefulWidget {
  final List<Alerta> alertas;
  final LatLng? miUbicacion;

  const BannerAlertas({
    super.key,
    required this.alertas,
    required this.miUbicacion,
  });

  @override
  State<BannerAlertas> createState() => _BannerAlertasState();
}

class _BannerAlertasState extends State<BannerAlertas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final GlobalKey _secuenciaKey = GlobalKey();

  double _anchoSecuencia = 0;
  static const double _velocidad = 65;
  static const double _separacion = 36;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
  }

  void _medirSecuencia() {
    final render = _secuenciaKey.currentContext?.findRenderObject();

    if (render is! RenderBox || !render.hasSize) return;

    final ancho = render.size.width;

    if (ancho <= 0 || (ancho - _anchoSecuencia).abs() < 1) {
      return;
    }

    setState(() {
      _anchoSecuencia = ancho;
    });

    _controller
      ..stop()
      ..duration = Duration(
        milliseconds: (ancho / _velocidad * 1000).round().clamp(1, 86400000),
      )
      ..repeat();
  }

  Widget _construirSecuencia(List<Alerta> alertas, {Key? key}) {
    return Row(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < alertas.length; i++)
          Padding(
            padding: EdgeInsets.only(
              right: i == alertas.length - 1 ? 0 : _separacion,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.textoNaranja,
                  size: 20,
                ),
                const SizedBox(width: 7),
                Text(
                  'Alerta de ${alertas[i].tipo.trim().toLowerCase()}',
                  maxLines: 1,
                  softWrap: false,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _construirCiclo(List<Alerta> alertas, {Key? key}) {
    return Row(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        _construirSecuencia(alertas),
        const SizedBox(width: _separacion),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final distance = Distance();

    final alertasCercanas = widget.alertas.where((alerta) {
      if (widget.miUbicacion != null &&
          distance(widget.miUbicacion!, alerta.ubicacion) >
              distanciaMaxima) {
        return false;
      }

      return alerta.tipo.trim().isNotEmpty;
    }).toList();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 44,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.fondoNormal.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Text(
                'Alertas cerca tuyo:',
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color: AppColors.textoMasClaro,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: alertasCercanas.isEmpty
                    ? const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Sin alertas activas',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) _medirSecuencia();
                          });

                          final anchoDisponible = constraints.maxWidth;

                          // Copias suficientes para cubrir el ancho visible
                          // Antes de medir, usamos copias de sobra para evitar espacios vacios
                          final cantidadCopias = _anchoSecuencia > 0
                              ? (anchoDisponible / _anchoSecuencia).ceil() + 2
                              : 10;

                          return ClipRect(
                            child: SizedBox(
                              width: anchoDisponible,
                              height: 44,
                              child: AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      -_controller.value * _anchoSecuencia,
                                      0,
                                    ),
                                    child: child,
                                  );
                                },
                                child: OverflowBox(
                                  alignment: Alignment.centerLeft,
                                  minWidth: 0,
                                  maxWidth: double.infinity,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      _construirCiclo(
                                        alertasCercanas,
                                        key: _secuenciaKey,
                                      ),
                                      for (int i = 0; i < cantidadCopias; i++)
                                        _construirCiclo(alertasCercanas),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
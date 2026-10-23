import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/alerta.dart';
import '../services/alerta_service.dart';
import '../services/location_service.dart';
import '../services/riesgo_service.dart';
import '../theme/app_colors.dart';

class ResumenRiesgoPerfil extends StatefulWidget {
  const ResumenRiesgoPerfil({super.key});

  @override
  State<ResumenRiesgoPerfil> createState() => _ResumenRiesgoPerfilState();
}

class _ResumenRiesgoPerfilState extends State<ResumenRiesgoPerfil>
    with WidgetsBindingObserver {
  final _location = LocationService();
  final _riesgo = RiesgoService();
  late final Stream<List<Alerta>> _alertas;
  Timer? _reloj;
  LatLng? _ubicacion;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _alertas = AlertaService().obtenerAlertas();
    _actualizarUbicacion();
    // Reevalúa vencimientos aunque Firestore no emita cambios.
    _reloj = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_cargando) {
      _actualizarUbicacion();
    }
  }

  Future<void> _actualizarUbicacion() async {
    setState(() {
      _cargando = true;
      _error = null;
      _ubicacion = null;
    });
    try {
      final ubicacion = await _location.obtenerUbicacionActual().timeout(
        const Duration(seconds: 20),
      );
      if (!mounted) return;
      setState(() {
        _ubicacion = ubicacion;
        if (ubicacion == null) {
          _error =
              'Activá la ubicación y permití el acceso para consultar tu zona.';
        }
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'No pudimos obtener tu ubicación. Probá nuevamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _reloj?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String _distancia(double? metros) {
    if (metros == null) return 'Sin eventos';
    if (metros == 0) return 'En tu zona';
    if (metros < 1000) return '${metros.ceil()} m';
    return '${(metros / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fondoNormal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar, color: AppColors.textoRojo),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Riesgos cerca tuyo',
                  style: TextStyle(
                    color: AppColors.textoMasClaro,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Actualizar ubicación',
                onPressed: _cargando ? null : _actualizarUbicacion,
                icon: const Icon(Icons.refresh, color: AppColors.textoClaro),
              ),
            ],
          ),
          if (_cargando)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.textoRojo),
              ),
            )
          else if (_error != null)
            Text(_error!, style: const TextStyle(color: AppColors.textoClaro))
          else
            StreamBuilder<List<Alerta>>(
              stream: _alertas,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    'No se pudieron consultar los eventos. Volvé a abrir el perfil para reintentar.',
                    style: TextStyle(color: AppColors.textoClaro),
                  );
                }
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.textoRojo,
                      ),
                    ),
                  );
                }
                final resumen = _riesgo.calcularResumen(
                  snapshot.data!,
                  _ubicacion!,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IndicadorRiesgo(
                      icono: Icons.warning_amber_rounded,
                      titulo: 'Zonas de riesgo cercanas',
                      valor: '${resumen.zonasCercanas}',
                    ),
                    _IndicadorRiesgo(
                      icono: Icons.my_location,
                      titulo: 'Zonas que incluyen tu ubicación',
                      valor: '${resumen.zonasEnUbicacion}',
                    ),
                    _IndicadorRiesgo(
                      icono: Icons.near_me_outlined,
                      titulo: 'Zona de riesgo más próxima',
                      valor: _distancia(resumen.distanciaMasCercana),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Eventos activos a 10 km o menos del área afectada. '
                      'Distancias aproximadas desde la última ubicación consultada.',
                      style: TextStyle(
                        color: AppColors.textoClaro,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _IndicadorRiesgo extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _IndicadorRiesgo({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icono, color: AppColors.textoRojo, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(color: AppColors.textoClaro),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textoMasClaro,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

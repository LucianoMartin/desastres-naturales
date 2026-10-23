import 'dart:math' as math;

import 'package:desastres_naturales/widgets/elemento_dato.dart';
import 'package:desastres_naturales/widgets/mini_mapa_alerta.dart';
import 'package:desastres_naturales/services/geocodificacion_service.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/alerta.dart';
import '../theme/app_colors.dart';

class AlertaExpandida extends StatelessWidget {
  final Alerta alerta;
  final bool expandidaInicialmente;
  final void Function(LatLng ubicacion, double zoom)? onAbrirMapa;

  const AlertaExpandida({
    super.key,
    required this.alerta,
    this.expandidaInicialmente = false,
    this.onAbrirMapa,
  });

  bool get _activa {
    final ahora = DateTime.now();

    return !alerta.fechaInicio.isAfter(ahora) &&
        (alerta.fechaFin == null || alerta.fechaFin!.isAfter(ahora));
  }

  bool get _programada {
    return alerta.fechaInicio.isAfter(DateTime.now());
  }

  Color get _colorEstado {
    if (_programada) return AppColors.contenedorAzul;
    if (_activa) return AppColors.contenedorRojo;
    return AppColors.contenedorGris;
  }

  String get _textoEstado {
    if (_programada) return 'Programada';
    if (_activa) return 'Activa';
    return 'Finalizada';
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio · $hora:$minuto';
  }

  double _calcularZoomMapa() {
    if (alerta.radio <= 0) return 13.5;

    final latitudRad = alerta.latitud * math.pi / 180;
    final metrosPorPixel = 156543.03392 * math.cos(latitudRad);

    final zoom =
        math.log((metrosPorPixel * 120) / (2 * alerta.radio)) / math.ln2;

    return zoom.clamp(3.0, 17.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.fondoNormal,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: _activa ? AppColors.contenedorRojo : AppColors.fondoClaro,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: expandidaInicialmente,
        backgroundColor: AppColors.fondoNormal,
        collapsedBackgroundColor: AppColors.fondoNormal,
        iconColor: AppColors.textoRojo,
        collapsedIconColor: AppColors.textoClaro,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _colorEstado.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _activa
                ? Icons.warning_amber_rounded
                : _programada
                ? Icons.schedule
                : Icons.check_circle_outline,
            color: _activa
                ? AppColors.textoRojo
                : _programada
                ? AppColors.textoAzul
                : AppColors.textoClaro,
            size: 27,
          ),
        ),
        title: Text(
          alerta.nombre?.trim().isNotEmpty == true
              ? alerta.nombre!
              : alerta.tipo.isEmpty ? alerta.tipo : '${alerta.tipo[0].toUpperCase()}${alerta.tipo.substring(1)}',
          style: const TextStyle(
            color: AppColors.textoMasClaro,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alerta.tipo.isEmpty ? alerta.tipo : '${alerta.tipo[0].toUpperCase()}${alerta.tipo.substring(1)}',
                style: const TextStyle(
                  color: AppColors.textoClaro,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 7),
              _EtiquetaEstado(texto: _textoEstado, color: _colorEstado),
              const SizedBox(height: 7),
              Text(
                'Inicio: ${_formatearFecha(alerta.fechaInicio)}',
                style: const TextStyle(
                  color: AppColors.textoClaro,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        children: [
          const Divider(color: AppColors.fondoClaro, height: 1),

          if (alerta.descripcion?.trim().isNotEmpty == true) ...[
            ElementoDato(
              icono: Icons.description_outlined,
              titulo: 'Descripción',
              contenido: alerta.descripcion!.trim(),
            ),
          ],

          FutureBuilder<String>(
            future: GeocodificacionService.obtenerCiudad(
              alerta.latitud,
              alerta.longitud,
            ),
            builder: (context, snapshot) {
              final ciudad = snapshot.data ?? 'Buscando ciudad...';

              return ElementoDato(
                icono: Icons.location_on,
                titulo: 'Ubicación',
                contenido:
                    '· Latitud: ${alerta.latitud} · Longitud: ${alerta.longitud}  · Ciudad: $ciudad',
                mostrarDivisor: false,
              );
            },
          ),

          MiniMapaAlerta(
            alerta: alerta,
            onTap: () {
              onAbrirMapa?.call(alerta.ubicacion, _calcularZoomMapa());
            },
          ),

          const SizedBox(height: 16),

          const Divider(color: AppColors.fondoClaro, height: 1),

          ElementoDato(
            icono: Icons.radar,
            titulo: 'Radio de afectación',
            contenido: alerta.radio >= 1000
                ? '${(alerta.radio / 1000).toStringAsFixed(2)} km'
                : '${alerta.radio.toStringAsFixed(0)} m',
          ),

          ElementoDato(
            icono: Icons.play_circle_outline,
            titulo: 'Fecha de inicio',
            contenido: _formatearFecha(alerta.fechaInicio),
          ),

          if (alerta.fechaFin != null) ...[
            ElementoDato(
              icono: Icons.stop_circle_outlined,
              titulo: 'Fecha de finalización',
              contenido: alerta.fechaFin != null
                  ? _formatearFecha(alerta.fechaFin!)
                  : 'Sin fecha de finalización definida',
            ),
          ],

          ElementoDato(
            icono: Icons.fingerprint,
            titulo: 'Identificador',
            contenido: alerta.id,
            mostrarDivisor: false,
          ),
        ],
      ),
    );
  }
}

class _EtiquetaEstado extends StatelessWidget {
  final String texto;
  final Color color;

  const _EtiquetaEstado({required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color == AppColors.contenedorAzul
              ? AppColors.textoAzul
              : color == AppColors.contenedorRojo
              ? AppColors.textoRojo
              : AppColors.textoClaro,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

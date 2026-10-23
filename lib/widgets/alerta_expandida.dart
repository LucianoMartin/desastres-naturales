import 'package:flutter/material.dart';

import '../models/alerta.dart';
import '../theme/app_colors.dart';

class AlertaExpandida extends StatelessWidget {
  final Alerta alerta;
  final bool expandidaInicialmente;

  const AlertaExpandida({
    super.key,
    required this.alerta,
    this.expandidaInicialmente = false,
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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.fondoNormal,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: _activa
              ? AppColors.contenedorRojo
              : AppColors.fondoClaro,
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
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
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
              : alerta.tipo,
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
                alerta.tipo,
                style: const TextStyle(
                  color: AppColors.textoClaro,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 7),
              _EtiquetaEstado(
                texto: _textoEstado,
                color: _colorEstado,
              ),
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
          const Divider(color: AppColors.fondoClaro, height: 24),

          if (alerta.descripcion?.trim().isNotEmpty == true) ...[
            _DetalleAlerta(
              icono: Icons.description_outlined,
              titulo: 'Descripción',
              contenido: alerta.descripcion!.trim(),
            ),
            const SizedBox(height: 18),
          ],

          _DetalleAlerta(
            icono: Icons.location_on_outlined,
            titulo: 'Ubicación',
            contenido:
                'Latitud: ${alerta.latitud.toStringAsFixed(6)}\n'
                'Longitud: ${alerta.longitud.toStringAsFixed(6)}',
          ),
          const SizedBox(height: 18),

          _DetalleAlerta(
            icono: Icons.radar,
            titulo: 'Radio de afectación',
            contenido: alerta.radio >= 1000
                ? '${(alerta.radio / 1000).toStringAsFixed(2)} km'
                : '${alerta.radio.toStringAsFixed(0)} m',
          ),
          const SizedBox(height: 18),

          _DetalleAlerta(
            icono: Icons.play_circle_outline,
            titulo: 'Fecha de inicio',
            contenido: _formatearFecha(alerta.fechaInicio),
          ),

          const SizedBox(height: 18),

          _DetalleAlerta(
            icono: Icons.stop_circle_outlined,
            titulo: 'Fecha de finalización',
            contenido: alerta.fechaFin != null
                ? _formatearFecha(alerta.fechaFin!)
                : 'Sin fecha de finalización definida',
          ),

          const SizedBox(height: 18),

          _DetalleAlerta(
            icono: Icons.fingerprint,
            titulo: 'Identificador',
            contenido: alerta.id,
          ),
        ],
      ),
    );
  }
}

class _EtiquetaEstado extends StatelessWidget {
  final String texto;
  final Color color;

  const _EtiquetaEstado({
    required this.texto,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
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

class _DetalleAlerta extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String contenido;

  const _DetalleAlerta({
    required this.icono,
    required this.titulo,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icono,
          color: AppColors.textoRojo,
          size: 21,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: AppColors.textoMasClaro,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              SelectableText(
                contenido,
                style: const TextStyle(
                  color: AppColors.textoClaro,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
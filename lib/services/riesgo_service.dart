import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../models/alerta.dart';
import '../models/resumen_riesgo.dart';

class RiesgoService {
  static const double cercaniaMetros = 10000;

  ResumenRiesgo calcularResumen(
    List<Alerta> alertas,
    LatLng ubicacion, {
    DateTime? ahora,
  }) {
    final instante = ahora ?? DateTime.now();
    const distancia = Distance();
    var cercanas = 0;
    var dentro = 0;
    double? masCercana;

    for (final alerta in alertas) {
      if (alerta.fechaInicio.isAfter(instante) ||
          (alerta.fechaFin != null && !alerta.fechaFin!.isAfter(instante))) {
        continue;
      }
      if (!alerta.latitud.isFinite ||
          !alerta.longitud.isFinite ||
          alerta.latitud.abs() > 90 ||
          alerta.longitud.abs() > 180 ||
          !alerta.radio.isFinite ||
          alerta.radio < 0) {
        continue;
      }
      final alCentro = distancia(ubicacion, alerta.ubicacion);
      final alBorde = math.max(0.0, alCentro - alerta.radio);
      if (alBorde <= cercaniaMetros) cercanas++;
      if (alCentro <= alerta.radio) dentro++;
      if (masCercana == null || alBorde < masCercana) masCercana = alBorde;
    }

    return ResumenRiesgo(
      zonasCercanas: cercanas,
      zonasEnUbicacion: dentro,
      distanciaMasCercana: masCercana,
    );
  }
}

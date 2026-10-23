import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:desastres_naturales/models/alerta.dart';
import 'package:desastres_naturales/services/riesgo_service.dart';

void main() {
  final ahora = DateTime(2026, 10, 23, 12);
  const ubicacion = LatLng(0, 0);

  Alerta evento({
    double longitud = 0,
    double radio = 500,
    DateTime? inicio,
    DateTime? fin,
  }) => Alerta(
    id: 'evento',
    tipo: 'terremoto',
    latitud: 0,
    longitud: longitud,
    radio: radio,
    fechaInicio: inicio ?? ahora.subtract(const Duration(hours: 1)),
    fechaFin: fin,
  );

  test('Excluye eventos futuros y finalizados, incluidos los límites', () {
    final resumen = RiesgoService().calcularResumen(
      [
        evento(inicio: ahora),
        evento(inicio: ahora.add(const Duration(seconds: 1))),
        evento(fin: ahora),
      ],
      ubicacion,
      ahora: ahora,
    );
    expect(resumen.zonasCercanas, 1);
    expect(resumen.zonasEnUbicacion, 1);
    expect(resumen.distanciaMasCercana, 0);
  });

  test('Mide cercanía al borde y contempla zonas de radio grande', () {
    final resumen = RiesgoService().calcularResumen(
      [evento(longitud: 0.18, radio: 15000), evento(longitud: 0.3)],
      ubicacion,
      ahora: ahora,
    );
    expect(resumen.zonasCercanas, 1);
    expect(resumen.zonasEnUbicacion, 0);
    expect(resumen.distanciaMasCercana, closeTo(5000, 100));
  });

  test('Sin eventos válidos no inventa una distancia', () {
    final resumen = RiesgoService().calcularResumen(
      [evento(longitud: 181), evento(radio: -1)],
      ubicacion,
      ahora: ahora,
    );
    expect(resumen.zonasCercanas, 0);
    expect(resumen.distanciaMasCercana, isNull);
  });
}

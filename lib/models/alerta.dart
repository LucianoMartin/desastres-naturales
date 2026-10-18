import 'package:latlong2/latlong.dart';

class Alerta {
  final String id;
  final String tipo;
  final double latitud;
  final double longitud;
  final double radio;

  const Alerta({
    required this.id,
    required this.tipo,
    required this.latitud,
    required this.longitud,
    required this.radio,
  });

  LatLng get ubicacion => LatLng(latitud, longitud);

  factory Alerta.fromFirestore(String id, Map<String, dynamic> data) {
    return Alerta(
      id: id,
      tipo: (data['tipo'] ?? '').toString(),
      latitud: (data['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (data['longitud'] as num?)?.toDouble() ?? 0.0,
      radio: (data['radio'] as num?)?.toDouble() ?? 500.0,
    );
  }
}

import 'package:latlong2/latlong.dart';

class Alerta {
  final String id;
  final String tipo;
  final double latitud;
  final double longitud;
  final double radio;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final String? nombre;
  final String? descripcion;

  const Alerta({
    required this.id,
    required this.tipo,
    required this.latitud,
    required this.longitud,
    required this.radio,
    required this.fechaInicio,
    this.fechaFin,
    this.nombre,
    this.descripcion,
  });

  LatLng get ubicacion => LatLng(latitud, longitud);

  factory Alerta.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime convertirFecha(dynamic valor, {DateTime? porDefecto}) {
      if (valor == null) {
        return porDefecto ?? DateTime.now();
      }

      if (valor is DateTime) {
        return valor;
      }

      // Firestore Timestamp
      if (valor is! String && valor is! num) {
        try {
          return valor.toDate() as DateTime;
        } catch (_) {
          // Si no es un DateTime válido, sigue igual
        }
      }

      if (valor is String) {
        return DateTime.tryParse(valor) ?? porDefecto ?? DateTime.now();
      }

      return porDefecto ?? DateTime.now();
    }

    DateTime? convertirFechaOpcional(dynamic valor) {
      if (valor == null) return null;

      if (valor is DateTime) return valor;

      if (valor is String) {
        return DateTime.tryParse(valor);
      }

      try {
        return valor.toDate() as DateTime;
      } catch (_) {
        return null;
      }
    }

    return Alerta(
      id: id,
      tipo: (data['tipo'] ?? '').toString(),
      latitud: (data['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (data['longitud'] as num?)?.toDouble() ?? 0.0,
      radio: (data['radio'] as num?)?.toDouble() ?? 500.0,
      fechaInicio: convertirFecha(data['fechaInicio']),
      fechaFin: convertirFechaOpcional(data['fechaFin']),
      nombre: data['nombre']?.toString(),
      descripcion: data['descripcion']?.toString(),
    );
  }
}
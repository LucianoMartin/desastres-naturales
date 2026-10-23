import 'dart:convert';

import 'package:http/http.dart' as http;

class GeocodificacionService {
  static Future<String> obtenerCiudad(
    double latitud,
    double longitud,
  ) async {
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        {
          'format': 'jsonv2',
          'lat': latitud.toString(),
          'lon': longitud.toString(),
          'zoom': '10',
          'addressdetails': '1',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'DesastresNaturales/1.0',
          'Accept-Language': 'es',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        return 'Ubicación desconocida';
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>?;

      if (address == null) {
        return 'Ubicación desconocida';
      }

      return address['city'] ??
          address['town'] ??
          address['village'] ??
          address['municipality'] ??
          address['city_district'] ??
          address['county'] ??
          address['state'] ??
          'Ubicación desconocida';
    } catch (e) {
      return 'Ubicación desconocida';
    }
  }
}
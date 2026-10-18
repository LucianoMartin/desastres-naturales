import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String _cloudName = 'tp-apps-moviles';
  static const String _uploadPreset = 'Torneos';

  static Future<String> subirImagen(XFile imagen) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = _uploadPreset;

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        await imagen.readAsBytes(),
        filename: imagen.name,
      ),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    final Map<String, dynamic> data = jsonDecode(body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = data['error'];

      throw Exception(
        error is Map
            ? error['message'] ?? 'Error al subir la imagen.'
            : 'Error al subir la imagen.',
      );
    }

    final url = data['secure_url'];

    if (url is! String || url.isEmpty) {
      throw Exception('Cloudinary no devolvió la URL de la imagen.');
    }

    return url;
  }
}

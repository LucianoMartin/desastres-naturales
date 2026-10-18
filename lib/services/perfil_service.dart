import 'package:image_picker/image_picker.dart';

import '../repositories/usuario_repository.dart';
import 'cloudinary_service.dart';

class PerfilService {
  final UsuarioRepository _usuarioRepository;
  final ImagePicker _picker;

  PerfilService({UsuarioRepository? usuarioRepository, ImagePicker? picker})
    : _usuarioRepository = usuarioRepository ?? UsuarioRepository(),
      _picker = picker ?? ImagePicker();

  Future<void> cambiarNombre(String uid, String nombre) async {
    final nombreLimpio = nombre.trim();

    if (nombreLimpio.isEmpty) {
      throw ArgumentError('El nombre no puede estar vacío.');
    }

    if (nombreLimpio.length > 50) {
      throw ArgumentError('El nombre no puede superar los 50 caracteres.');
    }

    await _usuarioRepository.actualizarNombre(uid, nombreLimpio);
  }

  Future<String?> cambiarFotoPerfil(String uid) async {
    final imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (imagen == null) return null;

    final url = await CloudinaryService.subirImagen(imagen);

    await _usuarioRepository.actualizarAvatar(uid, url);

    return url;
  }

  Future<void> quitarFotoPerfil(String uid) async {
    await _usuarioRepository.eliminarAvatar(uid);
  }
}

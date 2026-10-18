import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/usuario.dart';

class UsuarioRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _firestore.collection('usuarios');

  /// Crea el perfil solamente si todavía no existe.
  /// Si existe, conserva el nombre y la foto personalizados.
  Future<Usuario> asegurarPerfil({
    required String uid,
    required String email,
  }) async {
    final referencia = _usuarios.doc(uid);

    return _firestore.runTransaction<Usuario>((transaction) async {
      final documento = await transaction.get(referencia);

      if (documento.exists && documento.data() != null) {
        return Usuario.fromFirestore(documento.id, documento.data()!);
      }

      final nombreInicial = email.trim().split('@').first;

      final datos = <String, dynamic>{
        'nombre': nombreInicial.isEmpty ? 'usuario' : nombreInicial,
        'email': email.trim(),
        'rol': 'usuario',
        'activo': true,
        'avatarUrl': '',
        'fechaRegistro': FieldValue.serverTimestamp(),
      };

      transaction.set(referencia, datos);

      return Usuario.fromFirestore(uid, datos);
    });
  }

  Future<Usuario?> obtenerUsuario(String uid) async {
    final documento = await _usuarios.doc(uid).get();

    if (!documento.exists || documento.data() == null) {
      return null;
    }

    return Usuario.fromFirestore(documento.id, documento.data()!);
  }

  /// Escucha cambios del perfil en tiempo real.
  Stream<Usuario?> observarUsuario(String uid) {
    return _usuarios.doc(uid).snapshots().map((documento) {
      if (!documento.exists || documento.data() == null) {
        return null;
      }

      return Usuario.fromFirestore(documento.id, documento.data()!);
    });
  }

  Future<void> actualizarNombre(String uid, String nombre) async {
    await _usuarios.doc(uid).update({'nombre': nombre.trim()});
  }

  Future<void> actualizarAvatar(String uid, String avatarUrl) async {
    await _usuarios.doc(uid).update({'avatarUrl': avatarUrl});
  }

  Future<void> eliminarAvatar(String uid) async {
    await _usuarios.doc(uid).update({'avatarUrl': ''});
  }

  /// Conservamos este método por compatibilidad.
  Future<void> crearUsuario({
    required String uid,
    required String nombre,
    required String email,
  }) async {
    final referencia = _usuarios.doc(uid);
    final documento = await referencia.get();

    if (documento.exists) return;

    await referencia.set({
      'nombre': nombre,
      'email': email,
      'rol': 'usuario',
      'activo': true,
      'avatarUrl': '',
      'fechaRegistro': FieldValue.serverTimestamp(),
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/usuario.dart';

class UsuarioRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _firestore.collection('usuarios');

  /// Crea el perfil únicamente si todavía no existe.
  /// Devuelve el perfil existente o el que acaba de crear.
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

      final nombre = email.trim().split('@').first;

      final datos = <String, dynamic>{
        'nombre': nombre.isEmpty ? 'usuario' : nombre,
        'email': email.trim(),
        'rol': 'usuario',
        'activo': true,
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

  /// Conserva este método si ya lo utilizás en otras partes.
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
      'fechaRegistro': FieldValue.serverTimestamp(),
    });
  }
}

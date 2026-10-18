class Usuario {
  final String uid;
  final String nombre;
  final String email;
  final String rol;
  final bool activo;

  const Usuario({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.activo,
  });

  bool get esAdmin => rol == 'admin';

  factory Usuario.fromFirestore(String uid, Map<String, dynamic> data) {
    return Usuario(
      uid: uid,
      nombre: (data['nombre'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      rol: (data['rol'] ?? 'usuario').toString(),
      activo: data['activo'] ?? true,
    );
  }
}

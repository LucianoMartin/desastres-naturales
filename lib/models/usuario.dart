class Usuario {
  final String uid;
  final String nombre;
  final String email;
  final String rol;
  final bool activo;
  final String avatarUrl;

  const Usuario({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.activo,
    this.avatarUrl = '',
  });

  bool get esAdmin => rol == 'admin';

  factory Usuario.fromFirestore(String uid, Map<String, dynamic> data) {
    return Usuario(
      uid: uid,
      nombre: (data['nombre'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      rol: (data['rol'] ?? 'usuario').toString(),
      activo: data['activo'] as bool? ?? true,
      avatarUrl: (data['avatarUrl'] ?? '').toString(),
    );
  }

  Usuario copyWith({
    String? nombre,
    String? avatarUrl,
    String? email,
    String? rol,
    bool? activo,
  }) {
    return Usuario(
      uid: uid,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

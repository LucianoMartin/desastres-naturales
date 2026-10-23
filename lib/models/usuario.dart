class Usuario {
  final String uid;
  final String nombre;
  final String email;
  final String rol;
  final bool activo;
  final String avatarUrl;
  final double? latitud;
  final double? longitud;

  const Usuario({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.activo,
    this.avatarUrl = '',
    this.latitud,
    this.longitud,
  });

  bool get esAdmin => rol == 'admin';

  bool get tieneUbicacionValida =>
      latitud != null &&
      longitud != null &&
      latitud! >= -90 &&
      latitud! <= 90 &&
      longitud! >= -180 &&
      longitud! <= 180;

  static double? _parseCoordenada(dynamic valor) {
    if (valor == null) return null;
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor.toString().trim());
  }

  factory Usuario.fromFirestore(String uid, Map<String, dynamic> data) {
    final rawAvatar = data['avatarUrl'];
    final avatarLimpio = rawAvatar == null ? '' : rawAvatar.toString().trim();

    return Usuario(
      uid: uid,
      nombre: (data['nombre'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      rol: (data['rol'] ?? 'usuario').toString(),
      activo: data['activo'] as bool? ?? true,
      avatarUrl: avatarLimpio == 'null' ? '' : avatarLimpio,
      latitud: _parseCoordenada(data['latitud']),
      longitud: _parseCoordenada(data['longitud']),
    );
  }

  Usuario copyWith({
    String? nombre,
    String? avatarUrl,
    String? email,
    String? rol,
    bool? activo,
    double? latitud,
    double? longitud,
  }) {
    return Usuario(
      uid: uid,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
    );
  }
}

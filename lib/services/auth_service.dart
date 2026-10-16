import '../repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthService({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  Future<void> iniciarSesion({
    required String email,
    required String password,
  }) async {
    await _authRepository.iniciarSesion(email, password);
  }

  Future<void> registrarUsuario({
    required String email,
    required String password,
  }) async {
    await _authRepository.registrarUsuario(email, password);
  }

  Future<void> cerrarSesion() async {
    await _authRepository.cerrarSesion();
  }

  String? validarCredenciales({
    required String email,
    required String password,
  }) {
    if (email.trim().isEmpty || password.isEmpty) {
      return 'Completá todos los campos.';
    }

    if (!email.trim().contains('@') || !email.trim().contains('.')) {
      return 'Ingresá un correo electrónico válido.';
    }

    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }

    return null;
  }
}

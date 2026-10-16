import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get usuarioActual => _auth.currentUser;

  Stream<User?> get cambiosUsuario => _auth.authStateChanges();

  Future<UserCredential> iniciarSesion(String email, String password) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> registrarUsuario(String email, String password) async {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}

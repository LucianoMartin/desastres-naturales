import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();

  String? error;
  bool cargando = false;
  bool ocultarPassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration decoracionCampo({
    required String etiqueta,
    required IconData icono,
    Widget? sufijo,
  }) {
    return InputDecoration(
      labelText: etiqueta,
      prefixIcon: Icon(icono, color: AppColors.primaryGreen),
      suffixIcon: sufijo,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
    );
  }

  Future<void> autenticar({required bool registrar}) async {
    final mensaje = authService.validarCredenciales(
      email: emailController.text,
      password: passwordController.text,
    );

    if (mensaje != null) {
      setState(() => error = mensaje);
      return;
    }

    setState(() {
      cargando = true;
      error = null;
    });

    try {
      if (registrar) {
        await authService.registrarUsuario(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        await authService.iniciarSesion(
          email: emailController.text,
          password: passwordController.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        error = switch (e.code) {
          'invalid-email' => 'El correo electrónico no es válido.',
          'user-not-found' ||
          'wrong-password' ||
          'invalid-credential' => 'El correo o la contraseña son incorrectos.',
          'email-already-in-use' => 'Ya existe una cuenta con ese correo.',
          'weak-password' => 'Elegí una contraseña más segura.',
          'too-many-requests' => 'Demasiados intentos. Probá más tarde.',
          'network-request-failed' => 'Revisá tu conexión a internet.',
          'operation-not-allowed' =>
            'El acceso por correo está deshabilitado en Firebase.',
          _ => 'No se pudo completar la operación (${e.code}).',
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Ocurrió un error inesperado. Intentá nuevamente.';
      });
    } finally {
      if (mounted) {
        setState(() => cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryGreen,
              AppColors.lightGreen,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  elevation: 10,
                  color: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: AppColors.paleGreen,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.public,
                            size: 46,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Desastres Naturales',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ingresá o creá tu cuenta',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 28),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          decoration: decoracionCampo(
                            etiqueta: 'Correo electrónico',
                            icono: Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          obscureText: ocultarPassword,
                          onSubmitted: (_) => autenticar(registrar: false),
                          decoration: decoracionCampo(
                            etiqueta: 'Contraseña',
                            icono: Icons.lock_outline,
                            sufijo: IconButton(
                              onPressed: () {
                                setState(() {
                                  ocultarPassword = !ocultarPassword;
                                });
                              },
                              icon: Icon(
                                ocultarPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                        if (error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.errorRed,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: cargando
                                ? null
                                : () => autenticar(registrar: false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: AppColors.textPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: cargando
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.textPrimary,
                                    ),
                                  )
                                : const Text(
                                    'Iniciar sesión',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: cargando
                                ? null
                                : () => autenticar(registrar: true),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryGreen,
                              side: const BorderSide(
                                color: AppColors.primaryGreen,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Crear cuenta',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

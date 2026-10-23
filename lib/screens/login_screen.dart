import 'package:desastres_naturales/widgets/botones/boton_azul.dart';
import 'package:desastres_naturales/widgets/botones/boton_verde.dart';
import 'package:desastres_naturales/widgets/botones/campo_formulario.dart';
import 'package:desastres_naturales/widgets/logo_alertapp.dart';
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
              AppColors.fondoRojo,
              AppColors.fondoNormal,
              AppColors.fondoOscuro,
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
                  color: AppColors.fondoNormal,
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
                            color: AppColors.fondoClaro,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const LogoAlertApp(size: 100),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'AlertApp',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textoRojo,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ingresá o creá tu cuenta',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textoOscuro,
                          ),
                        ),
                        const SizedBox(height: 24),

                        CampoFormulario(
                          controller: emailController,
                          etiqueta: 'Correo electrónico',
                          icono: Icons.email_outlined,
                          teclado: TextInputType.emailAddress,
                          autocorrect: false,
                        ),

                        const SizedBox(height: 12),

                        CampoFormulario(
                          controller: passwordController,
                          etiqueta: 'Contraseña',
                          icono: Icons.lock_outline,
                          autocorrect: false,
                          mostrarBotonVisibilidad: true,
                          onSubmitted: (_) => autenticar(registrar: false),
                        ),

                        const SizedBox(height: 6),

                        if (error != null) ...[
                          Text(
                            error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textoRojo,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ] else
                          const SizedBox(height: 26),

                        BotonVerde(
                          texto: 'Iniciar sesión',
                          icono: Icons.login,
                          onPressed: cargando
                              ? null
                              : () => autenticar(registrar: false),
                        ),

                        const SizedBox(height: 12),

                        BotonAzul(
                          texto: 'Crear cuenta',
                          icono: Icons.person_add,
                          onPressed: cargando
                              ? null
                              : () => autenticar(registrar: true),
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

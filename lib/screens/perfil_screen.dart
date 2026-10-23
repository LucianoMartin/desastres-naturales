import 'package:desastres_naturales/theme/app_colors.dart';
import 'package:desastres_naturales/widgets/botones/boton.dart';
import 'package:desastres_naturales/widgets/botones/boton_azul.dart';
import 'package:desastres_naturales/widgets/botones/boton_rojo.dart';
import 'package:desastres_naturales/widgets/botones/boton_verde.dart';
import 'package:desastres_naturales/widgets/botones/campo_formulario.dart';
import 'package:desastres_naturales/widgets/dato_elemento.dart';
import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../repositories/usuario_repository.dart';
import '../services/perfil_service.dart';
import '../services/auth_service.dart';

class PerfilScreen extends StatefulWidget {
  final Usuario perfil;

  const PerfilScreen({super.key, required this.perfil});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final UsuarioRepository _usuarioRepository = UsuarioRepository();
  final PerfilService _perfilService = PerfilService();
  final TextEditingController _nombreController = TextEditingController();

  bool _editandoNombre = false;
  bool _ocupado = false;

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.perfil.nombre;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  Future<void> _guardarNombre(Usuario perfil) async {
    final nombre = _nombreController.text.trim();

    if (nombre.isEmpty) {
      _mostrarMensaje('El nombre no puede estar vacío.');
      return;
    }

    if (nombre.length > 50) {
      _mostrarMensaje('El nombre no puede superar los 50 caracteres.');
      return;
    }

    setState(() => _ocupado = true);

    try {
      await _perfilService.cambiarNombre(perfil.uid, nombre);

      if (!mounted) return;

      setState(() => _editandoNombre = false);
      _mostrarMensaje('Nombre actualizado correctamente.');
    } catch (e) {
      _mostrarMensaje('No se pudo actualizar el nombre: $e');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _cambiarFoto(Usuario perfil) async {
    setState(() => _ocupado = true);

    try {
      final url = await _perfilService.cambiarFotoPerfil(perfil.uid);

      if (!mounted) return;

      if (url != null) {
        _mostrarMensaje('Foto de perfil actualizada.');
      }
    } catch (e) {
      _mostrarMensaje('No se pudo cambiar la foto: $e');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _quitarFoto(Usuario perfil) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.fondoNormal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.textoRojo,
          size: 32,
        ),
        title: const Text('Quitar foto', 
          style: TextStyle(color:AppColors.textoClaro),
          textAlign: TextAlign.center,
        ),
        content: const Text('¿Querés eliminar tu foto de perfil?', 
          style: TextStyle(color:AppColors.textoClaro),
          textAlign: TextAlign.center,
        ),
        actions: [
          Boton(
            texto: 'Cancelar',
            ancho: 120,
            onPressed: () => Navigator.pop(dialogContext, false),
          ),
          BotonRojo(
            texto: 'Quitar',
            ancho: 120,
            onPressed: () => Navigator.pop(dialogContext, true),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() => _ocupado = true);

    try {
      await _perfilService.quitarFotoPerfil(perfil.uid);
      _mostrarMensaje('Foto de perfil eliminada.');
    } catch (e) {
      _mostrarMensaje('No se pudo quitar la foto: $e');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Widget _construirAvatar(Usuario perfil) {
    return Container(
      width: 124,
      height: 124,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.contenedorRojo, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.rojoPrimario.withValues(alpha: 0.13),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: perfil.avatarUrl.isNotEmpty
            ? Image.network(
                perfil.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _avatarPredeterminado();
                },
              )
            : _avatarPredeterminado(),
      ),
    );
  }

  Widget _avatarPredeterminado() {
    return Container(
      color: AppColors.fondoClaro,
      alignment: Alignment.center,
      child: const Icon(
        Icons.person_rounded,
        size: 64,
        color: AppColors.contenedorGris,
      ),
    );
  }

  Widget _construirEtiquetaRol(Usuario perfil) {
    final esAdmin = perfil.esAdmin;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.contenedorAmarillo,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            esAdmin
                ? Icons.admin_panel_settings_rounded
                : Icons.verified_user_rounded,
            color: AppColors.textoAmarillo,
            size: 14,
          ),
          const SizedBox(width: 7),
          Text(
            esAdmin ? 'Administrador' : 'Usuario',
            style: const TextStyle(
              color: AppColors.textoAmarillo,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirSeccionTitulo(String titulo, IconData icono) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icono, color: AppColors.rojoPrimario, size: 21),
          const SizedBox(width: 10),
          Text(
            titulo,
            style: const TextStyle(
              color: AppColors.textoMasClaro,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Usuario?>(
      stream: _usuarioRepository.observarUsuario(widget.perfil.uid),
      builder: (context, snapshot) {
        final perfilActual = snapshot.data ?? widget.perfil;

        if (!_editandoNombre) {
          final nombreActual = perfilActual.nombre;
          if (_nombreController.text != nombreActual) {
            _nombreController.text = nombreActual;
          }
        }

        return Scaffold(
          backgroundColor: AppColors.fondoOscuro,
          appBar: AppBar(
            backgroundColor: AppColors.fondoNormal,
            surfaceTintColor: AppColors.colorApp,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Mi perfil',
              style: TextStyle(
                color: AppColors.textoMasClaro,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Stack(
                  children: [
                    AbsorbPointer(
                      absorbing: _ocupado,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                        children: [
                          // Tarjeta principal del perfil
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
                            decoration: BoxDecoration(
                              color: AppColors.fondoNormal,
                              borderRadius: BorderRadius.circular(26),
                            ),
                            child: Column(
                              children: [
                                _construirAvatar(perfilActual),
                                const SizedBox(height: 18),
                                Text(
                                  perfilActual.nombre.isEmpty
                                      ? 'Mi cuenta'
                                      : perfilActual.nombre,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textoMasClaro,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  perfilActual.email,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textoClaro,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _construirEtiquetaRol(perfilActual),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    BotonAzul(
                                      texto: 'Cambiar foto',
                                      icono: Icons.add_a_photo_outlined,
                                      ancho: 170,
                                      onPressed: () =>
                                          _cambiarFoto(perfilActual),
                                    ),

                                    if (perfilActual.avatarUrl.isNotEmpty) ...[
                                      const SizedBox(width: 10),
                                      Boton(
                                        texto: 'Quitar foto',
                                        icono: Icons.delete_outline_rounded,
                                        ancho: 170,
                                        onPressed: () =>
                                            _quitarFoto(perfilActual),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          _construirSeccionTitulo(
                            'Información personal',
                            Icons.person_outline_rounded,
                          ),

                          // Datos de la cuenta
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.fondoNormal,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              children: [
                                // Nombre en modo edición
                                if (_editandoNombre) ...[
                                  const SizedBox(height: 16),
                                  CampoFormulario(
                                    controller: _nombreController,
                                    etiqueta: 'Nombre de usuario',
                                    icono: Icons.badge_outlined,
                                    maxLength: 50,
                                    autocorrect: false,
                                  ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: 0,
                                    children: [
                                      BotonVerde(
                                        texto: 'Guardar',
                                        icono: Icons.check_rounded,
                                        ancho: 150,
                                        onPressed: () =>
                                            _guardarNombre(perfilActual),
                                      ),
                                      const SizedBox(width: 12),
                                      BotonRojo(
                                        texto: 'Cancelar',
                                        icono: Icons.close_rounded,
                                        ancho: 150,
                                        onPressed: () {
                                          setState(() {
                                            _editandoNombre = false;
                                            _nombreController.text =
                                                perfilActual.nombre;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  // Nombre
                                  ElementoDato(
                                    icono: Icons.badge_outlined,
                                    titulo: 'Nombre de usuario',
                                    contenido: perfilActual.nombre,
                                    mostrarDivisor: false,
                                  ),

                                  Boton(
                                    texto: 'Editar nombre',
                                    icono: Icons.edit_outlined,
                                    ancho: 180,
                                    onPressed: () {
                                      _nombreController.text =
                                          perfilActual.nombre;
                                      setState(() => _editandoNombre = true);
                                    },
                                  ),
                                ],

                                // Correo electrónico
                                ElementoDato(
                                  icono: Icons.alternate_email_rounded, 
                                  titulo: 'Correo electrónico',
                                  contenido: perfilActual.email,
                                ),

                                // Tipo de cuenta
                                ElementoDato(
                                  icono: Icons.shield_outlined,
                                  titulo: 'Tipo de cuenta',
                                  contenido: perfilActual.esAdmin
                                      ? 'Administrador'
                                      : 'Usuario',
                                  mostrarDivisor: false,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Cierre de sesión
                          Center(
                            child: BotonRojo(
                              texto: 'Cerrar sesión',
                              icono: Icons.logout_rounded,
                              ancho: 180,
                              onPressed: () async {
                                try {
                                  await AuthService().cerrarSesion();
                                } catch (e) {
                                  _mostrarMensaje(
                                    'No se pudo cerrar sesión: $e',
                                  );
                                }
                              },
                            ),
                          ),

                          const SizedBox(height: 18),
                          const Center(
                            child: Text(
                              'AlertApp 2026 - Todos los derechos reservados',
                              style: TextStyle(
                                color: AppColors.textoOscuro,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_ocupado)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.35),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.textoRojo,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

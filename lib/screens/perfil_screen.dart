import 'package:desastres_naturales/theme/app_colors.dart';
import 'package:desastres_naturales/widgets/botones/boton.dart';
import 'package:desastres_naturales/widgets/botones/boton_rojo.dart';
import 'package:desastres_naturales/widgets/botones/boton_verde.dart';
import 'package:desastres_naturales/widgets/botones/campo_formulario.dart';
import 'package:desastres_naturales/widgets/elemento_dato.dart';
import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../repositories/usuario_repository.dart';
import '../services/perfil_service.dart';
import '../services/auth_service.dart';
import '../widgets/resumen_riesgo_perfil.dart';

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
        title: const Text(
          'Quitar foto',
          style: TextStyle(color: AppColors.textoClaro),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          '¿Querés eliminar tu foto de perfil?',
          style: TextStyle(color: AppColors.textoClaro),
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
    return SizedBox(
      width: 96,
      height: 96,
      child: ClipOval(
        child: perfil.avatarUrl.isNotEmpty
            ? Image.network(
                perfil.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _avatarPredeterminado(),
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
        Icons.person_outline_rounded,
        size: 48,
        color: AppColors.textoClaro,
      ),
    );
  }

  Widget _construirIdentidad(Usuario perfil) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      decoration: BoxDecoration(
        color: AppColors.fondoNormal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _construirAvatar(perfil),
          const SizedBox(height: 16),
          if (_editandoNombre) ...[
            CampoFormulario(
              controller: _nombreController,
              etiqueta: 'Nombre de usuario',
              icono: Icons.person_outline,
              maxLength: 50,
              autocorrect: false,
              onSubmitted: (_) {
                if (!_ocupado) _guardarNombre(perfil);
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Boton(
                  texto: 'Cancelar',
                  ancho: 120,
                  onPressed: () {
                    setState(() {
                      _editandoNombre = false;
                      _nombreController.text = perfil.nombre;
                    });
                  },
                ),
                BotonVerde(
                  texto: 'Guardar',
                  ancho: 120,
                  onPressed: () => _guardarNombre(perfil),
                ),
              ],
            ),
          ] else ...[
            Text(
              perfil.nombre.isEmpty ? 'Mi cuenta' : perfil.nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textoMasClaro,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Boton(
              texto: 'Editar nombre',
              icono: Icons.edit_outlined,
              ancho: 180,
              onPressed: () {
                _nombreController.text = perfil.nombre;
                setState(() => _editandoNombre = true);
              },
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.fondoClaro),

          ElementoDato(
            icono: Icons.mail_outline,
            titulo: 'Correo electrónico',
            contenido: perfil.email.isEmpty
                ? 'Sin correo registrado'
                : perfil.email,
          ),
          
          ElementoDato(
            icono: Icons.shield_outlined,
            titulo: 'Tipo de cuenta',
            contenido: perfil.esAdmin
                ? 'Cuenta de administrador'
                : 'Cuenta de usuario',
            mostrarDivisor: false,
          ),
        ],
      ),
    );
  }

  Widget _construirAccionFoto({
    required IconData icono,
    required String titulo,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icono, color: AppColors.textoRojo),
      title: Text(
        titulo,
        style: const TextStyle(color: AppColors.textoMasClaro),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textoClaro),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Usuario?>(
      stream: _usuarioRepository.observarUsuario(widget.perfil.uid),
      builder: (context, snapshot) {
        final perfilActual = snapshot.data ?? widget.perfil;

        if (!_editandoNombre && _nombreController.text != perfilActual.nombre) {
          _nombreController.text = perfilActual.nombre;
        }

        return Scaffold(
          backgroundColor: AppColors.fondoOscuro,
          appBar: AppBar(
            backgroundColor: AppColors.fondoNormal,
            foregroundColor: AppColors.textoMasClaro,
            elevation: 0,
            title: const Text(
              'Mi perfil',
              style: TextStyle(fontWeight: FontWeight.bold),
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
                        padding: const EdgeInsets.all(16),
                        children: [
                          _construirIdentidad(perfilActual),
                          const SizedBox(height: 24),
                          const ResumenRiesgoPerfil(),
                          const SizedBox(height: 24),
                          const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 12),
                            child: Text(
                              'Foto de perfil',
                              style: TextStyle(
                                color: AppColors.textoMasClaro,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Material(
                            color: AppColors.fondoNormal,
                            borderRadius: BorderRadius.circular(16),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                _construirAccionFoto(
                                  icono: Icons.add_a_photo_outlined,
                                  titulo: perfilActual.avatarUrl.isEmpty
                                      ? 'Agregar foto'
                                      : 'Cambiar foto',
                                  onTap: () => _cambiarFoto(perfilActual),
                                ),
                                if (perfilActual.avatarUrl.isNotEmpty) ...[
                                  const Divider(
                                    height: 1,
                                    indent: 16,
                                    endIndent: 16,
                                    color: AppColors.fondoClaro,
                                  ),
                                  _construirAccionFoto(
                                    icono: Icons.delete_outline_rounded,
                                    titulo: 'Quitar foto',
                                    onTap: () => _quitarFoto(perfilActual),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          Center(
                            child: BotonRojo(
                              texto: 'Cerrar sesión',
                              icono: Icons.logout_rounded,
                              ancho: 190,
                              onPressed: () async {
                                setState(() => _ocupado = true);
                                try {
                                  await AuthService().cerrarSesion();
                                } catch (e) {
                                  _mostrarMensaje(
                                    'No se pudo cerrar sesión: $e',
                                  );
                                } finally {
                                  if (mounted) setState(() => _ocupado = false);
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    if (_ocupado)
                      Positioned.fill(
                        child: Container(
                          color: AppColors.fondoOscuro.withValues(alpha: 0.6),
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

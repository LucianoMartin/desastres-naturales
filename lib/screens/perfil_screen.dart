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

  static const Color _fondo = Color(0xFF101A19);
  static const Color _tarjeta = Color(0xFF1A2925);
  static const Color _verde = Color(0xFF58D6A0);
  static const Color _verdeOscuro = Color(0xFF244A3B);
  static const Color _textoSecundario = Color(0xFF9CB1A7);
  static const Color _borde = Color(0xFF30443B);

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
        backgroundColor: _tarjeta,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFFF9B91),
          size: 32,
        ),
        title: const Text('Quitar foto'),
        content: const Text('¿Querés eliminar tu foto de perfil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8B3939),
              foregroundColor: Colors.white,
            ),
            child: const Text('Quitar foto'),
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
        border: Border.all(color: _verde, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: _verde.withValues(alpha: 0.13),
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
      color: _verdeOscuro,
      alignment: Alignment.center,
      child: const Icon(
        Icons.person_rounded,
        size: 64,
        color: Color(0xFFA6F0C9),
      ),
    );
  }

  Widget _construirEtiquetaRol(Usuario perfil) {
    final esAdmin = perfil.esAdmin;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: _verdeOscuro,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _verde.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            esAdmin
                ? Icons.admin_panel_settings_rounded
                : Icons.verified_user_rounded,
            color: _verde,
            size: 16,
          ),
          const SizedBox(width: 7),
          Text(
            esAdmin ? 'Administrador' : 'Usuario',
            style: const TextStyle(
              color: Color(0xFFA6F0C9),
              fontSize: 12,
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
          Icon(icono, color: _verde, size: 21),
          const SizedBox(width: 10),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirDato({
    required IconData icono,
    required String titulo,
    required String valor,
    bool mostrarDivisor = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _verdeOscuro,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icono, color: _verde, size: 21),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: _textoSecundario,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      valor.isEmpty ? 'Sin información' : valor,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (mostrarDivisor) const Divider(height: 1, color: _borde),
      ],
    );
  }

  Widget _construirBotonPrincipal({
    required IconData icono,
    required String texto,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icono, size: 20),
        label: Text(texto, style: const TextStyle(fontWeight: FontWeight.w600)),
        style: FilledButton.styleFrom(
          backgroundColor: _verde,
          foregroundColor: const Color(0xFF10231A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _construirBotonSecundario({
    required IconData icono,
    required String texto,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icono, size: 19),
        label: Text(texto),
        style: OutlinedButton.styleFrom(
          foregroundColor: _verde,
          side: const BorderSide(color: _borde),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
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
          backgroundColor: _fondo,
          appBar: AppBar(
            backgroundColor: _fondo,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Mi perfil',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
            ),
          ),
          body: SafeArea(
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
                          color: _tarjeta,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: _borde),
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
                                color: Colors.white,
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
                                color: _textoSecundario,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _construirEtiquetaRol(perfilActual),
                            const SizedBox(height: 22),
                            _construirBotonPrincipal(
                              icono: Icons.add_a_photo_outlined,
                              texto: 'Cambiar foto de perfil',
                              onPressed: () => _cambiarFoto(perfilActual),
                            ),
                            if (perfilActual.avatarUrl.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              _construirBotonSecundario(
                                icono: Icons.delete_outline_rounded,
                                texto: 'Quitar foto',
                                onPressed: () => _quitarFoto(perfilActual),
                              ),
                            ],
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
                          color: _tarjeta,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: _borde),
                        ),
                        child: Column(
                          children: [
                            if (_editandoNombre) ...[
                              const SizedBox(height: 17),
                              TextField(
                                controller: _nombreController,
                                autofocus: true,
                                maxLength: 50,
                                textCapitalization: TextCapitalization.words,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Nombre de usuario',
                                  labelStyle: const TextStyle(
                                    color: _textoSecundario,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.badge_outlined,
                                    color: _verde,
                                  ),
                                  filled: true,
                                  fillColor: _fondo,
                                  counterStyle: const TextStyle(
                                    color: _textoSecundario,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: _borde),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: _verde,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _construirBotonPrincipal(
                                icono: Icons.check_rounded,
                                texto: 'Guardar cambios',
                                onPressed: () => _guardarNombre(perfilActual),
                              ),
                              const SizedBox(height: 8),
                              _construirBotonSecundario(
                                icono: Icons.close_rounded,
                                texto: 'Cancelar',
                                onPressed: () {
                                  setState(() {
                                    _editandoNombre = false;
                                    _nombreController.text =
                                        perfilActual.nombre;
                                  });
                                },
                              ),
                              const SizedBox(height: 14),
                            ] else ...[
                              _construirDato(
                                icono: Icons.badge_outlined,
                                titulo: 'Nombre de usuario',
                                valor: perfilActual.nombre,
                                mostrarDivisor: false,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: _construirBotonSecundario(
                                  icono: Icons.edit_outlined,
                                  texto: 'Editar nombre',
                                  onPressed: () {
                                    _nombreController.text =
                                        perfilActual.nombre;
                                    setState(() => _editandoNombre = true);
                                  },
                                ),
                              ),
                            ],
                            _construirDato(
                              icono: Icons.alternate_email_rounded,
                              titulo: 'Correo electrónico',
                              valor: perfilActual.email,
                              mostrarDivisor: true,
                            ),
                            _construirDato(
                              icono: Icons.shield_outlined,
                              titulo: 'Tipo de cuenta',
                              valor: perfilActual.esAdmin
                                  ? 'Administrador'
                                  : 'Usuario',
                              mostrarDivisor: false,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Cierre de sesión
                      OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            await AuthService().cerrarSesion();
                          } catch (e) {
                            _mostrarMensaje('No se pudo cerrar sesión: $e');
                          }
                        },
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text(
                          'Cerrar sesión',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF9B91),
                          side: const BorderSide(color: Color(0xFF503332)),
                          backgroundColor: const Color(0xFF292020),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),
                      const Center(
                        child: Text(
                          'Desastres Naturales',
                          style: TextStyle(
                            color: _textoSecundario,
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
                        child: CircularProgressIndicator(color: _verde),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../services/notificacion_service.dart';

class BotonActivarAlertas extends StatefulWidget {
  final NotificacionService servicio;

  const BotonActivarAlertas({
    super.key,
    required this.servicio,
  });

  @override
  State<BotonActivarAlertas> createState() =>
      _BotonActivarAlertasState();
}

class _BotonActivarAlertasState
    extends State<BotonActivarAlertas> {
  bool? _concedido;
  bool _cargando = false;
  String? _mensaje;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _comprobarPermiso();
    }
  }

  Future<void> _comprobarPermiso() async {
    try {
      final concedido =
          await widget.servicio.permisoWebConcedido();

      if (!mounted) return;

      setState(() {
        _concedido = concedido;
        _mensaje = null;
      });
    } catch (e) {
      debugPrint('Error comprobando permisos: $e');

      if (!mounted) return;

      setState(() {
        _concedido = false;
        _mensaje = 'No se pudo comprobar el permiso del navegador.';
      });
    }
  }

  Future<void> _activarAlertas() async {
    if (_cargando) return;

    setState(() {
      _cargando = true;
      _mensaje = null;
    });

    try {
      final ok = await widget.servicio.pedirPermisoWeb();

      if (!mounted) return;

      setState(() {
        _concedido = ok;
        _mensaje = ok
            ? 'Permiso concedido. Comprobá la suscripción a las alertas.'
            : 'No se concedió el permiso. Revisá la configuración del navegador.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_mensaje!),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e, stack) {
      debugPrint('Error activando alertas: $e');
      debugPrintStack(stackTrace: stack);

      if (!mounted) return;

      setState(() {
        _mensaje = 'Error al activar alertas: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_mensaje!),
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || _concedido == true) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton.icon(
          onPressed: _cargando ? null : _activarAlertas,
          icon: _cargando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.notifications_active),
          label: Text(
            _cargando
                ? 'Activando alertas...'
                : 'Activar alertas en este navegador',
          ),
        ),
        if (_mensaje != null) ...[
          const SizedBox(height: 8),
          Text(
            _mensaje!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
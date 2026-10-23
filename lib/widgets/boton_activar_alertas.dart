import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../services/notificacion_service.dart';

/// Solo se muestra en web y mientras no haya permiso de notificaciones.
class BotonActivarAlertas extends StatefulWidget {
  final NotificacionService servicio;
  const BotonActivarAlertas({super.key, required this.servicio});

  @override
  State<BotonActivarAlertas> createState() => _BotonActivarAlertasState();
}

class _BotonActivarAlertasState extends State<BotonActivarAlertas> {
  bool? _concedido;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      widget.servicio.permisoWebConcedido().then((v) {
        if (mounted) setState(() => _concedido = v);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || _concedido != false) return const SizedBox.shrink();
    return FilledButton.icon(
      icon: const Icon(Icons.notifications_active),
      label: const Text('Activar alertas en este navegador'),
      onPressed: () async {
        final ok = await widget.servicio.pedirPermisoWeb();
        if (mounted) setState(() => _concedido = ok);
      },
    );
  }
}

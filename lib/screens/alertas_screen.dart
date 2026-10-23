import 'package:desastres_naturales/widgets/botones/boton_filtro.dart';
import 'package:flutter/material.dart';

import '../models/alerta.dart';
import '../services/alerta_service.dart';
import '../theme/app_colors.dart';
import '../widgets/alerta_expandida.dart';
import '../widgets/estado_vacio.dart';

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  final AlertaService _alertaService = AlertaService();

  String _tipoSeleccionado = 'Todas';

  bool _estaActiva(Alerta alerta) {
    final ahora = DateTime.now();

    return !alerta.fechaInicio.isAfter(ahora) &&
        (alerta.fechaFin == null || alerta.fechaFin!.isAfter(ahora));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoOscuro,
      appBar: AppBar(
        backgroundColor: AppColors.fondoNormal,
        foregroundColor: AppColors.textoMasClaro,
        elevation: 0,
        title: const Text(
          'Alertas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                _buildEncabezado(),
                Expanded(
                  child: StreamBuilder<List<Alerta>>(
                    stream: _alertaService.obtenerAlertas(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const EstadoVacio(
                          icono: Icons.error_outline,
                          titulo: 'No se pudieron cargar las alertas',
                          mensaje: 'Ocurrió un error al consultar los datos.',
                        );
                      }

                      if (snapshot.connectionState ==
                              ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.textoRojo,
                          ),
                        );
                      }

                      final todas = snapshot.data ?? [];

                      final activas =
                          todas.where(_estaActiva).toList()
                            ..sort((a, b) =>
                                b.fechaInicio.compareTo(a.fechaInicio));

                      final tipos = activas
                          .map((alerta) => alerta.tipo.trim())
                          .where((tipo) => tipo.isNotEmpty)
                          .toSet()
                          .toList()
                        ..sort((a, b) =>
                            a.toLowerCase().compareTo(b.toLowerCase()));

                      if (_tipoSeleccionado != 'Todas' &&
                          !tipos.contains(_tipoSeleccionado)) {
                        _tipoSeleccionado = 'Todas';
                      }

                      final filtradas = activas.where((alerta) {
                        return _tipoSeleccionado == 'Todas' ||
                            alerta.tipo.trim() == _tipoSeleccionado;
                      }).toList();

                      return Column(
                        children: [
                          _buildFiltros(tipos),
                          Expanded(
                            child: filtradas.isEmpty
                                ? const EstadoVacio()
                                : ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(
                                      16, 8, 16, 24,
                                    ),
                                    itemCount: filtradas.length,
                                    itemBuilder: (context, index) {
                                      return AlertaExpandida(
                                        key: ValueKey(filtradas[index].id),
                                        alerta: filtradas[index],
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEncabezado() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.fondoNormal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.notifications_active_outlined,
            color: AppColors.textoRojo,
            size: 34,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Centro de alertas',
                  style: TextStyle(
                    color: AppColors.textoMasClaro,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Consultá las emergencias activas y sus zonas de afectación.',
                  style: TextStyle(
                    color: AppColors.textoClaro,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros(List<String> tipos) {
    final opciones = ['Todas', ...tipos];

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final tipo in opciones)
            BotonFiltro(
              tipo: tipo,
              seleccionado: _tipoSeleccionado == tipo,
              onSelected: (_) {
                setState(() {
                  _tipoSeleccionado = tipo;
                });
              },
            ),
        ],
      ),
    );
  }
}
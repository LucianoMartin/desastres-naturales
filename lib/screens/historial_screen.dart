import 'package:desastres_naturales/widgets/botones/boton_filtro.dart';
import 'package:flutter/material.dart';

import '../models/alerta.dart';
import '../services/alerta_service.dart';
import '../theme/app_colors.dart';
import '../widgets/alerta_expandida.dart';
import '../widgets/estado_vacio.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final AlertaService _alertaService = AlertaService();

  String _tipoSeleccionado = 'Todas';

  bool _estaFinalizada(Alerta alerta) {
    final fechaFin = alerta.fechaFin;

    return fechaFin != null &&
        !fechaFin.isAfter(DateTime.now());
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
          'Historial',
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
                          titulo: 'No se pudo cargar el historial',
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

                      final finalizadas =
                          todas.where(_estaFinalizada).toList()
                            ..sort((a, b) =>
                                b.fechaFin!.compareTo(a.fechaFin!));

                      final tipos = finalizadas
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

                      final filtradas = finalizadas.where((alerta) {
                        return _tipoSeleccionado == 'Todas' ||
                            alerta.tipo.trim() == _tipoSeleccionado;
                      }).toList();

                      return Column(
                        children: [
                          _buildFiltros(tipos),
                          Expanded(
                            child: filtradas.isEmpty
                                ? const EstadoVacio(
                                  icono: Icons.history,
                                )
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
            Icons.history,
            color: AppColors.textoRojo,
            size: 34,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historial de eventos',
                  style: TextStyle(
                    color: AppColors.textoMasClaro,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Consultá las alertas que ya finalizaron.',
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < opciones.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              BotonFiltro(
                tipo: opciones[i],
                seleccionado: _tipoSeleccionado == opciones[i],
                onSelected: (_) {
                  setState(() {
                    _tipoSeleccionado = opciones[i];
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
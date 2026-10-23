import 'package:desastres_naturales/screens/alertas_screen.dart';
import 'package:desastres_naturales/screens/historial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/alerta.dart';
import '../services/alerta_service.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';
import '../widgets/banner_alertas.dart';
import '../widgets/controles_mapa.dart';
import '../widgets/mapa_alertas.dart';

import '../models/usuario.dart';

import 'perfil_screen.dart';

class HomeScreen extends StatefulWidget {
  final Usuario perfil;

  const HomeScreen({super.key, required this.perfil});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final MapController _mapController = MapController();

  final AlertaService _alertaService = AlertaService();
  final LocationService _locationService = LocationService();

  LatLng? _miUbicacion;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionInicial();
  }

  Future<void> _obtenerUbicacionInicial() async {
    try {
      final LatLng? ubicacion = await _locationService.obtenerUbicacionActual();

      if (!mounted || ubicacion == null) {
        return;
      }

      setState(() {
        _miUbicacion = ubicacion;
      });
    } catch (_) {}
  }

  Future<void> _centrarMapa() async {
    try {
      final bool serviceEnabled = await _locationService
          .verificarServicioUbicacion();

      if (!serviceEnabled) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Los servicios de ubicación están desactivados.'),
          ),
        );

        return;
      }

      final LatLng? posicionReal = await _locationService
          .obtenerUbicacionActual();

      if (posicionReal == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener la ubicación.')),
        );

        return;
      }

      if (mounted) {
        setState(() {
          _miUbicacion = posicionReal;
        });
      }

      _mapController.move(posicionReal, 14.5);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener la ubicación: $e')),
      );
    }
  }

  void _abrirMapaEn(LatLng ubicacion, double zoom) {
    setState(() {
      _selectedIndex = 0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _mapController.move(ubicacion, zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _buildMapTab(),
      _buildAlertsTab(),
      _buildHistoryTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      body: tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.fondoNormal,
        selectedItemColor: AppColors.contenedorRojo,
        unselectedItemColor: AppColors.textoOscuro,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        iconSize: 26,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map), 
            label: 'Mapa'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), 
            label: 'Perfil'
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    return StreamBuilder<List<Alerta>>(
      stream: _alertaService.obtenerAlertas(),
      builder: (context, snapshot) {
        final List<Alerta> alertas = snapshot.data ?? [];

        return Stack(
          children: [
            MapaAlertas(
              mapController: _mapController,
              alertas: alertas,
              miUbicacion: _miUbicacion,
            ),

            BannerAlertas(alertas: alertas),

            ControlesMapa(onCentrarUbicacion: _centrarMapa),
          ],
        );
      },
    );
  }

  Widget _buildAlertsTab() {
    return AlertasScreen(
      onAbrirMapa: _abrirMapaEn,
    );
  }

  Widget _buildHistoryTab() {
    return HistorialScreen(
      onAbrirMapa: _abrirMapaEn,
    );
  }

  Widget _buildProfileTab() {
    return PerfilScreen(perfil: widget.perfil);
  }
}

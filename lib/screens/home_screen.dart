import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/alerta.dart';
import '../services/alerta_service.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';
import '../widgets/banner_alertas.dart';
import '../widgets/controles_mapa.dart';
import '../widgets/mapa_alertas.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
        backgroundColor: AppColors.darkBackground,
        selectedItemColor: AppColors.lightGreen,
        unselectedItemColor: Colors.white60,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Historial',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
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
    return const Center(
      child: Text(
        'Sección de Alertas',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return const Center(
      child: Text(
        'Historial de Eventos',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildProfileTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryGreen,
              child: Icon(Icons.person, size: 44, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Perfil de Usuario',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await AuthService().cerrarSesion();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}

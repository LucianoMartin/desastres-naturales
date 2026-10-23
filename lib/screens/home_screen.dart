import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:desastres_naturales/screens/alertas_screen.dart';
import 'package:desastres_naturales/screens/historial_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/alerta.dart';
import '../models/usuario.dart';
import '../services/alerta_service.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';
import '../widgets/banner_alertas.dart';
import '../widgets/controles_mapa.dart';
import '../widgets/mapa_alertas.dart';
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

  late final Stream<List<Alerta>> _alertasStream;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _usuariosStream;

  LatLng? _miUbicacion;

  @override
  void initState() {
    super.initState();
    _alertasStream = _alertaService.obtenerAlertas();
    _usuariosStream = FirebaseFirestore.instance
        .collection('usuarios')
        .snapshots();
    _obtenerUbicacionInicial();
  }

  Future<void> _obtenerUbicacionInicial() async {
    try {
      final LatLng? ubicacion = await _locationService.obtenerUbicacionActual();

      if (ubicacion == null) {
        return;
      }

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.perfil.uid)
          .update({
            'latitud': ubicacion.latitude,
            'longitud': ubicacion.longitude,
          });

      if (!mounted) {
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

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.perfil.uid)
          .update({
            'latitud': posicionReal.latitude,
            'longitud': posicionReal.longitude,
          });

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
        backgroundColor: AppColors.fondoNormal,
        selectedItemColor: AppColors.contenedorRojo,
        unselectedItemColor: AppColors.textoOscuro,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        iconSize: 26,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
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
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    final String uidActual =
        FirebaseAuth.instance.currentUser?.uid ?? widget.perfil.uid;

    return StreamBuilder<List<Alerta>>(
      stream: _alertasStream,
      builder: (context, alertasSnapshot) {
        final List<Alerta> alertas = alertasSnapshot.data ?? [];

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _usuariosStream,
          builder: (context, usuariosSnapshot) {
            final List<Usuario> otrosUsuarios = [];
            Usuario perfilActual = widget.perfil;

            if (usuariosSnapshot.hasData) {
              for (final doc in usuariosSnapshot.data!.docs) {
                final data = doc.data();

                if (doc.id == uidActual || doc.id == widget.perfil.uid) {
                  perfilActual = Usuario.fromFirestore(doc.id, data);
                  continue;
                }

                if (data['latitud'] == null || data['longitud'] == null) {
                  continue;
                }

                final usuario = Usuario.fromFirestore(doc.id, data);
                if (usuario.tieneUbicacionValida) {
                  otrosUsuarios.add(usuario);
                }
              }
            }

            return Stack(
              children: [
                MapaAlertas(
                  mapController: _mapController,
                  alertas: alertas,
                  miUbicacion: _miUbicacion,
                  perfil: perfilActual,
                  otrosUsuarios: otrosUsuarios,
                ),

                BannerAlertas(alertas: alertas),

                ControlesMapa(
                  onCentrarUbicacion: _centrarMapa,
                  mapController: _mapController,
                  usuarios: otrosUsuarios,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAlertsTab() {
    return const AlertasScreen();
  }

  Widget _buildHistoryTab() {
    return const HistorialScreen();
  }

  Widget _buildProfileTab() {
    return PerfilScreen(perfil: widget.perfil);
  }
}

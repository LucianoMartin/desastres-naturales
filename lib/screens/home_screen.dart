import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:marquee/marquee.dart';

import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final MapController mapController = MapController();
  late final AnimationController _waveController;
  late final Stream<QuerySnapshot> _alertasStream;
  LatLng? miUbicacion;

  // Coordenada central inicial (ej. Buenos Aires / Florencio Varela)
  static const LatLng _initialCenter = LatLng(-34.6037, -58.3816);
  static const double _initialZoom = 5.0;

  @override
  void initState() {
    super.initState();
    _alertasStream = FirebaseFirestore.instance
        .collection('alertas')
        .snapshots();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _obtenerUbicacionInicial();
  }

  Future<void> _obtenerUbicacionInicial() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final Position position = await Geolocator.getCurrentPosition();
        if (!mounted) return;
        setState(() {
          miUbicacion = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _centrarMapa() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Los servicios de ubicación están desactivados.'),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de ubicación denegado.')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Los permisos de ubicación están denegados permanentemente.',
            ),
          ),
        );
        return;
      }

      final Position position = await Geolocator.getCurrentPosition();
      final LatLng posicionReal = LatLng(position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          miUbicacion = posicionReal;
        });
      }
      mapController.move(posicionReal, 14.5);
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
        onTap: (index) => setState(() => _selectedIndex = index),
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
    return Stack(
      children: [
        // 1. Fondo (FlutterMap con OpenStreetMap, fuera del redibujado de la animación)
        FlutterMap(
          mapController: mapController,
          options: const MapOptions(
            initialCenter: _initialCenter,
            initialZoom: _initialZoom,
            minZoom: 4.5,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.unaj.desastres_naturales',
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _alertasStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return const Stack(
                    children: [
                      CircleLayer<Object>(circles: []),
                      MarkerLayer(markers: []),
                    ],
                  );
                }

                final docs = snapshot.data!.docs;
                final List<Marker> markers = [];

                for (final doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final double latitud =
                      (data['latitud'] as num?)?.toDouble() ?? 0.0;
                  final double longitud =
                      (data['longitud'] as num?)?.toDouble() ?? 0.0;
                  final String tipoRaw = (data['tipo'] ?? '').toString();

                  markers.add(
                    Marker(
                      point: LatLng(latitud, longitud),
                      width: 120,
                      height: 36,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            tipoRaw,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Stack(
                  children: [
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        final double animValue = _waveController.value;
                        final double opacity = (1.0 - animValue).clamp(
                          0.0,
                          1.0,
                        );
                        final List<CircleMarker> circles = [];

                        for (final doc in docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final String tipo = (data['tipo'] ?? '')
                              .toString()
                              .toLowerCase();
                          final double latitud =
                              (data['latitud'] as num?)?.toDouble() ?? 0.0;
                          final double longitud =
                              (data['longitud'] as num?)?.toDouble() ?? 0.0;
                          final double radio =
                              (data['radio'] as num?)?.toDouble() ?? 500.0;
                          final LatLng center = LatLng(latitud, longitud);

                          if (tipo == 'misil') {
                            circles.add(
                              CircleMarker(
                                point: center,
                                radius: radio * animValue,
                                useRadiusInMeter: true,
                                color: Colors.red.withValues(
                                  alpha: 0.5 * opacity,
                                ),
                                borderColor: Colors.red.withValues(
                                  alpha: opacity,
                                ),
                                borderStrokeWidth: 2.5,
                              ),
                            );
                          } else if (tipo == 'terremoto') {
                            // Onda expansiva naranja
                            circles.add(
                              CircleMarker(
                                point: center,
                                radius: radio * animValue,
                                useRadiusInMeter: true,
                                color: Colors.orange.withValues(
                                  alpha: 0.5 * opacity,
                                ),
                                borderColor: Colors.deepOrange.withValues(
                                  alpha: opacity,
                                ),
                                borderStrokeWidth: 2.5,
                              ),
                            );
                            // Círculo central estático pequeño (epicentro)
                            circles.add(
                              CircleMarker(
                                point: center,
                                radius: 7,
                                useRadiusInMeter: false,
                                color: Colors.deepOrange,
                                borderColor: Colors.white,
                                borderStrokeWidth: 2.0,
                              ),
                            );
                          }
                        }

                        return CircleLayer(circles: circles);
                      },
                    ),
                    MarkerLayer(markers: markers),
                  ],
                );
              },
            ),
            if (miUbicacion != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: miUbicacion!,
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),

        // 2. Capa Superior (Banner animado con Marquee conectado a Firestore)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 44,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warningOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _alertasStream,
                      builder: (context, snapshot) {
                        String marqueeText = 'Sin alertas activas';

                        if (snapshot.hasData &&
                            snapshot.data!.docs.isNotEmpty) {
                          final List<String> alertas = [];
                          for (final doc in snapshot.data!.docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            final String tipo = (data['tipo'] ?? '')
                                .toString()
                                .trim();
                            if (tipo.isNotEmpty) {
                              alertas.add('⚠️ Alerta $tipo');
                            }
                          }

                          if (alertas.isNotEmpty) {
                            marqueeText = alertas.join(' - ');
                          }
                        }

                        return Marquee(
                          text: marqueeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          scrollAxis: Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          blankSpace: 40.0,
                          velocity: 45.0,
                          pauseAfterRound: const Duration(seconds: 1),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 3. Capa Inferior Izquierda (Avatares + botón '+')
        Positioned(
          left: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMiniAvatar(Colors.teal.shade700, Icons.person),
                const SizedBox(width: 6),
                _buildMiniAvatar(Colors.indigo.shade600, Icons.person_outline),
                const SizedBox(width: 6),
                _buildMiniAvatar(Colors.deepOrange.shade600, Icons.person),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(
                      Icons.add,
                      size: 18,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 4. Capa Inferior Derecha (Botón flotante de Ubicación)
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _centrarMapa,
            backgroundColor: AppColors.darkBackground,
            foregroundColor: Colors.white,
            tooltip: 'Centrar ubicación',
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniAvatar(Color color, IconData icon) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: color,
      child: Icon(icon, size: 18, color: Colors.white),
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

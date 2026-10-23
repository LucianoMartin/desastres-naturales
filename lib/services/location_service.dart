import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  LocationService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  Future<bool> verificarServicioUbicacion() async {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> obtenerPermiso() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  Future<LatLng?> obtenerUbicacionActual() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return null;
    }

    final LocationPermission permission = await obtenerPermiso();

    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return null;
    }

    final Position position = await Geolocator.getCurrentPosition();

    final User? usuarioActual = _auth.currentUser;
    if (usuarioActual != null) {
      try {
        await _firestore
            .collection('usuarios')
            .doc(usuarioActual.uid)
            .update({
              'latitud': position.latitude,
              'longitud': position.longitude,
            });
      } catch (e) {
        dev.log(
          'Error al actualizar ubicación en Firestore: $e',
          name: 'location',
        );
      }
    }

    return LatLng(position.latitude, position.longitude);
  }
}

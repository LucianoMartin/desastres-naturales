import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
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

    return LatLng(position.latitude, position.longitude);
  }
}

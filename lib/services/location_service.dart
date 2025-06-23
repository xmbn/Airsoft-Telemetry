import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Stream<Position>? _positionStream;

  Future<void> _requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  Future<Position?> getCurrentPosition() async {
    await _requestPermission();
    if (await Geolocator.isLocationServiceEnabled()) {
      return await Geolocator.getCurrentPosition();
    }
    return null;
  }

  Stream<Position>? getPositionStream({int distanceFilter = 10}) {
    _requestPermission().then((_) {
      if (Geolocator.isLocationServiceEnabled() != null) {
        _positionStream = Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: distanceFilter,
          ),
        );
      }
    });
    return _positionStream;
  }
}

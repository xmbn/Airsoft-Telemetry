import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  StreamController<Position>? _positionController;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, can't continue.
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      return null;
    }
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } on TimeoutException {
      // Handle timeout
      return null;
    } catch (e) {
      // Handle other errors
      return null;
    }
  }

  Stream<Position> getPositionStream({int distanceFilter = 5}) async* {
    final hasPermission = await _handleLocationPermission();
    if (hasPermission) {
      yield* Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: distanceFilter,
        ),
      );
    }
  }

  // Start continuous position tracking with custom interval
  Stream<Position> startContinuousTracking({int intervalSeconds = 2}) async* {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    _positionController = StreamController<Position>.broadcast();
    
    Timer.periodic(Duration(seconds: intervalSeconds), (timer) async {
      try {
        final position = await getCurrentPosition();
        if (position != null && !_positionController!.isClosed) {
          _positionController!.add(position);
        }
      } catch (e) {
        // Handle error silently, continue tracking
      }
    });

    yield* _positionController!.stream;
  }

  void stopContinuousTracking() {
    _positionSubscription?.cancel();
    _positionController?.close();
    _positionSubscription = null;
    _positionController = null;
  }

  void dispose() {
    stopContinuousTracking();
  }
}

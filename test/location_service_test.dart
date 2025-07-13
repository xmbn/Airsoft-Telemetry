// Dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geolocator/geolocator.dart';
import 'package:airsoft_telemetry_flutter/services/location_service.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGeolocator extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {}

void main() {
  late LocationService locationService;
  late MockGeolocator mockGeolocator;

  setUp(() {
    mockGeolocator = MockGeolocator();
    GeolocatorPlatform.instance = mockGeolocator;
    locationService = LocationService();
  });

  setUpAll(() {
    registerFallbackValue(const LocationSettings());
  });
  group('LocationService', () {
    test('getCurrentPosition returns null if permission denied', () async {
      when(() => mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(() => mockGeolocator.requestPermission())
          .thenAnswer((_) async => LocationPermission.denied);

      final result = await locationService.getCurrentPosition();
      expect(result, isNull);
    }, tags: ['unit']);

    test('getCurrentPosition returns Position if permission granted', () async {
      final fakePosition = Position(
        longitude: 1.0,
        latitude: 2.0,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 1.0,
        heading: 1.0,
        speed: 1.0,
        speedAccuracy: 1.0,
        floor: null, // or 0 if required
        isMocked: true,
        headingAccuracy: 1.0,
        altitudeAccuracy: 1.0,
      );

      when(() => mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.always);
      when(() => mockGeolocator.getCurrentPosition(
            locationSettings: any(named: 'locationSettings'),
          )).thenAnswer((_) async => fakePosition);

      final result = await locationService.getCurrentPosition();
      expect(result, equals(fakePosition));
    }, tags: ['unit']);

    test('getPositionStream yields positions if permission granted', () async {
      final fakePosition = Position(
        longitude: 1.0,
        latitude: 2.0,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 1.0,
        heading: 1.0,
        speed: 1.0,
        speedAccuracy: 1.0,
        floor: null, // or 0 if required
        isMocked: true,
        headingAccuracy: 1.0,
        altitudeAccuracy: 1.0,
      );
      when(() => mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.always);
      when(() => mockGeolocator.getPositionStream(
            locationSettings: any(named: 'locationSettings'),
          )).thenAnswer((_) => Stream.value(fakePosition));

      final stream = locationService.getPositionStream();
      expect(await stream.first, equals(fakePosition));
    }, tags: ['unit']);

    test('getPositionStream yields nothing if permission denied', () async {
      when(() => mockGeolocator.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);
      when(() => mockGeolocator.requestPermission())
          .thenAnswer((_) async => LocationPermission.denied);

      final stream = locationService.getPositionStream();
      expect(await stream.isEmpty, isTrue);
    }, tags: ['unit']);
  });
}

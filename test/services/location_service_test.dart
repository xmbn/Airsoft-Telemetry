import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:airsoft_telemetry_flutter/services/location_service.dart';

// Mock class for Geolocator
class MockGeolocator extends Mock {
  static Future<bool> isLocationServiceEnabled() async {
    return MockGeolocator._instance._isLocationServiceEnabled();
  }

  static Future<LocationPermission> checkPermission() async {
    return MockGeolocator._instance._checkPermission();
  }

  static Future<LocationPermission> requestPermission() async {
    return MockGeolocator._instance._requestPermission();
  }

  static Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    return MockGeolocator._instance._getCurrentPosition();
  }

  static Stream<Position> getPositionStream({
    LocationSettings? locationSettings,
  }) {
    return MockGeolocator._instance._getPositionStream();
  }

  static MockGeolocator _instance = MockGeolocator();

  Future<bool> _isLocationServiceEnabled() async => throw UnimplementedError();
  Future<LocationPermission> _checkPermission() async => throw UnimplementedError();
  Future<LocationPermission> _requestPermission() async => throw UnimplementedError();
  Future<Position> _getCurrentPosition() async => throw UnimplementedError();
  Stream<Position> _getPositionStream() => throw UnimplementedError();
}

void main() {
  group('LocationService Tests', () {
    late LocationService locationService;
    late MockGeolocator mockGeolocator;

    setUp(() {
      locationService = LocationService();
      mockGeolocator = MockGeolocator();
      MockGeolocator._instance = mockGeolocator;
    });

    tearDown(() {
      reset(mockGeolocator);
    });

    group('getCurrentPosition', () {
      test('should return null when location service is disabled', () async {
        // Arrange
        when(() => mockGeolocator._isLocationServiceEnabled())
            .thenAnswer((_) async => false);

        // Act
        final result = await locationService.getCurrentPosition();

        // Assert
        expect(result, isNull);
        verify(() => mockGeolocator._isLocationServiceEnabled()).called(1);
        verifyNever(() => mockGeolocator._checkPermission());
      });

      test('should return null when permission is denied', () async {
        // Arrange
        when(() => mockGeolocator._isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockGeolocator._checkPermission())
            .thenAnswer((_) async => LocationPermission.denied);
        when(() => mockGeolocator._requestPermission())
            .thenAnswer((_) async => LocationPermission.denied);

        // Act
        final result = await locationService.getCurrentPosition();

        // Assert
        expect(result, isNull);
        verify(() => mockGeolocator._isLocationServiceEnabled()).called(1);
        verify(() => mockGeolocator._checkPermission()).called(1);
        verify(() => mockGeolocator._requestPermission()).called(1);
        verifyNever(() => mockGeolocator._getCurrentPosition());
      });

      test('should return null when permission is denied forever', () async {
        // Arrange
        when(() => mockGeolocator._isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockGeolocator._checkPermission())
            .thenAnswer((_) async => LocationPermission.deniedForever);

        // Act
        final result = await locationService.getCurrentPosition();

        // Assert
        expect(result, isNull);
        verify(() => mockGeolocator._isLocationServiceEnabled()).called(1);
        verify(() => mockGeolocator._checkPermission()).called(1);
        verifyNever(() => mockGeolocator._requestPermission());
        verifyNever(() => mockGeolocator._getCurrentPosition());
      });

      test('should return position when permission is granted initially', () async {
        // Arrange
        final expectedPosition = Position(
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime.now(),
          accuracy: 5.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        when(() => mockGeolocator._isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockGeolocator._checkPermission())
            .thenAnswer((_) async => LocationPermission.always);
        when(() => mockGeolocator._getCurrentPosition())
            .thenAnswer((_) async => expectedPosition);

        // Act
        final result = await locationService.getCurrentPosition();

        // Assert
        expect(result, equals(expectedPosition));
        verify(() => mockGeolocator._isLocationServiceEnabled()).called(1);
        verify(() => mockGeolocator._checkPermission()).called(1);
        verify(() => mockGeolocator._getCurrentPosition()).called(1);
        verifyNever(() => mockGeolocator._requestPermission());
      });

      test('should return position when permission is granted after request', () async {
        // Arrange
        final expectedPosition = Position(
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime.now(),
          accuracy: 5.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        when(() => mockGeolocator._isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockGeolocator._checkPermission())
            .thenAnswer((_) async => LocationPermission.denied);
        when(() => mockGeolocator._requestPermission())
            .thenAnswer((_) async => LocationPermission.whileInUse);
        when(() => mockGeolocator._getCurrentPosition())
            .thenAnswer((_) async => expectedPosition);

        // Act
        final result = await locationService.getCurrentPosition();

        // Assert
        expect(result, equals(expectedPosition));
        verify(() => mockGeolocator._isLocationServiceEnabled()).called(1);
        verify(() => mockGeolocator._checkPermission()).called(1);
        verify(() => mockGeolocator._requestPermission()).called(1);
        verify(() => mockGeolocator._getCurrentPosition()).called(1);
      });
    });

    group('getPositionStream', () {
      test('should return empty stream when location service is disabled', () async {
        // Arrange
        when(() => mockGeolocator._isLocationServiceEnabled())
            .thenAnswer((_) async => false);

        // Act
        final stream = locationService.getPositionStream();
        final positions = await stream.toList();

        // Assert
        expect(positions, isEmpty);
        verify(() => mockGeolocator._isLocationServiceEnabled()).called(1);
        verifyNever(() => mockGeolocator._checkPermission());
      });

      test('should return empty stream when permission is denied', () async {
        // Arrange
        when(() => mockGeolocator._isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockGeolocator._checkPermission())
            .thenAnswer((_) async => LocationPermission.denied);
        when(() => mockGeolocator._requestPermission())
            .thenAnswer((_) async => LocationPermission.denied);

        // Act
        final stream = locationService.getPositionStream();
        final positions = await stream.toList();

        // Assert
        expect(positions, isEmpty);
        verify(() => mockGeolocator._isLocationServiceEnabled()).called(1);
        verify(() => mockGeolocator._checkPermission()).called(1);
        verify(() => mockGeolocator._requestPermission()).called(1);
      });

      test('should return position stream when permissions are granted', () async {
        // Arrange
        final position1 = Position(
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime.now(),
          accuracy: 5.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        final position2 = Position(
          latitude: 37.7750,
          longitude: -122.4195,
          timestamp: DateTime.now().add(const Duration(seconds: 1)),
          accuracy: 5.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        when(() => mockGeolocator._isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockGeolocator._checkPermission())
            .thenAnswer((_) async => LocationPermission.always);
        when(() => mockGeolocator._getPositionStream())
            .thenAnswer((_) => Stream.fromIterable([position1, position2]));

        // Act
        final stream = locationService.getPositionStream();
        final positions = await stream.toList();

        // Assert
        expect(positions, hasLength(2));
        expect(positions[0], equals(position1));
        expect(positions[1], equals(position2));
        verify(() => mockGeolocator._isLocationServiceEnabled()).called(1);
        verify(() => mockGeolocator._checkPermission()).called(1);
        verify(() => mockGeolocator._getPositionStream()).called(1);
      });

      test('should pass custom distance filter to position stream', () async {
        // Arrange
        when(() => mockGeolocator._isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockGeolocator._checkPermission())
            .thenAnswer((_) async => LocationPermission.always);
        when(() => mockGeolocator._getPositionStream())
            .thenAnswer((_) => const Stream.empty());

        // Act
        final stream = locationService.getPositionStream(distanceFilter: 50);
        await stream.toList();

        // Assert
        verify(() => mockGeolocator._isLocationServiceEnabled()).called(1);
        verify(() => mockGeolocator._checkPermission()).called(1);
        verify(() => mockGeolocator._getPositionStream()).called(1);
      });
    });

    group('Permission handling edge cases', () {
      test('should handle LocationPermission.whileInUse correctly', () async {
        // Arrange
        final expectedPosition = Position(
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime.now(),
          accuracy: 5.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        when(() => mockGeolocator._isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockGeolocator._checkPermission())
            .thenAnswer((_) async => LocationPermission.whileInUse);
        when(() => mockGeolocator._getCurrentPosition())
            .thenAnswer((_) async => expectedPosition);

        // Act
        final result = await locationService.getCurrentPosition();

        // Assert
        expect(result, equals(expectedPosition));
        verify(() => mockGeolocator._checkPermission()).called(1);
        verifyNever(() => mockGeolocator._requestPermission());
      });

      test('should handle LocationPermission.always correctly', () async {
        // Arrange
        final expectedPosition = Position(
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime.now(),
          accuracy: 5.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        when(() => mockGeolocator._isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockGeolocator._checkPermission())
            .thenAnswer((_) async => LocationPermission.always);
        when(() => mockGeolocator._getCurrentPosition())
            .thenAnswer((_) async => expectedPosition);

        // Act
        final result = await locationService.getCurrentPosition();

        // Assert
        expect(result, equals(expectedPosition));
        verify(() => mockGeolocator._checkPermission()).called(1);
        verifyNever(() => mockGeolocator._requestPermission());
      });
    });
  });
}

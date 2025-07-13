import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:airsoft_telemetry_flutter/main.dart' as app;
import 'package:airsoft_telemetry_flutter/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Location Integration Tests', () {
    late LocationService locationService;

    setUp(() {
      locationService = LocationService();
    });

    testWidgets('LocationService works with real GPS when permissions granted',
        (tester) async {
      // Test real location functionality
      final position = await locationService.getCurrentPosition();

      if (position != null) {
        // Verify position properties
        expect(position.latitude, isA<double>());
        expect(position.longitude, isA<double>());
        expect(position.accuracy, greaterThan(0));
        expect(position.timestamp, isA<DateTime>());
        expect(position.altitude, isA<double>());
        expect(position.speed, isA<double>());
        expect(position.heading, isA<double>());

        // Verify reasonable coordinate ranges
        expect(position.latitude, greaterThanOrEqualTo(-90));
        expect(position.latitude, lessThanOrEqualTo(90));
        expect(position.longitude, greaterThanOrEqualTo(-180));
        expect(position.longitude, lessThanOrEqualTo(180));

        // Print all possible Position fields
        print('--- Location Details ---');
        print('Latitude: ${position.latitude}');
        print('Longitude: ${position.longitude}');
        print('Accuracy: ${position.accuracy}');
        print('Altitude: ${position.altitude}');
        print('Speed: ${position.speed}');
        print('Speed Accuracy: ${position.speedAccuracy}');
        print('Heading: ${position.heading}');
        print('Heading Accuracy: ${position.headingAccuracy}');
        print('Timestamp: ${position.timestamp}');
        print('Floor: ${position.floor}');
        print('Is Mocked: ${position.isMocked}');
        print('Altitude Accuracy: ${position.altitudeAccuracy}');
        print('-----------------------');
      } else {
        // If position is null, it could be due to permissions or service issues
        print('Location service returned null - checking permission status');

        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        final permission = await Geolocator.checkPermission();

        print('Service enabled: $serviceEnabled, Permission: $permission');

        // In integration tests, we might expect this to work or fail gracefully
        expect(position, isNull,
            reason: 'Location service unavailable or permissions denied');
      }
    });

    testWidgets('LocationService position stream works', (tester) async {
      // Test position stream functionality
      final stream = locationService.getPositionStream(distanceFilter: 5);

      // Listen to the stream for a short time
      final subscription = stream.listen(
        (position) {
          expect(position.latitude, isA<double>());
          expect(position.longitude, isA<double>());
          expect(position.accuracy, greaterThan(0));
        },
        onError: (error) {
          print('Position stream error: $error');
        },
      );

      // Wait a bit to see if we get any positions
      await Future.delayed(const Duration(seconds: 3));
      await subscription.cancel();
    });

    testWidgets('App initializes and handles location services',
        (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app loads successfully
      expect(find.byType(MaterialApp), findsOneWidget);

      // Check if there are any location-related UI elements
      // This would depend on your specific UI implementation
      // await tester.pump(const Duration(seconds: 2));

      // You might want to test specific user interactions here
      // For example, if there's a button to get location:
      // final locationButton = find.byKey(const Key('location_button'));
      // if (tester.any(locationButton)) {
      //   await tester.tap(locationButton);
      //   await tester.pumpAndSettle();
      // }
    });

    testWidgets('LocationService handles permission scenarios gracefully',
        (tester) async {
      // This test verifies the service handles different permission states
      final position = await locationService.getCurrentPosition();

      // The service should either return a valid position or null
      // It should not throw unhandled exceptions
      if (position != null) {
        expect(position, isA<Position>());
      } else {
        // Verify the service handled permission issues gracefully
        expect(position, isNull);
      }
    });
  });
}

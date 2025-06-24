import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:airsoft_telemetry_flutter/main.dart' as app;
import 'package:airsoft_telemetry_flutter/services/location_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Location Integration Tests', () {
    testWidgets('LocationService works with real GPS', (tester) async {
      final locationService = LocationService();
      
      // Test real location functionality
      final position = await locationService.getCurrentPosition();
        if (position != null) {
        expect(position.latitude, isA<double>());
        expect(position.longitude, isA<double>());
        expect(position.accuracy, greaterThan(0));
      }
    }, tags: ['integration']);

    testWidgets('App handles location permissions correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle();      
      // Test UI interactions with real location services
      // ...
    }, tags: ['integration']);
  });
}

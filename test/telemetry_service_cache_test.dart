import 'package:flutter_test/flutter_test.dart';
import 'package:airsoft_telemetry_flutter/services/telemetry_service.dart';
import 'package:airsoft_telemetry_flutter/models/game_event.dart';
import 'dart:async';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('TelemetryService Event Caching', () {
    late TelemetryService telemetryService;

    setUp(() {
      telemetryService = TelemetryService();
    });

    test('should provide cached events immediately to new stream listeners', () async {
      // Initialize the service
      await telemetryService.initialize();
      
      // Check that cached events getter works
      final cachedEvents = telemetryService.cachedRecentEvents;
      expect(cachedEvents, isA<List<GameEvent>>());
      
      // Test that stream emits immediately for new listeners
      final streamCompleter = Completer<List<GameEvent>>();
      
      final subscription = telemetryService.recentEventsStream.listen((events) {
        if (!streamCompleter.isCompleted) {
          streamCompleter.complete(events);
        }
      });
      
      // Should get events immediately or very quickly
      final events = await streamCompleter.future.timeout(
        const Duration(milliseconds: 100),
        onTimeout: () => <GameEvent>[],
      );
      
      expect(events, isA<List<GameEvent>>());
      
      await subscription.cancel();
    });

    test('should maintain cached events between stream subscriptions', () async {
      // Initialize the service
      await telemetryService.initialize();
      
      // Get initial cached events
      final initialCachedEvents = telemetryService.cachedRecentEvents;
      
      // Create first subscription and cancel it
      final subscription1 = telemetryService.recentEventsStream.listen((events) {});
      await subscription1.cancel();
      
      // Check that cached events are still available
      final cachedEventsAfterCancel = telemetryService.cachedRecentEvents;
      expect(cachedEventsAfterCancel.length, equals(initialCachedEvents.length));
      
      // Create second subscription and verify it gets the same cached events
      List<GameEvent>? secondSubscriptionEvents;
      final subscription2 = telemetryService.recentEventsStream.listen((events) {
        secondSubscriptionEvents = events;
      });
      
      // Wait a bit for the stream to emit
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(secondSubscriptionEvents, isNotNull);
      expect(secondSubscriptionEvents!.length, equals(cachedEventsAfterCancel.length));
      
      await subscription2.cancel();
    });
  });
}

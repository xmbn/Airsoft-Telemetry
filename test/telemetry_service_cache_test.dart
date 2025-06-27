import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geolocator/geolocator.dart';
import 'package:airsoft_telemetry_flutter/models/game_event.dart';
import 'package:airsoft_telemetry_flutter/services/database_service.dart';
import 'package:airsoft_telemetry_flutter/services/location_service.dart';
import 'package:airsoft_telemetry_flutter/services/preferences_service.dart';
import 'dart:async';

// Mock classes
class MockDatabaseService extends Mock implements DatabaseService {}
class MockLocationService extends Mock implements LocationService {}
class MockPreferencesService extends Mock implements PreferencesService {}

// Create a testable version of TelemetryService
class TestableTelemetryService {
  final DatabaseService _databaseService;
  final LocationService _locationService;
  final PreferencesService _preferencesService;

  String? _currentSessionId;
  String _currentPlayerId = 'test_player';
  List<GameEvent> _cachedRecentEvents = [];
  
  final StreamController<List<GameEvent>> _recentEventsController = 
      StreamController<List<GameEvent>>.broadcast();

  TestableTelemetryService({
    required DatabaseService databaseService,
    required LocationService locationService,
    required PreferencesService preferencesService,
  }) : _databaseService = databaseService,
       _locationService = locationService,
       _preferencesService = preferencesService;

  List<GameEvent> get cachedRecentEvents => List.unmodifiable(_cachedRecentEvents);

  Stream<List<GameEvent>> get recentEventsStream {
    return Stream.multi((controller) {
      // Immediately emit cached events if available
      if (_cachedRecentEvents.isNotEmpty) {
        controller.add(_cachedRecentEvents);
      }
      
      // Then listen to the actual stream for updates
      final subscription = _recentEventsController.stream.listen(
        (events) => controller.add(events),
        onError: (error) => controller.addError(error),
        onDone: () => controller.close(),
      );
      
      controller.onCancel = () => subscription.cancel();
    });
  }

  Future<void> initialize() async {
    // Load preferences (mocked)
    final preferences = await _preferencesService.loadAllPreferences();
    _currentPlayerId = preferences['playerName'] ?? 'test_player';
    
    // Get initial position (mocked)
    await _locationService.getCurrentPosition();
    
    // Load recent events
    await _updateRecentEvents();
  }

  Future<void> _updateRecentEvents() async {
    final events = await _databaseService.getRecentEvents(limit: 50);
    _cachedRecentEvents = events;
    _recentEventsController.add(_cachedRecentEvents);
  }

  void dispose() {
    _recentEventsController.close();
  }
}

void main() {
  group('TelemetryService Event Caching', () {
    late TestableTelemetryService telemetryService;
    late MockDatabaseService mockDatabaseService;
    late MockLocationService mockLocationService;
    late MockPreferencesService mockPreferencesService;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockLocationService = MockLocationService();
      mockPreferencesService = MockPreferencesService();
      
      telemetryService = TestableTelemetryService(
        databaseService: mockDatabaseService,
        locationService: mockLocationService,
        preferencesService: mockPreferencesService,
      );
    });

    tearDown(() {
      telemetryService.dispose();
    });

    setUpAll(() {
      // Register fallback values
      registerFallbackValue(<String, dynamic>{});
    });

    test('should provide cached events immediately to new stream listeners', () async {
      // Arrange
      final mockEvents = [
        GameEvent(
          gameSessionId: 'test_session',
          playerId: 'test_player',
          eventType: 'HIT',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          latitude: 40.7128,
          longitude: -74.0060,
          altitude: 10.0,
        ),
      ];

      when(() => mockPreferencesService.loadAllPreferences())
          .thenAnswer((_) async => {'playerName': 'test_player'});
      when(() => mockLocationService.getCurrentPosition())
          .thenAnswer((_) async => null);
      when(() => mockDatabaseService.getRecentEvents(limit: any(named: 'limit')))
          .thenAnswer((_) async => mockEvents);

      // Act
      await telemetryService.initialize();
      
      // Check that cached events getter works
      final cachedEvents = telemetryService.cachedRecentEvents;
      expect(cachedEvents, isA<List<GameEvent>>());
      expect(cachedEvents.length, equals(1));
      
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
      expect(events.length, equals(1));
      expect(events[0].gameSessionId, equals('test_session'));
      
      await subscription.cancel();
    });

    test('should maintain cached events between stream subscriptions', () async {
      // Arrange
      final mockEvents = [
        GameEvent(
          gameSessionId: 'test_session_1',
          playerId: 'test_player',
          eventType: 'START',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          latitude: 40.7128,
          longitude: -74.0060,
          altitude: 10.0,
        ),
        GameEvent(
          gameSessionId: 'test_session_1',
          playerId: 'test_player',
          eventType: 'HIT',
          timestamp: DateTime.now().millisecondsSinceEpoch + 1000,
          latitude: 40.7129,
          longitude: -74.0061,
          altitude: 10.0,
        ),
      ];

      when(() => mockPreferencesService.loadAllPreferences())
          .thenAnswer((_) async => {'playerName': 'test_player'});
      when(() => mockLocationService.getCurrentPosition())
          .thenAnswer((_) async => null);
      when(() => mockDatabaseService.getRecentEvents(limit: any(named: 'limit')))
          .thenAnswer((_) async => mockEvents);

      // Act
      await telemetryService.initialize();
      
      // Get initial cached events
      final initialCachedEvents = telemetryService.cachedRecentEvents;
      expect(initialCachedEvents.length, equals(2));
      
      // Create first subscription and cancel it
      final subscription1 = telemetryService.recentEventsStream.listen((events) {});
      await subscription1.cancel();
      
      // Check that cached events are still available
      final cachedEventsAfterCancel = telemetryService.cachedRecentEvents;
      expect(cachedEventsAfterCancel.length, equals(initialCachedEvents.length));
      expect(cachedEventsAfterCancel.length, equals(2));
      
      // Create second subscription and verify it gets the same cached events
      List<GameEvent>? secondSubscriptionEvents;
      final subscription2 = telemetryService.recentEventsStream.listen((events) {
        secondSubscriptionEvents = events;
      });
      
      // Wait a bit for the stream to emit
      await Future.delayed(const Duration(milliseconds: 50));
      
      expect(secondSubscriptionEvents, isNotNull);
      expect(secondSubscriptionEvents!.length, equals(cachedEventsAfterCancel.length));
      expect(secondSubscriptionEvents!.length, equals(2));
      expect(secondSubscriptionEvents![0].eventType, equals('START'));
      expect(secondSubscriptionEvents![1].eventType, equals('HIT'));
      
      await subscription2.cancel();
    });
  });
}

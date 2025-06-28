import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:airsoft_telemetry_flutter/services/telemetry_service.dart';
import 'package:airsoft_telemetry_flutter/services/database_service.dart';
import 'package:airsoft_telemetry_flutter/models/game_event.dart';
import 'dart:async';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('TelemetryService Integration Tests', () {
    late TelemetryService telemetryService;
    late DatabaseService databaseService;

    setUp(() async {
      telemetryService = TelemetryService();
      databaseService = DatabaseService();
      
      // Clear any existing data and reset service state
      await databaseService.clearAllEvents();
      
      // Initialize the service
      await telemetryService.initialize();
    });

    tearDown(() async {
      // Stop any running sessions and clear data
      if (telemetryService.sessionState != SessionState.stopped) {
        await telemetryService.stopSession();
      }
      await databaseService.clearAllEvents();
    });

    tearDownAll(() async {
      telemetryService.dispose();
      await databaseService.close();
    });

    test('complete session lifecycle creates correct events', () async {
      // Verify initial state
      expect(telemetryService.sessionState, equals(SessionState.stopped));
      expect(telemetryService.currentSessionId, isNull);
      
      // Start session
      await telemetryService.startSession();
      expect(telemetryService.sessionState, equals(SessionState.running));
      expect(telemetryService.currentSessionId, isNotNull);
      
      final sessionId = telemetryService.currentSessionId!;
      
      // Wait a moment for any automatic events
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Record manual event
      await telemetryService.recordManualEvent('HIT');
      
      // Pause session
      await telemetryService.pauseSession();
      expect(telemetryService.sessionState, equals(SessionState.paused));
      
      // Resume session
      await telemetryService.resumeSession();
      expect(telemetryService.sessionState, equals(SessionState.running));
      
      // Record another manual event
      await telemetryService.recordManualEvent('KILL');
      
      // Stop session
      await telemetryService.stopSession();
      expect(telemetryService.sessionState, equals(SessionState.stopped));
      expect(telemetryService.currentSessionId, isNull);
      
      // Verify events were recorded
      final sessionEvents = await databaseService.getEventsBySession(sessionId);
      expect(sessionEvents.length, greaterThanOrEqualTo(5)); // START, HIT, PAUSE, RESUME, KILL, STOP
      
      // Verify event types in session
      final eventTypes = sessionEvents.map((e) => e.eventType).toSet();
      expect(eventTypes, contains('START'));
      expect(eventTypes, contains('HIT'));
      expect(eventTypes, contains('PAUSE'));
      expect(eventTypes, contains('RESUME'));
      expect(eventTypes, contains('KILL'));
      expect(eventTypes, contains('STOP'));
      
      // Verify all events have the same session ID
      for (final event in sessionEvents) {
        expect(event.gameSessionId, equals(sessionId));
        expect(event.playerId, isNotEmpty);
      }
    });

    test('event caching updates correctly during session', () async {
      // Start with empty cache
      expect(telemetryService.cachedRecentEvents, isEmpty);
      
      // Start session
      await telemetryService.startSession();
      
      // Wait for START event to be processed
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check cache has START event
      var cachedEvents = telemetryService.cachedRecentEvents;
      expect(cachedEvents.length, greaterThanOrEqualTo(1));
      expect(cachedEvents.any((e) => e.eventType == 'START'), isTrue);
      
      // Record manual event
      await telemetryService.recordManualEvent('OBJECTIVE_CAPTURED');
      
      // Wait for cache update
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Check cache includes new event
      cachedEvents = telemetryService.cachedRecentEvents;
      expect(cachedEvents.any((e) => e.eventType == 'OBJECTIVE_CAPTURED'), isTrue);
      
      // Stop session
      await telemetryService.stopSession();
      
      // Wait for STOP event and cache update
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Verify cache shows recent events from all sessions
      cachedEvents = telemetryService.cachedRecentEvents;
      expect(cachedEvents.any((e) => e.eventType == 'STOP'), isTrue);
    });

    test('stream notifications work during session lifecycle', () async {
      final List<SessionState> stateChanges = [];
      final List<List<GameEvent>> eventUpdates = [];
      
      // Subscribe to streams
      final stateSubscription = telemetryService.sessionStateStream.listen((state) {
        stateChanges.add(state);
      });
      
      final eventsSubscription = telemetryService.recentEventsStream.listen((events) {
        eventUpdates.add(List.from(events));
      });
      
      // Perform session operations
      await telemetryService.startSession();
      await Future.delayed(const Duration(milliseconds: 500));
      
      await telemetryService.recordManualEvent('TEST_EVENT');
      await Future.delayed(const Duration(milliseconds: 300));
      
      await telemetryService.pauseSession();
      await Future.delayed(const Duration(milliseconds: 300));
      
      await telemetryService.resumeSession();
      await Future.delayed(const Duration(milliseconds: 300));
      
      await telemetryService.stopSession();
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Verify state changes
      expect(stateChanges, contains(SessionState.running));
      expect(stateChanges, contains(SessionState.paused));
      expect(stateChanges, contains(SessionState.stopped));
      
      // Verify event updates occurred
      expect(eventUpdates.length, greaterThan(3));
      
      // Verify final event list includes our test event
      final finalEvents = eventUpdates.last;
      expect(finalEvents.any((e) => e.eventType == 'TEST_EVENT'), isTrue);
      
      // Clean up
      await stateSubscription.cancel();
      await eventsSubscription.cancel();
    });

    test('auto-start functionality works for manual events', () async {
      // Verify service is stopped
      expect(telemetryService.sessionState, equals(SessionState.stopped));
      
      // Record manual event while stopped (should auto-start)
      await telemetryService.recordManualEvent('EMERGENCY');
      
      // Verify session was auto-started
      expect(telemetryService.sessionState, equals(SessionState.running));
      expect(telemetryService.currentSessionId, isNotNull);
      
      // Wait for events to be processed
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Verify both START and EMERGENCY events were recorded
      final sessionId = telemetryService.currentSessionId!;
      final events = await databaseService.getEventsBySession(sessionId);
      expect(events.length, greaterThanOrEqualTo(2));
      
      final eventTypes = events.map((e) => e.eventType).toSet();
      expect(eventTypes, contains('START'));
      expect(eventTypes, contains('EMERGENCY'));
    });

    test('paused session prevents manual event recording', () async {
      // Start and immediately pause session
      await telemetryService.startSession();
      await telemetryService.pauseSession();
      
      final sessionId = telemetryService.currentSessionId!;
      
      // Get initial event count
      await Future.delayed(const Duration(milliseconds: 300));
      final initialEvents = await databaseService.getEventsBySession(sessionId);
      final initialCount = initialEvents.length;
      
      // Try to record event while paused
      await telemetryService.recordManualEvent('SHOULD_NOT_RECORD');
      
      // Wait and verify no new events were added
      await Future.delayed(const Duration(milliseconds: 300));
      final finalEvents = await databaseService.getEventsBySession(sessionId);
      expect(finalEvents.length, equals(initialCount));
      
      // Verify the blocked event is not in the database
      expect(finalEvents.any((e) => e.eventType == 'SHOULD_NOT_RECORD'), isFalse);
    });

    test('location tracking creates periodic LOCATION events', () async {
      // Start session
      await telemetryService.startSession();
      
      // Wait for multiple location tracking intervals
      await Future.delayed(const Duration(seconds: 6));
      
      final sessionId = telemetryService.currentSessionId!;
      final events = await databaseService.getEventsBySession(sessionId);
      
      // Count LOCATION events
      final locationEvents = events.where((e) => e.eventType == 'LOCATION').length;
      
      // Should have at least 2-3 location events (depending on timing and interval settings)
      expect(locationEvents, greaterThanOrEqualTo(2));
      
      // Stop session
      await telemetryService.stopSession();
    });

    test('player name and interval updates work correctly', () async {
      // Update player name
      await telemetryService.updatePlayerName('integration_test_player');
      expect(telemetryService.currentPlayerId, equals('integration_test_player'));
      
      // Update interval
      await telemetryService.updateInterval('5 seconds');
      
      // Start session to verify new settings are used
      await telemetryService.startSession();
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Record an event to verify player name
      await telemetryService.recordManualEvent('SETTINGS_TEST');
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      final sessionId = telemetryService.currentSessionId!;
      final events = await databaseService.getEventsBySession(sessionId);
      
      // Verify player name is used in events
      final testEvent = events.firstWhere((e) => e.eventType == 'SETTINGS_TEST');
      expect(testEvent.playerId, equals('integration_test_player'));
      
      await telemetryService.stopSession();
    });

    test('clear all data functionality works', () async {
      // Create a session with events
      await telemetryService.startSession();
      await telemetryService.recordManualEvent('BEFORE_CLEAR');
      await telemetryService.stopSession();
      
      // Verify events exist
      await Future.delayed(const Duration(milliseconds: 500));
      var allEvents = await telemetryService.getAllEvents();
      expect(allEvents.length, greaterThan(0));
      
      // Clear all data
      final deletedCount = await telemetryService.clearAllData();
      expect(deletedCount, greaterThan(0));
      
      // Verify data is cleared
      allEvents = await telemetryService.getAllEvents();
      expect(allEvents.length, equals(0));
      
      // Verify cache is also cleared
      expect(telemetryService.cachedRecentEvents, isEmpty);
    });

    test('service initialization loads correct preferences', () async {
      // The service should already be initialized from setUp
      expect(telemetryService.currentPlayerId, isNotEmpty);
      
      // Verify position stream and state stream are available
      expect(telemetryService.sessionStateStream, isNotNull);
      expect(telemetryService.positionStream, isNotNull);
      expect(telemetryService.recentEventsStream, isNotNull);
      
      // Verify initial state
      expect(telemetryService.sessionState, equals(SessionState.stopped));
      expect(telemetryService.currentSessionId, isNull);
    });
  });
}

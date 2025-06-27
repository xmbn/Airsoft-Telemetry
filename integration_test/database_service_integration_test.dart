import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:airsoft_telemetry_flutter/models/game_event.dart';
import 'package:airsoft_telemetry_flutter/services/database_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('DatabaseService Integration Tests', () {
    late DatabaseService databaseService;

    setUp(() async {
      databaseService = DatabaseService();
      // Clear any existing data before each test
      await databaseService.clearAllEvents();
    });

    tearDownAll(() async {
      // Only close once at the end
      await databaseService.close();
    });

    test('insertEvent adds event to database and returns valid ID', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final event = GameEvent(
        gameSessionId: 'test_session_1',
        playerId: 'player_1',
        eventType: 'HIT',
        timestamp: timestamp,
        latitude: 40.7128,
        longitude: -74.0060,
        altitude: 10.0,
        azimuth: 45.0,
        speed: 2.5,
        accuracy: 3.0,
      );

      final id = await databaseService.insertEvent(event);
      expect(id, greaterThan(0));

      // Verify the event was actually inserted
      final count = await databaseService.getEventCount();
      expect(count, equals(1));
    });

    test('getAllEvents retrieves all events in correct order', () async {
      final timestamp1 = DateTime.now().millisecondsSinceEpoch - 1000;
      final timestamp2 = DateTime.now().millisecondsSinceEpoch;
      
      final event1 = GameEvent(
        gameSessionId: 'session_1',
        playerId: 'player_1',
        eventType: 'HIT',
        timestamp: timestamp1,
        latitude: 40.7128,
        longitude: -74.0060,
        altitude: 0.0,
      );

      final event2 = GameEvent(
        gameSessionId: 'session_2',
        playerId: 'player_2',
        eventType: 'KILL',
        timestamp: timestamp2,
        latitude: 41.7128,
        longitude: -75.0060,
        altitude: 0.0,
      );

      await databaseService.insertEvent(event1);
      await databaseService.insertEvent(event2);

      final events = await databaseService.getAllEvents();
      expect(events.length, equals(2));
      
      // Should be ordered by timestamp DESC (newest first)
      expect(events[0].timestamp, equals(timestamp2));
      expect(events[1].timestamp, equals(timestamp1));
      expect(events[0].eventType, equals('KILL'));
      expect(events[1].eventType, equals('HIT'));
    });

    test('getEventsBySession filters events correctly', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final eventSession1 = GameEvent(
        gameSessionId: 'session_1',
        playerId: 'player_1',
        eventType: 'HIT',
        timestamp: timestamp,
        latitude: 40.7128,
        longitude: -74.0060,
        altitude: 0.0,
      );

      final eventSession2 = GameEvent(
        gameSessionId: 'session_2',
        playerId: 'player_2',
        eventType: 'KILL',
        timestamp: timestamp + 1000,
        latitude: 41.7128,
        longitude: -75.0060,
        altitude: 0.0,
      );

      final anotherEventSession1 = GameEvent(
        gameSessionId: 'session_1',
        playerId: 'player_3',
        eventType: 'REVIVE',
        timestamp: timestamp + 2000,
        latitude: 42.7128,
        longitude: -76.0060,
        altitude: 0.0,
      );

      await databaseService.insertEvent(eventSession1);
      await databaseService.insertEvent(eventSession2);
      await databaseService.insertEvent(anotherEventSession1);

      final session1Events = await databaseService.getEventsBySession('session_1');
      expect(session1Events.length, equals(2));
      expect(session1Events[0].gameSessionId, equals('session_1'));
      expect(session1Events[1].gameSessionId, equals('session_1'));
      
      final session2Events = await databaseService.getEventsBySession('session_2');
      expect(session2Events.length, equals(1));
      expect(session2Events[0].gameSessionId, equals('session_2'));
    });

    test('getRecentEvents respects limit parameter', () async {
      final baseTimestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Insert 10 events
      for (int i = 0; i < 10; i++) {
        final event = GameEvent(
          gameSessionId: 'session_$i',
          playerId: 'player_$i',
          eventType: 'EVENT_$i',
          timestamp: baseTimestamp + i * 1000,
          latitude: 40.0 + i,
          longitude: -74.0 - i,
          altitude: 0.0,
        );
        await databaseService.insertEvent(event);
      }

      // Test default limit
      final defaultEvents = await databaseService.getRecentEvents();
      expect(defaultEvents.length, equals(10)); // Should get all since we only have 10

      // Test custom limit
      final limitedEvents = await databaseService.getRecentEvents(limit: 5);
      expect(limitedEvents.length, equals(5));
      
      // Should be ordered by timestamp DESC (newest first)
      expect(limitedEvents[0].eventType, equals('EVENT_9'));
      expect(limitedEvents[4].eventType, equals('EVENT_5'));
    });

    test('clearAllEvents removes all data', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Insert multiple events
      for (int i = 0; i < 5; i++) {
        final event = GameEvent(
          gameSessionId: 'session_$i',
          playerId: 'player_$i',
          eventType: 'TEST',
          timestamp: timestamp + i * 1000,
          latitude: 40.0 + i,
          longitude: -74.0 - i,
          altitude: 0.0,
        );
        await databaseService.insertEvent(event);
      }

      // Verify events were inserted
      final countBefore = await databaseService.getEventCount();
      expect(countBefore, equals(5));

      // Clear all events
      final deletedCount = await databaseService.clearAllEvents();
      expect(deletedCount, equals(5));

      // Verify all events were deleted
      final countAfter = await databaseService.getEventCount();
      expect(countAfter, equals(0));

      final allEvents = await databaseService.getAllEvents();
      expect(allEvents.length, equals(0));
    });

    test('clearEventsBySession removes only specified session data', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Insert events for different sessions
      final eventSession1a = GameEvent(
        gameSessionId: 'session_1',
        playerId: 'player_1',
        eventType: 'HIT',
        timestamp: timestamp,
        latitude: 40.7128,
        longitude: -74.0060,
        altitude: 0.0,
      );

      final eventSession1b = GameEvent(
        gameSessionId: 'session_1',
        playerId: 'player_2',
        eventType: 'KILL',
        timestamp: timestamp + 1000,
        latitude: 41.7128,
        longitude: -75.0060,
        altitude: 0.0,
      );

      final eventSession2 = GameEvent(
        gameSessionId: 'session_2',
        playerId: 'player_3',
        eventType: 'REVIVE',
        timestamp: timestamp + 2000,
        latitude: 42.7128,
        longitude: -76.0060,
        altitude: 0.0,
      );

      await databaseService.insertEvent(eventSession1a);
      await databaseService.insertEvent(eventSession1b);
      await databaseService.insertEvent(eventSession2);

      // Clear only session_1 events
      final deletedCount = await databaseService.clearEventsBySession('session_1');
      expect(deletedCount, equals(2));

      // Verify session_1 events are gone
      final session1Events = await databaseService.getEventsBySession('session_1');
      expect(session1Events.length, equals(0));

      // Verify session_2 events remain
      final session2Events = await databaseService.getEventsBySession('session_2');
      expect(session2Events.length, equals(1));

      // Verify total count
      final totalCount = await databaseService.getEventCount();
      expect(totalCount, equals(1));
    });

    test('getEventCount returns correct count', () async {
      // Initially should be 0
      final initialCount = await databaseService.getEventCount();
      expect(initialCount, equals(0));

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Insert events one by one and verify count
      for (int i = 1; i <= 3; i++) {
        final event = GameEvent(
          gameSessionId: 'session_$i',
          playerId: 'player_$i',
          eventType: 'TEST',
          timestamp: timestamp + i * 1000,
          latitude: 40.0 + i,
          longitude: -74.0 - i,
          altitude: 0.0,
        );
        await databaseService.insertEvent(event);

        final count = await databaseService.getEventCount();
        expect(count, equals(i));
      }
    });

    test('database persists data correctly with complex GameEvent', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final originalEvent = GameEvent(
        gameSessionId: 'complex_session_123',
        playerId: 'player_with_special_chars_!@#',
        eventType: 'COMPLEX_EVENT',
        timestamp: timestamp,
        latitude: 40.758896,
        longitude: -73.985130,
        altitude: 123.45,
        azimuth: 270.5,
        speed: 15.7,
        accuracy: 2.3,
      );

      // Insert the event
      final id = await databaseService.insertEvent(originalEvent);
      expect(id, greaterThan(0));

      // Retrieve all events
      final events = await databaseService.getAllEvents();
      expect(events.length, equals(1));

      final retrievedEvent = events[0];
      
      // Verify all fields are correctly persisted and retrieved
      expect(retrievedEvent.id, equals(id));
      expect(retrievedEvent.gameSessionId, equals(originalEvent.gameSessionId));
      expect(retrievedEvent.playerId, equals(originalEvent.playerId));
      expect(retrievedEvent.eventType, equals(originalEvent.eventType));
      expect(retrievedEvent.timestamp, equals(originalEvent.timestamp));
      expect(retrievedEvent.latitude, equals(originalEvent.latitude));
      expect(retrievedEvent.longitude, equals(originalEvent.longitude));
      expect(retrievedEvent.altitude, equals(originalEvent.altitude));
      expect(retrievedEvent.azimuth, equals(originalEvent.azimuth));
      expect(retrievedEvent.speed, equals(originalEvent.speed));
      expect(retrievedEvent.accuracy, equals(originalEvent.accuracy));
    });

    test('database handles null optional fields correctly', () async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final eventWithNulls = GameEvent(
        gameSessionId: 'session_null_test',
        playerId: 'player_null_test',
        eventType: 'NULL_TEST',
        timestamp: timestamp,
        latitude: 40.7128,
        longitude: -74.0060,
        altitude: 0.0, // Required field
        // Optional fields are null
        azimuth: null,
        speed: null,
        accuracy: null,
      );

      // Insert the event
      final id = await databaseService.insertEvent(eventWithNulls);
      expect(id, greaterThan(0));

      // Retrieve the event
      final events = await databaseService.getAllEvents();
      expect(events.length, equals(1));

      final retrievedEvent = events[0];
      
      // Verify required fields
      expect(retrievedEvent.gameSessionId, equals(eventWithNulls.gameSessionId));
      expect(retrievedEvent.playerId, equals(eventWithNulls.playerId));
      expect(retrievedEvent.eventType, equals(eventWithNulls.eventType));
      expect(retrievedEvent.timestamp, equals(eventWithNulls.timestamp));
      expect(retrievedEvent.latitude, equals(eventWithNulls.latitude));
      expect(retrievedEvent.longitude, equals(eventWithNulls.longitude));
      expect(retrievedEvent.altitude, equals(eventWithNulls.altitude));
      
      // Verify optional fields are null
      expect(retrievedEvent.azimuth, isNull);
      expect(retrievedEvent.speed, isNull);
      expect(retrievedEvent.accuracy, isNull);
    });
  });
}

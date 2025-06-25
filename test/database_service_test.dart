import 'package:flutter_test/flutter_test.dart';
import 'package:airsoft_telemetry_flutter/models/game_event.dart';

void main() {
  group('GameEvent Database Model', () {
    test('GameEvent model works correctly', () {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final event = GameEvent(
        gameSessionId: 'test_session_1',
        playerId: 'test_player',
        eventType: 'TEST',
        timestamp: timestamp,
        latitude: 40.7128,
        longitude: -74.0060,
        altitude: 10.0,
        azimuth: 45.0,
        speed: 2.5,
        accuracy: 3.0,
      );

      expect(event.gameSessionId, equals('test_session_1'));
      expect(event.playerId, equals('test_player'));
      expect(event.eventType, equals('TEST'));
      expect(event.timestamp, equals(timestamp));
      expect(event.latitude, equals(40.7128));
      expect(event.longitude, equals(-74.0060));
      expect(event.altitude, equals(10.0));
      expect(event.azimuth, equals(45.0));
      expect(event.speed, equals(2.5));
      expect(event.accuracy, equals(3.0));
    });

    test('GameEvent toJson and fromJson work correctly', () {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final originalEvent = GameEvent(
        id: 1,
        gameSessionId: 'session_123',
        playerId: 'player_1',
        eventType: 'LOCATION',
        timestamp: timestamp,
        latitude: 40.7128,
        longitude: -74.0060,
        altitude: 10.0,
        azimuth: 45.0,
        speed: 2.5,
        accuracy: 3.0,
      );

      final json = originalEvent.toJson();
      final reconstructedEvent = GameEvent.fromJson(json);

      expect(reconstructedEvent.id, equals(originalEvent.id));
      expect(reconstructedEvent.gameSessionId, equals(originalEvent.gameSessionId));
      expect(reconstructedEvent.playerId, equals(originalEvent.playerId));
      expect(reconstructedEvent.eventType, equals(originalEvent.eventType));
      expect(reconstructedEvent.timestamp, equals(originalEvent.timestamp));
      expect(reconstructedEvent.latitude, equals(originalEvent.latitude));
      expect(reconstructedEvent.longitude, equals(originalEvent.longitude));
      expect(reconstructedEvent.altitude, equals(originalEvent.altitude));
      expect(reconstructedEvent.azimuth, equals(originalEvent.azimuth));
      expect(reconstructedEvent.speed, equals(originalEvent.speed));
      expect(reconstructedEvent.accuracy, equals(originalEvent.accuracy));
    });
  });
}

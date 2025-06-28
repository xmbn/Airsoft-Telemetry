import 'package:flutter_test/flutter_test.dart';
import 'package:airsoft_telemetry_flutter/models/game_event.dart';

void main() {
  group('GameEvent', () {
    test('creates GameEvent with all required fields', () {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final event = GameEvent(
        gameSessionId: 'session_123',
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

      expect(event.gameSessionId, equals('session_123'));
      expect(event.playerId, equals('player_1'));
      expect(event.eventType, equals('HIT'));
      expect(event.timestamp, equals(timestamp));
      expect(event.latitude, equals(40.7128));
      expect(event.longitude, equals(-74.0060));
      expect(event.altitude, equals(10.0));
      expect(event.azimuth, equals(45.0));
      expect(event.speed, equals(2.5));
      expect(event.accuracy, equals(3.0));
    });

    test('creates GameEvent with optional fields as null', () {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final event = GameEvent(
        gameSessionId: 'session_123',
        playerId: 'player_1',
        eventType: 'START',
        timestamp: timestamp,
        latitude: 40.7128,
        longitude: -74.0060,
        altitude: 10.0,
      );

      expect(event.azimuth, isNull);
      expect(event.speed, isNull);
      expect(event.accuracy, isNull);
    });

    test('toJson converts GameEvent to Map correctly', () {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final event = GameEvent(
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

      final json = event.toJson();

      expect(json['id'], equals(1));
      expect(json['gameSessionId'], equals('session_123'));
      expect(json['playerId'], equals('player_1'));
      expect(json['eventType'], equals('LOCATION'));
      expect(json['timestamp'], equals(timestamp));
      expect(json['latitude'], equals(40.7128));
      expect(json['longitude'], equals(-74.0060));
      expect(json['altitude'], equals(10.0));
      expect(json['azimuth'], equals(45.0));
      expect(json['speed'], equals(2.5));
      expect(json['accuracy'], equals(3.0));
    });

    test('fromJson creates GameEvent from Map correctly', () {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final json = {
        'id': 1,
        'gameSessionId': 'session_123',
        'playerId': 'player_1',
        'eventType': 'KILL',
        'timestamp': timestamp,
        'latitude': 40.7128,
        'longitude': -74.0060,
        'altitude': 10.0,
        'azimuth': 45.0,
        'speed': 2.5,
        'accuracy': 3.0,
      };

      final event = GameEvent.fromJson(json);

      expect(event.id, equals(1));
      expect(event.gameSessionId, equals('session_123'));
      expect(event.playerId, equals('player_1'));
      expect(event.eventType, equals('KILL'));
      expect(event.timestamp, equals(timestamp));
      expect(event.latitude, equals(40.7128));
      expect(event.longitude, equals(-74.0060));
      expect(event.altitude, equals(10.0));
      expect(event.azimuth, equals(45.0));
      expect(event.speed, equals(2.5));
      expect(event.accuracy, equals(3.0));
    });

    test('fromJson handles null optional fields', () {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final json = {
        'id': null,
        'gameSessionId': 'session_123',
        'playerId': 'player_1',
        'eventType': 'SPAWN',
        'timestamp': timestamp,
        'latitude': 40.7128,
        'longitude': -74.0060,
        'altitude': 10.0,
        'azimuth': null,
        'speed': null,
        'accuracy': null,
      };

      final event = GameEvent.fromJson(json);

      expect(event.id, isNull);
      expect(event.azimuth, isNull);
      expect(event.speed, isNull);
      expect(event.accuracy, isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:airsoft_telemetry_flutter/models/game_event.dart';

class MockDatabase extends Mock implements Database {}

// Create a testable version of DatabaseService that can be injected with a mock database
class TestableDatabaseService {
  final Database _database;
  
  TestableDatabaseService(this._database);
  
  Future<Database> get database async => _database;

  // Copy all the methods from DatabaseService for testing
  Future<int> insertEvent(GameEvent event) async {
    final db = await database;
    return await db.insert('game_events', {
      'gameSessionId': event.gameSessionId,
      'playerId': event.playerId,
      'eventType': event.eventType,
      'timestamp': event.timestamp,
      'latitude': event.latitude,
      'longitude': event.longitude,
      'altitude': event.altitude,
      'azimuth': event.azimuth,
      'speed': event.speed,
      'accuracy': event.accuracy,
    });
  }

  Future<List<GameEvent>> getAllEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'game_events',
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) {
      return GameEvent(
        id: maps[i]['id'],
        gameSessionId: maps[i]['gameSessionId'],
        playerId: maps[i]['playerId'],
        eventType: maps[i]['eventType'],
        timestamp: maps[i]['timestamp'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
        altitude: maps[i]['altitude'],
        azimuth: maps[i]['azimuth'],
        speed: maps[i]['speed'],
        accuracy: maps[i]['accuracy'],
      );
    });
  }

  Future<List<GameEvent>> getEventsBySession(String sessionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'game_events',
      where: 'gameSessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) {
      return GameEvent(
        id: maps[i]['id'],
        gameSessionId: maps[i]['gameSessionId'],
        playerId: maps[i]['playerId'],
        eventType: maps[i]['eventType'],
        timestamp: maps[i]['timestamp'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
        altitude: maps[i]['altitude'],
        azimuth: maps[i]['azimuth'],
        speed: maps[i]['speed'],
        accuracy: maps[i]['accuracy'],
      );
    });
  }

  Future<List<GameEvent>> getRecentEvents({int limit = 50}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'game_events',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) {
      return GameEvent(
        id: maps[i]['id'],
        gameSessionId: maps[i]['gameSessionId'],
        playerId: maps[i]['playerId'],
        eventType: maps[i]['eventType'],
        timestamp: maps[i]['timestamp'],
        latitude: maps[i]['latitude'],
        longitude: maps[i]['longitude'],
        altitude: maps[i]['altitude'],
        azimuth: maps[i]['azimuth'],
        speed: maps[i]['speed'],
        accuracy: maps[i]['accuracy'],
      );
    });
  }

  Future<int> clearAllEvents() async {
    final db = await database;
    return await db.delete('game_events');
  }

  Future<int> clearEventsBySession(String sessionId) async {
    final db = await database;
    return await db.delete(
      'game_events',
      where: 'gameSessionId = ?',
      whereArgs: [sessionId],
    );
  }

  Future<int> getEventCount() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('SELECT COUNT(*) FROM game_events');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

void main() {
  late TestableDatabaseService databaseService;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabase = MockDatabase();
    databaseService = TestableDatabaseService(mockDatabase);
  });

  setUpAll(() {
    // Register fallback values for complex types
    registerFallbackValue(<String, dynamic>{});
  });

  group('DatabaseService Unit Tests', () {
    test('insertEvent calls database insert with correct parameters', () async {
      // Arrange
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final event = GameEvent(
        gameSessionId: 'test_session',
        playerId: 'test_player',
        eventType: 'HIT',
        timestamp: timestamp,
        latitude: 40.7128,
        longitude: -74.0060,
        altitude: 10.0,
        azimuth: 45.0,
        speed: 2.5,
        accuracy: 3.0,
      );

      const expectedId = 123;
      when(() => mockDatabase.insert(any(), any()))
          .thenAnswer((_) async => expectedId);

      // Act
      final result = await databaseService.insertEvent(event);

      // Assert
      expect(result, equals(expectedId));
      verify(() => mockDatabase.insert(
        'game_events',
        {
          'gameSessionId': 'test_session',
          'playerId': 'test_player',
          'eventType': 'HIT',
          'timestamp': timestamp,
          'latitude': 40.7128,
          'longitude': -74.0060,
          'altitude': 10.0,
          'azimuth': 45.0,
          'speed': 2.5,
          'accuracy': 3.0,
        },
      )).called(1);
    });

    test('insertEvent handles null optional fields correctly', () async {
      // Arrange
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final event = GameEvent(
        gameSessionId: 'test_session',
        playerId: 'test_player',
        eventType: 'HIT',
        timestamp: timestamp,
        latitude: 40.7128,
        longitude: -74.0060,
        altitude: 10.0,
        azimuth: null,
        speed: null,
        accuracy: null,
      );

      const expectedId = 456;
      when(() => mockDatabase.insert(any(), any()))
          .thenAnswer((_) async => expectedId);

      // Act
      final result = await databaseService.insertEvent(event);

      // Assert
      expect(result, equals(expectedId));
      verify(() => mockDatabase.insert(
        'game_events',
        {
          'gameSessionId': 'test_session',
          'playerId': 'test_player',
          'eventType': 'HIT',
          'timestamp': timestamp,
          'latitude': 40.7128,
          'longitude': -74.0060,
          'altitude': 10.0,
          'azimuth': null,
          'speed': null,
          'accuracy': null,
        },
      )).called(1);
    });

    test('getAllEvents calls database query with correct parameters', () async {
      // Arrange
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final mockData = [
        {
          'id': 1,
          'gameSessionId': 'session_1',
          'playerId': 'player_1',
          'eventType': 'HIT',
          'timestamp': timestamp,
          'latitude': 40.7128,
          'longitude': -74.0060,
          'altitude': 10.0,
          'azimuth': 45.0,
          'speed': 2.5,
          'accuracy': 3.0,
        },
        {
          'id': 2,
          'gameSessionId': 'session_2',
          'playerId': 'player_2',
          'eventType': 'KILL',
          'timestamp': timestamp + 1000,
          'latitude': 41.7128,
          'longitude': -75.0060,
          'altitude': 0.0,
          'azimuth': null,
          'speed': null,
          'accuracy': null,
        },
      ];

      when(() => mockDatabase.query(
        any(),
        orderBy: any(named: 'orderBy'),
      )).thenAnswer((_) async => mockData);

      // Act
      final result = await databaseService.getAllEvents();

      // Assert
      expect(result.length, equals(2));
      expect(result[0].id, equals(1));
      expect(result[0].gameSessionId, equals('session_1'));
      expect(result[0].eventType, equals('HIT'));
      expect(result[1].id, equals(2));
      expect(result[1].gameSessionId, equals('session_2'));
      expect(result[1].eventType, equals('KILL'));
      expect(result[1].azimuth, isNull);

      verify(() => mockDatabase.query(
        'game_events',
        orderBy: 'timestamp DESC',
      )).called(1);
    });

    test('getEventsBySession calls database query with session filter', () async {
      // Arrange
      const sessionId = 'test_session_123';
      final mockData = [
        {
          'id': 1,
          'gameSessionId': sessionId,
          'playerId': 'player_1',
          'eventType': 'HIT',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'latitude': 40.7128,
          'longitude': -74.0060,
          'altitude': 10.0,
          'azimuth': 45.0,
          'speed': 2.5,
          'accuracy': 3.0,
        },
      ];

      when(() => mockDatabase.query(
        any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'),
        orderBy: any(named: 'orderBy'),
      )).thenAnswer((_) async => mockData);

      // Act
      final result = await databaseService.getEventsBySession(sessionId);

      // Assert
      expect(result.length, equals(1));
      expect(result[0].gameSessionId, equals(sessionId));

      verify(() => mockDatabase.query(
        'game_events',
        where: 'gameSessionId = ?',
        whereArgs: [sessionId],
        orderBy: 'timestamp DESC',
      )).called(1);
    });

    test('getRecentEvents calls database query with limit', () async {
      // Arrange
      const limit = 5;
      final mockData = List.generate(
        limit,
        (index) => {
          'id': index + 1,
          'gameSessionId': 'session_$index',
          'playerId': 'player_$index',
          'eventType': 'EVENT_$index',
          'timestamp': DateTime.now().millisecondsSinceEpoch + index * 1000,
          'latitude': 40.0 + index,
          'longitude': -74.0 - index,
          'altitude': 0.0,
          'azimuth': null,
          'speed': null,
          'accuracy': null,
        },
      );

      when(() => mockDatabase.query(
        any(),
        orderBy: any(named: 'orderBy'),
        limit: any(named: 'limit'),
      )).thenAnswer((_) async => mockData);

      // Act
      final result = await databaseService.getRecentEvents(limit: limit);

      // Assert
      expect(result.length, equals(limit));

      verify(() => mockDatabase.query(
        'game_events',
        orderBy: 'timestamp DESC',
        limit: limit,
      )).called(1);
    });

    test('getRecentEvents uses default limit when not specified', () async {
      // Arrange
      when(() => mockDatabase.query(
        any(),
        orderBy: any(named: 'orderBy'),
        limit: any(named: 'limit'),
      )).thenAnswer((_) async => []);

      // Act
      await databaseService.getRecentEvents();

      // Assert
      verify(() => mockDatabase.query(
        'game_events',
        orderBy: 'timestamp DESC',
        limit: 50, // Default limit
      )).called(1);
    });

    test('clearAllEvents calls database delete without conditions', () async {
      // Arrange
      const deletedCount = 10;
      when(() => mockDatabase.delete(any()))
          .thenAnswer((_) async => deletedCount);

      // Act
      final result = await databaseService.clearAllEvents();

      // Assert
      expect(result, equals(deletedCount));
      verify(() => mockDatabase.delete('game_events')).called(1);
    });

    test('clearEventsBySession calls database delete with session filter', () async {
      // Arrange
      const sessionId = 'session_to_delete';
      const deletedCount = 5;
      when(() => mockDatabase.delete(
        any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'),
      )).thenAnswer((_) async => deletedCount);

      // Act
      final result = await databaseService.clearEventsBySession(sessionId);

      // Assert
      expect(result, equals(deletedCount));
      verify(() => mockDatabase.delete(
        'game_events',
        where: 'gameSessionId = ?',
        whereArgs: [sessionId],
      )).called(1);
    });

    test('getEventCount calls database rawQuery and returns count', () async {
      // Arrange
      const expectedCount = 42;
      when(() => mockDatabase.rawQuery(any()))
          .thenAnswer((_) async => [{'COUNT(*)': expectedCount}]);

      // Act
      final result = await databaseService.getEventCount();

      // Assert
      expect(result, equals(expectedCount));
      verify(() => mockDatabase.rawQuery('SELECT COUNT(*) FROM game_events'))
          .called(1);
    });

    test('getEventCount returns 0 when database returns null', () async {
      // Arrange
      when(() => mockDatabase.rawQuery(any()))
          .thenAnswer((_) async => [{'COUNT(*)': null}]);

      // Act
      final result = await databaseService.getEventCount();

      // Assert
      expect(result, equals(0));
    });

    test('close calls database close', () async {
      // Arrange
      when(() => mockDatabase.close()).thenAnswer((_) async {});

      // Act
      await databaseService.close();

      // Assert
      verify(() => mockDatabase.close()).called(1);
    });
  });
}

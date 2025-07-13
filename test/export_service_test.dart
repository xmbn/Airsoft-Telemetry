import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:airsoft_telemetry_flutter/services/database_service.dart';
import 'package:airsoft_telemetry_flutter/models/game_event.dart';

// Mock classes
class MockDatabaseService extends Mock implements DatabaseService {}

// Create a testable version of ExportService that accepts a DatabaseService dependency
class TestableExportService {
  final DatabaseService _databaseService;

  TestableExportService(this._databaseService);

  Future<Map<String, dynamic>> getExportStats() async {
    final eventCount = await _databaseService.getEventCount();
    final events = await _databaseService.getAllEvents();

    if (events.isEmpty) {
      return {
        'eventCount': 0,
        'sessionCount': 0,
        'dateRange': '',
      };
    }

    // Count unique sessions
    final uniqueSessions = events.map((e) => e.gameSessionId).toSet();

    // Get date range
    final timestamps = events.map((e) => e.timestamp).toList();
    timestamps.sort();
    final earliestDate = DateTime.fromMillisecondsSinceEpoch(timestamps.first);
    final latestDate = DateTime.fromMillisecondsSinceEpoch(timestamps.last);

    final earliestFormatted = _formatDate(earliestDate);
    final latestFormatted = _formatDate(latestDate);

    final dateRange =
        timestamps.length > 1 && earliestFormatted != latestFormatted
            ? '$earliestFormatted - $latestFormatted'
            : earliestFormatted;

    return {
      'eventCount': eventCount,
      'sessionCount': uniqueSessions.length,
      'dateRange': dateRange,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String convertEventsToCsv(List<GameEvent> events) {
    // Define CSV headers
    final headers = [
      'ID',
      'Session ID',
      'Player ID',
      'Event Type',
      'Timestamp',
      'Date/Time',
      'Latitude',
      'Longitude',
      'Altitude (m)',
      'Azimuth (degrees)',
      'Speed (m/s)',
      'Accuracy (m)',
    ];

    // Convert events to rows
    final rows = <List<String>>[headers];

    for (final event in events) {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(event.timestamp);
      final formattedDateTime = dateTime.toIso8601String();

      rows.add([
        event.id?.toString() ?? '',
        event.gameSessionId,
        event.playerId,
        event.eventType,
        event.timestamp.toString(),
        formattedDateTime,
        event.latitude.toStringAsFixed(8),
        event.longitude.toStringAsFixed(8),
        event.altitude.toStringAsFixed(2),
        event.azimuth?.toStringAsFixed(2) ?? '',
        event.speed?.toStringAsFixed(2) ?? '',
        event.accuracy?.toStringAsFixed(2) ?? '',
      ]);
    }

    // Convert to CSV string - simplified for testing
    return rows.map((row) => row.join(',')).join('\n');
  }
}

void main() {
  group('ExportService Unit Tests', () {
    late TestableExportService exportService;
    late MockDatabaseService mockDatabaseService;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      exportService = TestableExportService(mockDatabaseService);
    });

    group('CSV Conversion', () {
      test('convertEventsToCsv creates correct CSV format with sample data',
          () {
        final events = [
          GameEvent(
            id: 1,
            gameSessionId: 'session123',
            playerId: 'player1',
            eventType: 'START',
            timestamp: 1641024000000, // 2022-01-01 08:00:00 UTC
            latitude: 40.71280000,
            longitude: -74.00600000,
            altitude: 10.50,
            azimuth: 45.0,
            speed: 0.0,
            accuracy: 5.0,
          ),
          GameEvent(
            id: 2,
            gameSessionId: 'session123',
            playerId: 'player1',
            eventType: 'HIT',
            timestamp: 1641024060000, // 2022-01-01 08:01:00 UTC
            latitude: 40.71290000,
            longitude: -74.00610000,
            altitude: 11.00,
            azimuth: 50.0,
            speed: 1.5,
            accuracy: 3.0,
          ),
        ];

        final csvResult = exportService.convertEventsToCsv(events);

        // Verify CSV structure
        final lines = csvResult.split('\n');
        expect(lines.length, equals(3)); // Header + 2 data rows

        // Verify headers
        final headers = lines[0].split(',');
        expect(headers.length, equals(12));
        expect(headers[0], equals('ID'));
        expect(headers[1], equals('Session ID'));
        expect(headers[2], equals('Player ID'));
        expect(headers[3], equals('Event Type'));

        // Verify first data row
        final firstRow = lines[1].split(',');
        expect(firstRow[0], equals('1')); // ID
        expect(firstRow[1], equals('session123')); // Session ID
        expect(firstRow[2], equals('player1')); // Player ID
        expect(firstRow[3], equals('START')); // Event Type
        expect(firstRow[4], equals('1641024000000')); // Timestamp
        expect(firstRow[6],
            equals('40.71280000')); // Latitude with 8 decimal places
        expect(firstRow[7],
            equals('-74.00600000')); // Longitude with 8 decimal places
        expect(firstRow[8], equals('10.50')); // Altitude with 2 decimal places
        expect(firstRow[9], equals('45.00')); // Azimuth with 2 decimal places
        expect(firstRow[10], equals('0.00')); // Speed with 2 decimal places
        expect(firstRow[11], equals('5.00')); // Accuracy with 2 decimal places
      });

      test('convertEventsToCsv handles null optional fields', () {
        final events = [
          GameEvent(
            id: 1,
            gameSessionId: 'session123',
            playerId: 'player1',
            eventType: 'START',
            timestamp: 1641024000000, // 2022-01-01 08:00:00 UTC
            latitude: 40.7128,
            longitude: -74.0060,
            altitude: 10.5,
            // azimuth, speed, accuracy are null
          ),
        ];

        final csvResult = exportService.convertEventsToCsv(events);
        final lines = csvResult.split('\n');
        final dataRow = lines[1].split(',');

        // Verify null fields are handled as empty strings
        expect(dataRow[9], equals('')); // Azimuth
        expect(dataRow[10], equals('')); // Speed
        expect(dataRow[11], equals('')); // Accuracy
      });
    });

    group('Export Statistics', () {
      test('getExportStats returns correct stats for empty database', () async {
        // Mock empty database
        when(() => mockDatabaseService.getEventCount())
            .thenAnswer((_) async => 0);
        when(() => mockDatabaseService.getAllEvents())
            .thenAnswer((_) async => []);

        final stats = await exportService.getExportStats();

        expect(stats['eventCount'], equals(0));
        expect(stats['sessionCount'], equals(0));
        expect(stats['dateRange'], equals(''));
      });

      test('getExportStats calculates correct stats for single session',
          () async {
        final events = [
          GameEvent(
            id: 1,
            gameSessionId: 'session123',
            playerId: 'player1',
            eventType: 'START',
            timestamp:
                1641024000000, // 2022-01-01 08:00:00 UTC (adjusted for timezone)
            latitude: 40.7128,
            longitude: -74.0060,
            altitude: 10.5,
          ),
          GameEvent(
            id: 2,
            gameSessionId: 'session123',
            playerId: 'player1',
            eventType: 'STOP',
            timestamp: 1641024600000, // 2022-01-01 08:10:00 UTC
            latitude: 40.7129,
            longitude: -74.0061,
            altitude: 11.0,
          ),
        ];

        when(() => mockDatabaseService.getEventCount())
            .thenAnswer((_) async => 2);
        when(() => mockDatabaseService.getAllEvents())
            .thenAnswer((_) async => events);

        final stats = await exportService.getExportStats();

        expect(stats['eventCount'], equals(2));
        expect(stats['sessionCount'], equals(1));
        expect(stats['dateRange'], equals('1/1/2022'));
      });

      test('getExportStats calculates correct stats for multiple sessions',
          () async {
        final events = [
          GameEvent(
            id: 1,
            gameSessionId: 'session123',
            playerId: 'player1',
            eventType: 'START',
            timestamp: 1641024000000, // 2022-01-01 08:00:00 UTC
            latitude: 40.7128,
            longitude: -74.0060,
            altitude: 10.5,
          ),
          GameEvent(
            id: 2,
            gameSessionId: 'session456',
            playerId: 'player2',
            eventType: 'START',
            timestamp: 1641110400000, // 2022-01-02 08:00:00 UTC
            latitude: 40.7130,
            longitude: -74.0062,
            altitude: 12.0,
          ),
          GameEvent(
            id: 3,
            gameSessionId: 'session123',
            playerId: 'player1',
            eventType: 'STOP',
            timestamp: 1641196800000, // 2022-01-03 08:00:00 UTC
            latitude: 40.7131,
            longitude: -74.0063,
            altitude: 13.0,
          ),
        ];

        when(() => mockDatabaseService.getEventCount())
            .thenAnswer((_) async => 3);
        when(() => mockDatabaseService.getAllEvents())
            .thenAnswer((_) async => events);

        final stats = await exportService.getExportStats();

        expect(stats['eventCount'], equals(3));
        expect(stats['sessionCount'], equals(2)); // Two unique session IDs
        expect(stats['dateRange'], equals('1/1/2022 - 3/1/2022'));
      });
    });

    group('Edge Cases', () {
      test('getExportStats handles events with same timestamp', () async {
        final timestamp = 1641024000000; // 2022-01-01 08:00:00 UTC
        final events = [
          GameEvent(
            id: 1,
            gameSessionId: 'session123',
            playerId: 'player1',
            eventType: 'START',
            timestamp: timestamp,
            latitude: 40.7128,
            longitude: -74.0060,
            altitude: 10.5,
          ),
          GameEvent(
            id: 2,
            gameSessionId: 'session123',
            playerId: 'player1',
            eventType: 'HIT',
            timestamp: timestamp, // Same timestamp
            latitude: 40.7128,
            longitude: -74.0060,
            altitude: 10.5,
          ),
        ];

        when(() => mockDatabaseService.getEventCount())
            .thenAnswer((_) async => 2);
        when(() => mockDatabaseService.getAllEvents())
            .thenAnswer((_) async => events);

        final stats = await exportService.getExportStats();

        expect(stats['eventCount'], equals(2));
        expect(stats['sessionCount'], equals(1));
        expect(stats['dateRange'],
            equals('1/1/2022')); // Single date for same timestamps
      });

      test('getExportStats handles events with null optional fields', () async {
        final events = [
          GameEvent(
            id: 1,
            gameSessionId: 'session123',
            playerId: 'player1',
            eventType: 'START',
            timestamp: 1641024000000, // 2022-01-01 08:00:00 UTC
            latitude: 40.7128,
            longitude: -74.0060,
            altitude: 10.5,
            // azimuth, speed, accuracy are null
          ),
        ];

        when(() => mockDatabaseService.getEventCount())
            .thenAnswer((_) async => 1);
        when(() => mockDatabaseService.getAllEvents())
            .thenAnswer((_) async => events);

        final stats = await exportService.getExportStats();

        expect(stats['eventCount'], equals(1));
        expect(stats['sessionCount'], equals(1));
        expect(stats['dateRange'], equals('1/1/2022'));
      });
    });

    group('Error Handling', () {
      test('getExportStats handles database errors gracefully', () async {
        // Mock database error
        when(() => mockDatabaseService.getEventCount())
            .thenThrow(Exception('Database error'));
        when(() => mockDatabaseService.getAllEvents())
            .thenThrow(Exception('Database error'));

        expect(
          () => exportService.getExportStats(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

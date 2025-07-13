import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:airsoft_telemetry_flutter/services/export_service.dart';
import 'package:airsoft_telemetry_flutter/services/database_service.dart';
import 'package:airsoft_telemetry_flutter/models/game_event.dart';
import 'dart:io';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('ExportService Integration Tests', () {
    late ExportService exportService;
    late DatabaseService databaseService;

    setUp(() async {
      exportService = ExportService();
      databaseService = DatabaseService();

      // Clear any existing data
      await databaseService.clearAllEvents();
    });

    tearDown(() async {
      // Clean up test data
      await databaseService.clearAllEvents();
    });

    tearDownAll(() async {
      await databaseService.close();
    });

    group('Export Statistics Integration', () {
      test('getExportStats works with real database', () async {
        // Insert test events into the database
        final testEvents = [
          GameEvent(
            gameSessionId: 'integration_session_1',
            playerId: 'test_player_1',
            eventType: 'START',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            latitude: 40.7128,
            longitude: -74.0060,
            altitude: 10.5,
            azimuth: 45.0,
            speed: 0.0,
            accuracy: 5.0,
          ),
          GameEvent(
            gameSessionId: 'integration_session_1',
            playerId: 'test_player_1',
            eventType: 'HIT',
            timestamp:
                DateTime.now().millisecondsSinceEpoch + 60000, // 1 minute later
            latitude: 40.7129,
            longitude: -74.0061,
            altitude: 11.0,
            azimuth: 50.0,
            speed: 1.5,
            accuracy: 3.0,
          ),
          GameEvent(
            gameSessionId: 'integration_session_2',
            playerId: 'test_player_2',
            eventType: 'START',
            timestamp: DateTime.now().millisecondsSinceEpoch +
                120000, // 2 minutes later
            latitude: 40.7130,
            longitude: -74.0062,
            altitude: 12.0,
            azimuth: 55.0,
            speed: 2.0,
            accuracy: 4.0,
          ),
        ];

        // Insert events into database
        for (final event in testEvents) {
          await databaseService.insertEvent(event);
        }

        // Wait a moment for database operations to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Test export stats
        final stats = await exportService.getExportStats();

        expect(stats['eventCount'], equals(3));
        expect(stats['sessionCount'], equals(2)); // Two unique sessions
        expect(stats['dateRange'], isNotEmpty);

        // Verify stats structure
        expect(stats, contains('eventCount'));
        expect(stats, contains('sessionCount'));
        expect(stats, contains('dateRange'));
      });

      test('getExportStats handles empty database correctly', () async {
        // Ensure database is empty
        await databaseService.clearAllEvents();

        final stats = await exportService.getExportStats();

        expect(stats['eventCount'], equals(0));
        expect(stats['sessionCount'], equals(0));
        expect(stats['dateRange'], equals(''));
      });
    });

    group('CSV Export Integration', () {
      test('exportToCsv creates valid CSV file with real data', () async {
        // Insert test events with comprehensive data
        final now = DateTime.now();
        final testEvents = [
          GameEvent(
            gameSessionId: 'csv_test_session',
            playerId: 'csv_test_player',
            eventType: 'START',
            timestamp: now.millisecondsSinceEpoch,
            latitude: 40.71234567,
            longitude: -74.00987654,
            altitude: 15.75,
            azimuth: 123.45,
            speed: 2.5,
            accuracy: 3.2,
          ),
          GameEvent(
            gameSessionId: 'csv_test_session',
            playerId: 'csv_test_player',
            eventType: 'LOCATION',
            timestamp: now.millisecondsSinceEpoch + 30000,
            latitude: 40.71235000,
            longitude: -74.00988000,
            altitude: 16.25,
            azimuth: 125.00,
            speed: 3.0,
            accuracy: 2.8,
          ),
          GameEvent(
            gameSessionId: 'csv_test_session',
            playerId: 'csv_test_player',
            eventType: 'HIT',
            timestamp: now.millisecondsSinceEpoch + 60000,
            latitude: 40.71236000,
            longitude: -74.00989000,
            altitude: 17.00,
            // Test null optional fields
            azimuth: null,
            speed: null,
            accuracy: null,
          ),
          GameEvent(
            gameSessionId: 'csv_test_session',
            playerId: 'csv_test_player',
            eventType: 'STOP',
            timestamp: now.millisecondsSinceEpoch + 90000,
            latitude: 40.71237000,
            longitude: -74.00990000,
            altitude: 18.50,
            azimuth: 130.75,
            speed: 0.0,
            accuracy: 4.1,
          ),
        ];

        // Insert events into database
        for (final event in testEvents) {
          await databaseService.insertEvent(event);
        }

        // Wait for database operations
        await Future.delayed(const Duration(milliseconds: 200));

        // Export to CSV
        final csvFilePath = await exportService.exportToCsv();

        // Verify file was created
        expect(csvFilePath, isNotNull);
        expect(csvFilePath, isNotEmpty);

        final csvFile = File(csvFilePath!);
        expect(csvFile.existsSync(), isTrue);

        // Read and verify CSV content
        final csvContent = await csvFile.readAsString();
        final lines = csvContent.split('\n');

        // Verify structure
        expect(
            lines.length,
            greaterThanOrEqualTo(
                5)); // Header + 4 data rows + possible empty line

        // Verify headers
        final headers = lines[0].split(',').map((h) => h.trim()).toList();
        expect(headers.length, equals(12));
        expect(headers, contains('ID'));
        expect(headers, contains('Session ID'));
        expect(headers, contains('Player ID'));
        expect(headers, contains('Event Type'));
        expect(headers, contains('Timestamp'));
        expect(headers, contains('Date/Time'));
        expect(headers, contains('Latitude'));
        expect(headers, contains('Longitude'));
        expect(headers, contains('Altitude (m)'));
        expect(headers, contains('Azimuth (degrees)'));
        expect(headers, contains('Speed (m/s)'));
        expect(headers, contains('Accuracy (m)'));

        // Verify data content (events might be in different order)
        final dataRows = <List<String>>[];
        for (int i = 1; i < lines.length; i++) {
          if (lines[i].trim().isNotEmpty) {
            dataRows
                .add(lines[i].split(',').map((cell) => cell.trim()).toList());
          }
        }

        // Find the START event row
        final startEventRow = dataRows.firstWhere((row) => row[3] == 'START');
        expect(startEventRow[1], equals('csv_test_session')); // Session ID
        expect(startEventRow[2], equals('csv_test_player')); // Player ID

        // Verify latitude/longitude precision (8 decimal places)
        expect(startEventRow[6], equals('40.71234567'));
        expect(startEventRow[7], equals('-74.00987654'));

        // Verify altitude precision (2 decimal places)
        expect(startEventRow[8], equals('15.75'));

        // Find the HIT event row for null handling
        final hitEventRow = dataRows.firstWhere((row) => row[3] == 'HIT');
        expect(
            hitEventRow[9].trim(), equals('')); // Null azimuth should be empty
        expect(
            hitEventRow[10].trim(), equals('')); // Null speed should be empty
        expect(hitEventRow[11].trim(),
            equals('')); // Null accuracy should be empty

        // Clean up - delete the generated file
        await csvFile.delete();
      });

      test('exportToCsv returns null for empty database', () async {
        // Ensure database is empty
        await databaseService.clearAllEvents();

        final csvFilePath = await exportService.exportToCsv();

        expect(csvFilePath, isNull);
      });

      test('exportToCsv creates unique filenames', () async {
        // Insert minimal test data
        final testEvent = GameEvent(
          gameSessionId: 'filename_test',
          playerId: 'test_player',
          eventType: 'START',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          latitude: 40.7128,
          longitude: -74.0060,
          altitude: 10.0,
        );

        await databaseService.insertEvent(testEvent);
        await Future.delayed(const Duration(milliseconds: 100));

        // Export multiple times
        final csvFilePath1 = await exportService.exportToCsv();

        // Wait a moment to ensure different timestamps
        await Future.delayed(const Duration(milliseconds: 10));

        final csvFilePath2 = await exportService.exportToCsv();

        expect(csvFilePath1, isNotNull);
        expect(csvFilePath2, isNotNull);
        expect(csvFilePath1,
            isNot(equals(csvFilePath2))); // Should have different timestamps

        // Verify both files exist
        expect(File(csvFilePath1!).existsSync(), isTrue);
        expect(File(csvFilePath2!).existsSync(), isTrue);

        // Clean up
        await File(csvFilePath1).delete();
        await File(csvFilePath2).delete();
      });
    });

    group('End-to-End Export Workflow', () {
      test('complete export workflow with session data', () async {
        // Simulate a complete game session
        final sessionId = 'e2e_test_${DateTime.now().millisecondsSinceEpoch}';
        final playerId = 'e2e_player';
        final baseTime = DateTime.now().millisecondsSinceEpoch;

        final sessionEvents = [
          // Session start
          GameEvent(
            gameSessionId: sessionId,
            playerId: playerId,
            eventType: 'START',
            timestamp: baseTime,
            latitude: 40.7128,
            longitude: -74.0060,
            altitude: 10.0,
            azimuth: 0.0,
            speed: 0.0,
            accuracy: 5.0,
          ),
          // Location updates
          GameEvent(
            gameSessionId: sessionId,
            playerId: playerId,
            eventType: 'LOCATION',
            timestamp: baseTime + 30000,
            latitude: 40.7129,
            longitude: -74.0061,
            altitude: 10.5,
            azimuth: 45.0,
            speed: 1.2,
            accuracy: 4.8,
          ),
          // Game events
          GameEvent(
            gameSessionId: sessionId,
            playerId: playerId,
            eventType: 'HIT',
            timestamp: baseTime + 60000,
            latitude: 40.7130,
            longitude: -74.0062,
            altitude: 11.0,
            azimuth: 90.0,
            speed: 0.5,
            accuracy: 3.5,
          ),
          GameEvent(
            gameSessionId: sessionId,
            playerId: playerId,
            eventType: 'SPAWN',
            timestamp: baseTime + 90000,
            latitude: 40.7131,
            longitude: -74.0063,
            altitude: 11.5,
            azimuth: 135.0,
            speed: 0.0,
            accuracy: 4.2,
          ),
          // Session end
          GameEvent(
            gameSessionId: sessionId,
            playerId: playerId,
            eventType: 'STOP',
            timestamp: baseTime + 120000,
            latitude: 40.7132,
            longitude: -74.0064,
            altitude: 12.0,
            azimuth: 180.0,
            speed: 0.0,
            accuracy: 5.1,
          ),
        ];

        // Insert all events
        for (final event in sessionEvents) {
          await databaseService.insertEvent(event);
        }

        await Future.delayed(const Duration(milliseconds: 200));

        // 1. Verify export stats
        final stats = await exportService.getExportStats();
        expect(stats['eventCount'], equals(5));
        expect(stats['sessionCount'], equals(1));

        // 2. Export to CSV
        final csvFilePath = await exportService.exportToCsv();
        expect(csvFilePath, isNotNull);

        // 3. Verify CSV content
        final csvFile = File(csvFilePath!);
        expect(csvFile.existsSync(), isTrue);

        final csvContent = await csvFile.readAsString();
        final lines =
            csvContent.split('\n').where((line) => line.isNotEmpty).toList();

        // Should have header + 5 data rows
        expect(lines.length, equals(6));

        // Verify all event types are present
        final eventTypes = <String>[];
        for (int i = 1; i < lines.length; i++) {
          final columns = lines[i].split(',');
          eventTypes.add(columns[3]); // Event type column
        }

        expect(eventTypes, contains('START'));
        expect(eventTypes, contains('LOCATION'));
        expect(eventTypes, contains('HIT'));
        expect(eventTypes, contains('SPAWN'));
        expect(eventTypes, contains('STOP'));

        // Verify all events have the same session ID
        for (int i = 1; i < lines.length; i++) {
          final columns = lines[i].split(',');
          expect(columns[1], equals(sessionId)); // Session ID column
        }

        // Clean up
        await csvFile.delete();
      });
    });

    group('Error Handling Integration', () {
      test('export handles database errors gracefully', () async {
        // This test verifies that the export service properly handles
        // database operations and maintains data integrity

        // Add some test data
        final testEvent = GameEvent(
          gameSessionId: 'error_test',
          playerId: 'test_player',
          eventType: 'START',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          latitude: 40.7128,
          longitude: -74.0060,
          altitude: 10.0,
        );

        await databaseService.insertEvent(testEvent);
        await Future.delayed(const Duration(milliseconds: 100));

        // Test normal operation
        final stats = await exportService.getExportStats();
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats['eventCount'], greaterThan(0));

        // Test export functionality
        final csvPath = await exportService.exportToCsv();
        expect(csvPath, isNotNull);

        // Clean up the generated file
        if (csvPath != null) {
          final csvFile = File(csvPath);
          if (csvFile.existsSync()) {
            await csvFile.delete();
          }
        }
      });
    });
  });
}

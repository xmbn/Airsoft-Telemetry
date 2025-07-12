import 'package:airsoft_telemetry_flutter/utils/location_formatter.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:airsoft_telemetry_flutter/models/game_event.dart';
import 'package:airsoft_telemetry_flutter/services/database_service.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  final DatabaseService _databaseService = DatabaseService();

  Future<String?> exportToCsv() async {
    try {
      // Get all events from database
      final events = await _databaseService.getAllEvents();
      
      if (events.isEmpty) {
        return null; // No data to export
      }

      // Convert events to CSV format
      final csvData = _convertEventsToCsv(events);
      
      // Get the downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      // Create filename with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final filename = 'airsoft_telemetry_$timestamp.csv';
      final filePath = '${directory.path}/$filename';

      // Write CSV data to file
      final file = File(filePath);
      await file.writeAsString(csvData);

      return filePath;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  String _convertEventsToCsv(List<GameEvent> events) {
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
        LocationFormatter.formatLatitude(event.latitude),
        LocationFormatter.formatLongitude(event.longitude),
        event.altitude.toStringAsFixed(2),
        event.azimuth?.toStringAsFixed(2) ?? '',
        event.speed?.toStringAsFixed(2) ?? '',
        event.accuracy?.toStringAsFixed(2) ?? '',
      ]);
    }

    // Convert to CSV string
    return const ListToCsvConverter().convert(rows);
  }

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
    
    final dateRange = timestamps.length > 1 
        ? '${_formatDate(earliestDate)} - ${_formatDate(latestDate)}'
        : _formatDate(earliestDate);

    return {
      'eventCount': eventCount,
      'sessionCount': uniqueSessions.length,
      'dateRange': dateRange,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:airsoft_telemetry_flutter/models/game_event.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'airsoft_telemetry.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE game_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gameSessionId TEXT NOT NULL,
        playerId TEXT NOT NULL,
        eventType TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        altitude REAL,
        azimuth REAL,
        speed REAL,
        accuracy REAL
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_session_timestamp ON game_events(gameSessionId, timestamp)
    ''');
  }

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

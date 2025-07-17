import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:airsoft_telemetry_flutter/models/game_event.dart';
import 'package:airsoft_telemetry_flutter/services/database_service.dart';
import 'package:airsoft_telemetry_flutter/services/location_service.dart';
import 'package:airsoft_telemetry_flutter/services/preferences_service.dart';
import 'package:airsoft_telemetry_flutter/services/app_config.dart';

enum SessionState { stopped, running, paused }

class TelemetryService {
  static final TelemetryService _instance = TelemetryService._internal();
  factory TelemetryService() => _instance;
  TelemetryService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final LocationService _locationService = LocationService();
  final PreferencesService _preferencesService = PreferencesService();

  // Current session state
  SessionState _sessionState = SessionState.stopped;
  String? _currentSessionId;
  Timer? _locationTimer;
  Position? _lastPosition;
  String _currentPlayerId = AppConfig.defaultPlayerName;
  int _intervalSeconds = 2;
  // Stream controllers for reactive updates
  final StreamController<SessionState> _sessionStateController =
      StreamController<SessionState>.broadcast();
  final StreamController<Position?> _positionController =
      StreamController<Position?>.broadcast();
  final StreamController<List<GameEvent>> _recentEventsController =
      StreamController<List<GameEvent>>.broadcast();

  // Cache the last emitted events to provide immediate data to new listeners
  List<GameEvent> _cachedRecentEvents = [];
  // Getters
  SessionState get sessionState => _sessionState;
  String? get currentSessionId => _currentSessionId;
  Position? get lastPosition => _lastPosition;
  String get currentPlayerId => _currentPlayerId;
  List<GameEvent> get cachedRecentEvents =>
      List.unmodifiable(_cachedRecentEvents);
  // Streams
  Stream<SessionState> get sessionStateStream => _sessionStateController.stream;
  Stream<Position?> get positionStream => _positionController.stream;
  Stream<List<GameEvent>> get recentEventsStream {
    // Return a stream that immediately emits cached events, then continues with updates
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
    // Load preferences
    final preferences = await _preferencesService.loadAllPreferences();
    _currentPlayerId = preferences['playerName'] ?? AppConfig.defaultPlayerName;
    final intervalString = preferences['interval'] ?? AppConfig.defaultInterval;
    _intervalSeconds = _preferencesService.getIntervalInSeconds(intervalString);

    // Get initial position
    _lastPosition = await _locationService.getCurrentPosition();
    _positionController.add(_lastPosition);

    // Load recent events
    await _updateRecentEvents();
  }

  Future<void> startSession() async {
    if (_sessionState != SessionState.stopped) return;

    // Generate new session ID
    _currentSessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    _sessionState = SessionState.running;
    _sessionStateController.add(_sessionState);

    // Get current position for start event
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      _lastPosition = position;
      _positionController.add(_lastPosition);

      // Record START event
      await _recordEvent('START', position);
    }

    // Start periodic location tracking
    _startLocationTracking();
  }

  Future<void> pauseSession() async {
    if (_sessionState != SessionState.running) return;

    _sessionState = SessionState.paused;
    _sessionStateController.add(_sessionState);

    // Stop location tracking
    _stopLocationTracking();

    // Record PAUSE event
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      await _recordEvent('PAUSE', position);
    }
  }

  Future<void> resumeSession() async {
    if (_sessionState != SessionState.paused) return;

    _sessionState = SessionState.running;
    _sessionStateController.add(_sessionState);

    // Record RESUME event
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      _lastPosition = position;
      _positionController.add(_lastPosition);
      await _recordEvent('RESUME', position);
    }

    // Restart location tracking
    _startLocationTracking();
  }

  Future<void> stopSession() async {
    if (_sessionState == SessionState.stopped) return;

    // Record STOP event
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      await _recordEvent('STOP', position);
    }

    // Stop location tracking
    _stopLocationTracking();

    // Reset session state
    _sessionState = SessionState.stopped;
    _currentSessionId = null;
    _sessionStateController.add(_sessionState);

    // Update events to show recent events from all sessions
    await _updateRecentEvents();
  }

  Future<void> recordManualEvent(String eventType) async {
    if (_sessionState == SessionState.stopped) {
      // Auto-start session if stopped
      await startSession();
    }

    if (_sessionState == SessionState.paused) {
      // Cannot record events while paused
      return;
    }

    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      _lastPosition = position;
      _positionController.add(_lastPosition);
      await _recordEvent(eventType, position);
    }
  }

  Future<void> _recordEvent(String eventType, Position position) async {
    if (_currentSessionId == null) return;

    final event = GameEvent(
      gameSessionId: _currentSessionId!,
      playerId: _currentPlayerId,
      eventType: eventType,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      azimuth: position.heading.isNaN ? null : position.heading,
      speed: position.speed.isNaN ? null : position.speed,
      accuracy: position.accuracy.isNaN ? null : position.accuracy,
    );

    await _databaseService.insertEvent(event);
    await _updateRecentEvents();
  }

  void _startLocationTracking() {
    _stopLocationTracking(); // Ensure no duplicate timers

    _locationTimer =
        Timer.periodic(Duration(seconds: _intervalSeconds), (timer) async {
      if (_sessionState != SessionState.running) {
        timer.cancel();
        return;
      }

      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        _lastPosition = position;
        _positionController.add(_lastPosition);
        await _recordEvent('LOCATION', position);
      }
    });
  }

  void _stopLocationTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  Future<void> _updateRecentEvents() async {
    List<GameEvent> events;

    if (_currentSessionId != null) {
      // If there's an active session, show only events from the current session
      events = await _databaseService.getEventsBySession(_currentSessionId!);
    } else {
      // If no active session, show recent events from all sessions
      events = await _databaseService.getRecentEvents(limit: 20);
    }

    // Cache the events for immediate emission to new listeners
    _cachedRecentEvents = events;
    _recentEventsController.add(events);
  }

  Future<void> updatePlayerName(String playerName) async {
    _currentPlayerId = playerName;
    await _preferencesService.setPlayerName(playerName);
  }

  Future<void> updateInterval(String intervalString) async {
    _intervalSeconds = _preferencesService.getIntervalInSeconds(intervalString);
    await _preferencesService.setUpdateInterval(intervalString);

    // Restart tracking with new interval if currently running
    if (_sessionState == SessionState.running) {
      _startLocationTracking();
    }
  }

  Future<List<GameEvent>> getAllEvents() async {
    return await _databaseService.getAllEvents();
  }

  Future<int> clearAllData() async {
    final count = await _databaseService.clearAllEvents();
    _cachedRecentEvents.clear();
    await _updateRecentEvents();
    return count;
  }

  void dispose() {
    _stopLocationTracking();
    _locationService.dispose();
    _sessionStateController.close();
    _positionController.close();
    _recentEventsController.close();
  }
}

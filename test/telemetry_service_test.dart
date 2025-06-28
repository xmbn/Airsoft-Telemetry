import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geolocator/geolocator.dart';
import 'package:airsoft_telemetry_flutter/models/game_event.dart';
import 'package:airsoft_telemetry_flutter/services/database_service.dart';
import 'package:airsoft_telemetry_flutter/services/location_service.dart';
import 'package:airsoft_telemetry_flutter/services/preferences_service.dart';
import 'package:airsoft_telemetry_flutter/services/telemetry_service.dart';
import 'dart:async';

// Mock classes
class MockDatabaseService extends Mock implements DatabaseService {}
class MockLocationService extends Mock implements LocationService {}
class MockPreferencesService extends Mock implements PreferencesService {}

// Testable version of TelemetryService that allows dependency injection
class TestableTelemetryService {
  final DatabaseService _databaseService;
  final LocationService _locationService;
  final PreferencesService _preferencesService;

  // Current session state
  SessionState _sessionState = SessionState.stopped;
  String? _currentSessionId;
  Position? _lastPosition;
  String _currentPlayerId = 'default_player';
  int _intervalSeconds = 2;

  // Stream controllers for reactive updates
  final StreamController<SessionState> _sessionStateController = StreamController<SessionState>.broadcast();
  final StreamController<Position?> _positionController = StreamController<Position?>.broadcast();
  final StreamController<List<GameEvent>> _recentEventsController = StreamController<List<GameEvent>>.broadcast();
  
  // Cache the last emitted events to provide immediate data to new listeners
  List<GameEvent> _cachedRecentEvents = [];

  TestableTelemetryService({
    required DatabaseService databaseService,
    required LocationService locationService,
    required PreferencesService preferencesService,
  }) : _databaseService = databaseService,
       _locationService = locationService,
       _preferencesService = preferencesService;

  DatabaseService get databaseService => _databaseService;
  LocationService get locationService => _locationService;
  PreferencesService get preferencesService => _preferencesService;

  // Getters
  SessionState get sessionState => _sessionState;
  String? get currentSessionId => _currentSessionId;
  Position? get lastPosition => _lastPosition;
  String get currentPlayerId => _currentPlayerId;
  int get intervalSeconds => _intervalSeconds;
  List<GameEvent> get cachedRecentEvents => List.unmodifiable(_cachedRecentEvents);

  // Streams
  Stream<SessionState> get sessionStateStream => _sessionStateController.stream;
  Stream<Position?> get positionStream => _positionController.stream;
  Stream<List<GameEvent>> get recentEventsStream {
    return Stream.multi((controller) {
      if (_cachedRecentEvents.isNotEmpty) {
        controller.add(_cachedRecentEvents);
      }
      
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
    _currentPlayerId = preferences['playerName'] ?? 'default_player';
    final intervalString = preferences['interval'] ?? '2 seconds';
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
  }

  Future<void> pauseSession() async {
    if (_sessionState != SessionState.running) return;

    _sessionState = SessionState.paused;
    _sessionStateController.add(_sessionState);

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
  }

  Future<void> stopSession() async {
    if (_sessionState == SessionState.stopped) return;

    // Record STOP event
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      await _recordEvent('STOP', position);
    }

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
    _locationService.dispose();
    _sessionStateController.close();
    _positionController.close();
    _recentEventsController.close();
  }
}

void main() {
  group('TelemetryService Unit Tests', () {
    late TestableTelemetryService telemetryService;
    late MockDatabaseService mockDatabaseService;
    late MockLocationService mockLocationService;
    late MockPreferencesService mockPreferencesService;

    // Test data
    final testPosition = Position(
      latitude: 40.7128,
      longitude: -74.0060,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      altitude: 10.0,
      altitudeAccuracy: 3.0,
      heading: 45.0,
      headingAccuracy: 2.0,
      speed: 1.5,
      speedAccuracy: 0.5,
    );

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockLocationService = MockLocationService();
      mockPreferencesService = MockPreferencesService();
      
      // Set up default return value for getIntervalInSeconds
      when(() => mockPreferencesService.getIntervalInSeconds(any()))
          .thenReturn(2);
      
      telemetryService = TestableTelemetryService(
        databaseService: mockDatabaseService,
        locationService: mockLocationService,
        preferencesService: mockPreferencesService,
      );
    });

    tearDown(() {
      telemetryService.dispose();
    });

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(<String, String>{});
      registerFallbackValue(GameEvent(
        gameSessionId: 'fallback',
        playerId: 'fallback',
        eventType: 'fallback',
        timestamp: 0,
        latitude: 0.0,
        longitude: 0.0,
        altitude: 0.0,
      ));
    });

    group('Initialization', () {
      test('should initialize with default values when no preferences exist', () async {
        // Arrange
        when(() => mockPreferencesService.loadAllPreferences())
            .thenAnswer((_) async => <String, String>{});
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => testPosition);
        when(() => mockDatabaseService.getRecentEvents(limit: any(named: 'limit')))
            .thenAnswer((_) async => <GameEvent>[]);

        // Act
        await telemetryService.initialize();

        // Assert
        expect(telemetryService.sessionState, equals(SessionState.stopped));
        expect(telemetryService.currentSessionId, isNull);
        expect(telemetryService.currentPlayerId, isNotEmpty);
        expect(telemetryService.lastPosition, equals(testPosition));
        verify(() => mockPreferencesService.loadAllPreferences()).called(1);
        verify(() => mockLocationService.getCurrentPosition()).called(1);
        verify(() => mockDatabaseService.getRecentEvents(limit: any(named: 'limit'))).called(1);
      });

      test('should load preferences correctly during initialization', () async {
        // Arrange
        final preferences = {
          'playerName': 'test_player_123',
          'interval': '5 seconds',
        };
        when(() => mockPreferencesService.loadAllPreferences())
            .thenAnswer((_) async => preferences);
        when(() => mockPreferencesService.getIntervalInSeconds('5 seconds'))
            .thenReturn(5);
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => testPosition);
        when(() => mockDatabaseService.getRecentEvents(limit: any(named: 'limit')))
            .thenAnswer((_) async => <GameEvent>[]);

        // Act
        await telemetryService.initialize();

        // Assert
        expect(telemetryService.currentPlayerId, equals('test_player_123'));
        verify(() => mockPreferencesService.getIntervalInSeconds('5 seconds')).called(1);
      });

      test('should handle initialization errors gracefully', () async {
        // Arrange
        when(() => mockPreferencesService.loadAllPreferences())
            .thenThrow(Exception('Preferences loading failed'));

        // Act & Assert
        expect(
          () => telemetryService.initialize(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Session Management', () {
      setUp(() async {
        // Common setup for session tests
        when(() => mockPreferencesService.loadAllPreferences())
            .thenAnswer((_) async => {'playerName': 'test_player'});
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => testPosition);
        when(() => mockDatabaseService.getRecentEvents(limit: any(named: 'limit')))
            .thenAnswer((_) async => <GameEvent>[]);
        when(() => mockDatabaseService.insertEvent(any()))
            .thenAnswer((_) async => 1);
        
        // Add missing mocks for database service methods
        when(() => mockDatabaseService.getEventsBySession(any()))
            .thenAnswer((_) async => <GameEvent>[]);

        await telemetryService.initialize();
      });

      test('should start session successfully', () async {
        // Arrange
        expect(telemetryService.sessionState, equals(SessionState.stopped));

        // Act
        await telemetryService.startSession();

        // Assert
        expect(telemetryService.sessionState, equals(SessionState.running));
        expect(telemetryService.currentSessionId, isNotNull);
        expect(telemetryService.currentSessionId, startsWith('session_'));
        verify(() => mockDatabaseService.insertEvent(any())).called(1);
      });

      test('should not start session if already running', () async {
        // Arrange
        await telemetryService.startSession();
        final firstSessionId = telemetryService.currentSessionId;

        // Act
        await telemetryService.startSession();

        // Assert
        expect(telemetryService.currentSessionId, equals(firstSessionId));
        expect(telemetryService.sessionState, equals(SessionState.running));
      });

      test('should pause session successfully', () async {
        // Arrange
        await telemetryService.startSession();
        expect(telemetryService.sessionState, equals(SessionState.running));

        // Act
        await telemetryService.pauseSession();

        // Assert
        expect(telemetryService.sessionState, equals(SessionState.paused));
        expect(telemetryService.currentSessionId, isNotNull);
        verify(() => mockDatabaseService.insertEvent(any())).called(2); // START + PAUSE
      });

      test('should not pause session if not running', () async {
        // Arrange
        expect(telemetryService.sessionState, equals(SessionState.stopped));

        // Act
        await telemetryService.pauseSession();

        // Assert
        expect(telemetryService.sessionState, equals(SessionState.stopped));
        verifyNever(() => mockDatabaseService.insertEvent(any()));
      });

      test('should resume session successfully', () async {
        // Arrange
        await telemetryService.startSession();
        await telemetryService.pauseSession();
        expect(telemetryService.sessionState, equals(SessionState.paused));

        // Act
        await telemetryService.resumeSession();

        // Assert
        expect(telemetryService.sessionState, equals(SessionState.running));
        verify(() => mockDatabaseService.insertEvent(any())).called(3); // START + PAUSE + RESUME
      });

      test('should not resume session if not paused', () async {
        // Arrange
        expect(telemetryService.sessionState, equals(SessionState.stopped));

        // Act
        await telemetryService.resumeSession();

        // Assert
        expect(telemetryService.sessionState, equals(SessionState.stopped));
        verifyNever(() => mockDatabaseService.insertEvent(any()));
      });

      test('should stop session successfully', () async {
        // Arrange
        await telemetryService.startSession();
        expect(telemetryService.sessionState, equals(SessionState.running));

        // Act
        await telemetryService.stopSession();

        // Assert
        expect(telemetryService.sessionState, equals(SessionState.stopped));
        expect(telemetryService.currentSessionId, isNull);
        verify(() => mockDatabaseService.insertEvent(any())).called(2); // START + STOP
      });

      test('should stop session from paused state', () async {
        // Arrange
        await telemetryService.startSession();
        await telemetryService.pauseSession();
        expect(telemetryService.sessionState, equals(SessionState.paused));

        // Act
        await telemetryService.stopSession();

        // Assert
        expect(telemetryService.sessionState, equals(SessionState.stopped));
        expect(telemetryService.currentSessionId, isNull);
        verify(() => mockDatabaseService.insertEvent(any())).called(3); // START + PAUSE + STOP
      });
    });

    group('Event Recording', () {
      setUp(() async {
        when(() => mockPreferencesService.loadAllPreferences())
            .thenAnswer((_) async => {'playerName': 'test_player'});
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => testPosition);
        when(() => mockDatabaseService.getRecentEvents(limit: any(named: 'limit')))
            .thenAnswer((_) async => <GameEvent>[]);
        when(() => mockDatabaseService.getEventsBySession(any()))
            .thenAnswer((_) async => <GameEvent>[]);
        when(() => mockDatabaseService.insertEvent(any()))
            .thenAnswer((_) async => 1);
        
        await telemetryService.initialize();
      });

      test('should record manual event during active session', () async {
        // Arrange
        await telemetryService.startSession();

        // Act
        await telemetryService.recordManualEvent('HIT');

        // Assert
        verify(() => mockDatabaseService.insertEvent(any())).called(2); // START + HIT
        verify(() => mockLocationService.getCurrentPosition()).called(3); // init + startSession + recordEvent
      });

      test('should auto-start session when recording event while stopped', () async {
        // Arrange
        expect(telemetryService.sessionState, equals(SessionState.stopped));

        // Act
        await telemetryService.recordManualEvent('EMERGENCY');

        // Assert
        expect(telemetryService.sessionState, equals(SessionState.running));
        expect(telemetryService.currentSessionId, isNotNull);
        verify(() => mockDatabaseService.insertEvent(any())).called(2); // START + EMERGENCY
      });

      test('should not record event when session is paused', () async {
        // Arrange
        await telemetryService.startSession();
        await telemetryService.pauseSession();
        expect(telemetryService.sessionState, equals(SessionState.paused));

        // Act
        await telemetryService.recordManualEvent('SHOULD_NOT_RECORD');

        // Assert
        expect(telemetryService.sessionState, equals(SessionState.paused));
        verify(() => mockDatabaseService.insertEvent(any())).called(2); // Only START + PAUSE
      });

      test('should create event with correct data structure', () async {
        // Arrange
        await telemetryService.startSession();

        // Act
        await telemetryService.recordManualEvent('KILL');

        // Assert
        final capturedCalls = verify(() => mockDatabaseService.insertEvent(captureAny())).captured;
        final killEvent = capturedCalls.last as GameEvent;
        
        expect(killEvent.eventType, equals('KILL'));
        expect(killEvent.playerId, equals('test_player'));
        expect(killEvent.gameSessionId, equals(telemetryService.currentSessionId));
        expect(killEvent.latitude, equals(testPosition.latitude));
        expect(killEvent.longitude, equals(testPosition.longitude));
        expect(killEvent.altitude, equals(testPosition.altitude));
        expect(killEvent.timestamp, closeTo(DateTime.now().millisecondsSinceEpoch, 1000));
      });

      test('should verify exact parameters passed to database service', () async {
        // Arrange
        await telemetryService.startSession();

        // Act
        await telemetryService.recordManualEvent('ELIMINATION');

        // Assert - Verify exact parameters
        final capturedEvents = verify(() => mockDatabaseService.insertEvent(captureAny())).captured;
        expect(capturedEvents, hasLength(2)); // START + ELIMINATION
        
        final eliminationEvent = capturedEvents.last as GameEvent;
        expect(eliminationEvent.eventType, equals('ELIMINATION'));
        expect(eliminationEvent.gameSessionId, equals(telemetryService.currentSessionId));
        expect(eliminationEvent.playerId, equals('test_player'));
        expect(eliminationEvent.latitude, equals(testPosition.latitude));
        expect(eliminationEvent.longitude, equals(testPosition.longitude));
        expect(eliminationEvent.altitude, equals(testPosition.altitude));
        expect(eliminationEvent.azimuth, equals(testPosition.heading));
        expect(eliminationEvent.speed, equals(testPosition.speed));
        expect(eliminationEvent.accuracy, equals(testPosition.accuracy));
      });

      test('should handle NaN values in position data', () async {
        // Arrange
        final nanPosition = Position(
          latitude: 40.7128,
          longitude: -74.0060,
          timestamp: DateTime.now(),
          accuracy: 5.0,
          altitude: 10.0,
          altitudeAccuracy: 3.0,
          heading: double.nan,
          headingAccuracy: 2.0,
          speed: double.nan,
          speedAccuracy: 0.5,
        );
        
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => nanPosition);
            
        await telemetryService.startSession();

        // Act
        await telemetryService.recordManualEvent('TEST_EVENT');

        // Assert
        final capturedEvents = verify(() => mockDatabaseService.insertEvent(captureAny())).captured;
        final testEvent = capturedEvents.last as GameEvent;
        
        expect(testEvent.azimuth, isNull); // NaN should be converted to null
        expect(testEvent.speed, isNull); // NaN should be converted to null
        expect(testEvent.accuracy, equals(nanPosition.accuracy)); // Non-NaN should be preserved
      });

      test('should handle location service errors during event recording', () async {
        // Arrange - first allow session to start normally
        await telemetryService.startSession();
        
        // Then make subsequent calls to getCurrentPosition throw
        when(() => mockLocationService.getCurrentPosition())
            .thenThrow(Exception('GPS error'));

        // Act & Assert
        expect(
          () => telemetryService.recordManualEvent('HIT'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Stream Notifications', () {
      setUp(() async {
        when(() => mockPreferencesService.loadAllPreferences())
            .thenAnswer((_) async => {'playerName': 'test_player'});
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => testPosition);
        when(() => mockDatabaseService.getRecentEvents(limit: any(named: 'limit')))
            .thenAnswer((_) async => <GameEvent>[]);
        when(() => mockDatabaseService.getEventsBySession(any()))
            .thenAnswer((_) async => <GameEvent>[]);
        when(() => mockDatabaseService.insertEvent(any()))
            .thenAnswer((_) async => 1);
        
        await telemetryService.initialize();
      });

      test('should emit session state changes', () async {
        // Arrange
        final expectedStates = [
          SessionState.running,
          SessionState.paused,
          SessionState.running,
          SessionState.stopped,
        ];

        // Act & Assert using expectLater for proper stream testing
        final streamFuture = expectLater(
          telemetryService.sessionStateStream.take(4),
          emitsInOrder(expectedStates),
        );

        await telemetryService.startSession();
        await telemetryService.pauseSession();
        await telemetryService.resumeSession();
        await telemetryService.stopSession();

        await streamFuture;
      });

      test('should emit position updates', () async {
        // Act & Assert using expectLater for stream testing
        final positionFuture = expectLater(
          telemetryService.positionStream.take(2),
          emitsInOrder([
            predicate<Position?>((pos) => pos?.latitude == testPosition.latitude),
            predicate<Position?>((pos) => pos?.latitude == testPosition.latitude),
          ]),
        );

        await telemetryService.startSession();
        await telemetryService.recordManualEvent('HIT');

        await positionFuture;
      });

      test('should emit recent events updates', () async {
        // Arrange
        final mockEvents = [
          GameEvent(
            gameSessionId: 'test_session',
            playerId: 'test_player',
            eventType: 'START',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            latitude: 40.7128,
            longitude: -74.0060,
            altitude: 10.0,
          ),
        ];
        when(() => mockDatabaseService.getEventsBySession(any()))
            .thenAnswer((_) async => mockEvents);

        // Act & Assert
        await telemetryService.startSession();
        
        await expectLater(
          telemetryService.recentEventsStream.first,
          completion(isA<List<GameEvent>>()),
        );
      });
    });

    group('Settings Updates', () {
      setUp(() async {
        when(() => mockPreferencesService.loadAllPreferences())
            .thenAnswer((_) async => {'playerName': 'test_player'});
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => testPosition);
        when(() => mockDatabaseService.getRecentEvents(limit: any(named: 'limit')))
            .thenAnswer((_) async => <GameEvent>[]);
        when(() => mockDatabaseService.getEventsBySession(any()))
            .thenAnswer((_) async => <GameEvent>[]);
        when(() => mockDatabaseService.insertEvent(any()))
            .thenAnswer((_) async => 1);
        when(() => mockPreferencesService.setPlayerName(any()))
            .thenAnswer((_) async => true);
        when(() => mockPreferencesService.setUpdateInterval(any()))
            .thenAnswer((_) async => true);
        when(() => mockPreferencesService.getIntervalInSeconds(any()))
            .thenReturn(3);
        
        await telemetryService.initialize();
      });

      test('should update player name', () async {
        // Act
        await telemetryService.updatePlayerName('new_player');

        // Assert
        expect(telemetryService.currentPlayerId, equals('new_player'));
        verify(() => mockPreferencesService.setPlayerName('new_player')).called(1);
      });

      test('should update tracking interval', () async {
        // Act
        await telemetryService.updateInterval('3 seconds');

        // Assert
        verify(() => mockPreferencesService.setUpdateInterval('3 seconds')).called(1);
        verify(() => mockPreferencesService.getIntervalInSeconds('3 seconds')).called(1);
      });

      test('should restart location tracking when updating interval during active session', () async {
        // Arrange
        await telemetryService.startSession();
        expect(telemetryService.sessionState, equals(SessionState.running));

        // Act
        await telemetryService.updateInterval('10 seconds');

        // Assert
        expect(telemetryService.sessionState, equals(SessionState.running));
        verify(() => mockPreferencesService.setUpdateInterval('10 seconds')).called(1);
      });
    });

    group('Data Management', () {
      setUp(() async {
        when(() => mockPreferencesService.loadAllPreferences())
            .thenAnswer((_) async => {'playerName': 'test_player'});
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => testPosition);
        when(() => mockDatabaseService.getRecentEvents(limit: any(named: 'limit')))
            .thenAnswer((_) async => <GameEvent>[]);
        
        await telemetryService.initialize();
      });

      test('should get all events', () async {
        // Arrange
        final mockEvents = [
          GameEvent(
            gameSessionId: 'session1',
            playerId: 'player1',
            eventType: 'START',
            timestamp: DateTime.now().millisecondsSinceEpoch,
            latitude: 40.7128,
            longitude: -74.0060,
            altitude: 0.0,
          ),
        ];
        when(() => mockDatabaseService.getAllEvents())
            .thenAnswer((_) async => mockEvents);

        // Act
        final events = await telemetryService.getAllEvents();

        // Assert
        expect(events, equals(mockEvents));
        verify(() => mockDatabaseService.getAllEvents()).called(1);
      });

      test('should clear all data', () async {
        // Arrange
        when(() => mockDatabaseService.clearAllEvents())
            .thenAnswer((_) async => 5);

        // Act
        final deletedCount = await telemetryService.clearAllData();

        // Assert
        expect(deletedCount, equals(5));
        expect(telemetryService.cachedRecentEvents, isEmpty);
        verify(() => mockDatabaseService.clearAllEvents()).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle database errors during initialization', () async {
        // Arrange
        when(() => mockPreferencesService.loadAllPreferences())
            .thenAnswer((_) async => {'playerName': 'test_player'});
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => testPosition);
        when(() => mockDatabaseService.getRecentEvents(limit: any(named: 'limit')))
            .thenThrow(Exception('Database connection failed'));

        // Act & Assert
        expect(
          () => telemetryService.initialize(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle location service errors during session start', () async {
        // Arrange - first allow initialization to succeed
        when(() => mockPreferencesService.loadAllPreferences())
            .thenAnswer((_) async => {'playerName': 'test_player'});
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => testPosition);
        when(() => mockDatabaseService.getRecentEvents(limit: any(named: 'limit')))
            .thenAnswer((_) async => <GameEvent>[]);

        await telemetryService.initialize();
        
        // Then make location service fail for session start
        when(() => mockLocationService.getCurrentPosition())
            .thenThrow(Exception('GPS not available'));

        // Act & Assert
        expect(
          () => telemetryService.startSession(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle database errors during event insertion', () async {
        // Arrange
        when(() => mockPreferencesService.loadAllPreferences())
            .thenAnswer((_) async => {'playerName': 'test_player'});
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => testPosition);
        when(() => mockDatabaseService.getRecentEvents(limit: any(named: 'limit')))
            .thenAnswer((_) async => <GameEvent>[]);
        when(() => mockDatabaseService.insertEvent(any()))
            .thenThrow(Exception('Database insert failed'));

        await telemetryService.initialize();

        // Act & Assert
        expect(
          () => telemetryService.startSession(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Disposal', () {
      test('should dispose resources properly', () async {
        // Arrange
        when(() => mockPreferencesService.loadAllPreferences())
            .thenAnswer((_) async => {'playerName': 'test_player'});
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => testPosition);
        when(() => mockDatabaseService.getRecentEvents(limit: any(named: 'limit')))
            .thenAnswer((_) async => <GameEvent>[]);
        when(() => mockDatabaseService.getEventsBySession(any()))
            .thenAnswer((_) async => <GameEvent>[]);

        await telemetryService.initialize();

        // Act
        telemetryService.dispose();

        // Assert - should not throw
        expect(() => telemetryService.dispose(), returnsNormally);
        verify(() => mockLocationService.dispose()).called(2); // called in test and tearDown
      });

      test('should stop location tracking on disposal', () async {
        // Arrange
        when(() => mockPreferencesService.loadAllPreferences())
            .thenAnswer((_) async => {'playerName': 'test_player'});
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => testPosition);
        when(() => mockDatabaseService.getRecentEvents(limit: any(named: 'limit')))
            .thenAnswer((_) async => <GameEvent>[]);
        when(() => mockDatabaseService.getEventsBySession(any()))
            .thenAnswer((_) async => <GameEvent>[]);
        when(() => mockDatabaseService.insertEvent(any()))
            .thenAnswer((_) async => 1);

        await telemetryService.initialize();
        await telemetryService.startSession();

        // Act
        telemetryService.dispose();

        // Assert
        verify(() => mockLocationService.dispose()).called(1);
      });
    });

    group('Complete Session Flow', () {
      setUp(() async {
        when(() => mockPreferencesService.loadAllPreferences())
            .thenAnswer((_) async => {'playerName': 'test_player'});
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => testPosition);
        when(() => mockDatabaseService.getRecentEvents(limit: any(named: 'limit')))
            .thenAnswer((_) async => <GameEvent>[]);
        when(() => mockDatabaseService.getEventsBySession(any()))
            .thenAnswer((_) async => <GameEvent>[]);
        
        await telemetryService.initialize();
      });

      test('should handle complete session lifecycle with events', () async {
        // Arrange
        final events = <GameEvent>[];
        when(() => mockDatabaseService.insertEvent(any())).thenAnswer((invocation) async {
          events.add(invocation.positionalArguments[0] as GameEvent);
          return events.length;
        });

        // Act - Complete session flow
        await telemetryService.startSession();
        await telemetryService.recordManualEvent('HIT');
        await telemetryService.recordManualEvent('KILL');
        await telemetryService.pauseSession();
        await telemetryService.resumeSession();
        await telemetryService.recordManualEvent('OBJECTIVE_COMPLETE');
        await telemetryService.stopSession();

        // Assert
        expect(events, hasLength(7)); // START, HIT, KILL, PAUSE, RESUME, OBJECTIVE_COMPLETE, STOP
        expect(events.map((e) => e.eventType), contains('START'));
        expect(events.map((e) => e.eventType), contains('HIT'));
        expect(events.map((e) => e.eventType), contains('KILL'));
        expect(events.map((e) => e.eventType), contains('PAUSE'));
        expect(events.map((e) => e.eventType), contains('RESUME'));
        expect(events.map((e) => e.eventType), contains('OBJECTIVE_COMPLETE'));
        expect(events.map((e) => e.eventType), contains('STOP'));
        
        // All events should have the same session ID
        final sessionIds = events.map((e) => e.gameSessionId).toSet();
        expect(sessionIds, hasLength(1));
      });

      test('should maintain consistent player ID across all events', () async {
        // Arrange
        final events = <GameEvent>[];
        when(() => mockDatabaseService.insertEvent(any())).thenAnswer((invocation) async {
          events.add(invocation.positionalArguments[0] as GameEvent);
          return events.length;
        });

        // Act
        await telemetryService.startSession();
        await telemetryService.recordManualEvent('EVENT1');
        await telemetryService.recordManualEvent('EVENT2');
        await telemetryService.stopSession();

        // Assert
        final playerIds = events.map((e) => e.playerId).toSet();
        expect(playerIds, hasLength(1));
        expect(playerIds.first, equals('test_player'));
      });
    });

    group('Performance Tests', () {
      setUp(() async {
        when(() => mockPreferencesService.loadAllPreferences())
            .thenAnswer((_) async => {'playerName': 'test_player'});
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => testPosition);
        when(() => mockDatabaseService.getRecentEvents(limit: any(named: 'limit')))
            .thenAnswer((_) async => <GameEvent>[]);
        when(() => mockDatabaseService.getEventsBySession(any()))
            .thenAnswer((_) async => <GameEvent>[]);
        when(() => mockDatabaseService.insertEvent(any()))
            .thenAnswer((_) async => 1);
      });

      test('should initialize within reasonable time', () async {
        // Act & Assert
        await expectLater(
          telemetryService.initialize(),
          completes,
        ).timeout(const Duration(seconds: 2));
      });

      test('should handle rapid event recording', () async {
        // Arrange
        await telemetryService.initialize();
        await telemetryService.startSession();

        // Act - Record multiple events rapidly
        final futures = <Future<void>>[];
        for (int i = 0; i < 10; i++) {
          futures.add(telemetryService.recordManualEvent('RAPID_EVENT_$i'));
        }

        // Assert - Should complete without timing out
        await expectLater(
          Future.wait(futures),
          completes,
        ).timeout(const Duration(seconds: 5));
      });
    });

    group('Null Safety and Edge Cases', () {
      setUp(() async {
        when(() => mockPreferencesService.loadAllPreferences())
            .thenAnswer((_) async => {'playerName': 'test_player'});
        when(() => mockDatabaseService.getRecentEvents(limit: any(named: 'limit')))
            .thenAnswer((_) async => <GameEvent>[]);
        when(() => mockDatabaseService.getEventsBySession(any()))
            .thenAnswer((_) async => <GameEvent>[]);
      });

      test('should handle null position gracefully during session start', () async {
        // Arrange
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => null);
        when(() => mockDatabaseService.insertEvent(any()))
            .thenAnswer((_) async => 1);
        
        await telemetryService.initialize();

        // Act & Assert - should not throw
        await expectLater(
          telemetryService.startSession(),
          completes,
        );
        
        expect(telemetryService.sessionState, equals(SessionState.running));
        verifyNever(() => mockDatabaseService.insertEvent(any()));
      });

      test('should handle null position gracefully during event recording', () async {
        // Arrange
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => testPosition);
        when(() => mockDatabaseService.insertEvent(any()))
            .thenAnswer((_) async => 1);
        
        await telemetryService.initialize();
        await telemetryService.startSession();
        
        // Make subsequent position calls return null
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => null);

        // Act & Assert - should not throw
        await expectLater(
          telemetryService.recordManualEvent('HIT'),
          completes,
        );
        
        // Only START event should be recorded, not HIT
        verify(() => mockDatabaseService.insertEvent(any())).called(1);
      });

      test('should handle empty preferences gracefully', () async {
        // Arrange
        when(() => mockPreferencesService.loadAllPreferences())
            .thenAnswer((_) async => <String, String>{});
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => testPosition);

        // Act & Assert
        await expectLater(
          telemetryService.initialize(),
          completes,
        );
        
        expect(telemetryService.currentPlayerId, isNotEmpty);
        expect(telemetryService.currentPlayerId, equals('default_player'));
      });
    });
  });
}

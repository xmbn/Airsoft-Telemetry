# Event Detection Implementation Plan

## Overview

This document outlines the implementation plan for integrating the advanced event detection algorithms (spawn and death detection) developed in the Jupyter notebook into the Flutter airsoft telemetry app. The event detection will run automatically when a game analysis is first requested, providing enhanced insights beyond manual event recording.

## Implementation Goals

1. **Automatic Event Detection**: Detect spawn and death events from GPS movement patterns
2. **Triggered Analysis**: Run detection when user requests game analysis for the first time
3. **Performance Optimization**: Efficient algorithms that don't impact real-time tracking
4. **Confidence Scoring**: Provide confidence levels for detected events
5. **User Feedback**: Allow users to review and validate detected events
6. **Data Integration**: Seamlessly integrate detected events with existing manual events

## Architecture Overview

### Key Components

1. **EventDetectionService**: Core service implementing the detection algorithms
2. **AnalysisService**: Orchestrates analysis workflow and caches results
3. **Enhanced InsightsScreen**: Updated UI to display detected events and confidence scores
4. **Database Extensions**: Store detected events with metadata
5. **Export Enhancements**: Include detected events in CSV exports

## Implementation Plan

### Phase 1: Core Event Detection Service

#### 1.1 Create EventDetectionService (`lib/services/event_detection_service.dart`)

**Key Features:**
- Port spawn detection algorithm with hysteresis
- Port death detection algorithm with backtracking
- Movement pattern analysis utilities
- Confidence scoring system
- Clustering and filtering logic

**Algorithm Parameters:**
```dart
class EventDetectionConfig {
  // Spawn Detection
  static const double spawnRadius = 25.0; // meters
  static const double exitRadius = 35.0; // meters (hysteresis)
  static const int minTimeOutside = 30; // seconds
  
  // Death Detection
  static const double confidenceThreshold = 0.6;
  static const int maxBacktrackTime = 300; // seconds (5 minutes)
  static const double clusterDistanceThreshold = 30.0; // meters
  static const int clusterTimeThreshold = 120; // seconds (2 minutes)
  
  // Movement Analysis
  static const double anomalyThreshold = 0.6;
  static const int movementWindowSize = 5; // GPS points
}
```

**Core Methods:**
```dart
class EventDetectionService {
  // Main detection methods
  Future<List<DetectedEvent>> detectSpawnEvents(List<GameEvent> events, {
    required double spawnLat,
    required double spawnLon,
    required double spawnRadius,
  });
  
  Future<List<DetectedEvent>> detectDeathEvents(List<GameEvent> events, {
    required double spawnLat,
    required double spawnLon,
    required double confidenceThreshold,
  });
  
  // Utility methods
  double calculateDistance(double lat1, double lon1, double lat2, double lon2);
  double calculateBearing(double lat1, double lon1, double lat2, double lon2);
  double angleDifference(double angle1, double angle2);
  List<double> calculateSpeeds(List<GameEvent> events);
  
  // Analysis methods
  List<MovementAnomaly> detectMovementAnomalies(List<GameEvent> events);
  List<DetectedEvent> backtrackFromAnomalies(
    List<GameEvent> events,
    List<MovementAnomaly> anomalies,
  );
  List<DetectedEvent> clusterAndFilterEvents(
    List<DetectedEvent> candidates,
    double distanceThreshold,
    int timeThreshold,
  );
}
```

#### 1.2 Create DetectedEvent Model (`lib/models/detected_event.dart`)

```dart
class DetectedEvent {
  final String sessionId;
  final String playerId;
  final String eventType; // 'DETECTED_SPAWN', 'DETECTED_DEATH'
  final int timestamp;
  final double latitude;
  final double longitude;
  final double confidence; // 0.0 to 1.0
  final Map<String, dynamic> metadata; // Additional detection info
  
  // Optional fields for death detection
  final int? backtrackSeconds;
  final double? distanceToSpawn;
  final int? anomalyTime;
  
  // Optional fields for spawn detection
  final int? timeOutside;
  final double? exitDistance;
}
```

#### 1.3 Database Schema Extensions

**Add new table for detected events:**
```sql
CREATE TABLE detected_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sessionId TEXT NOT NULL,
  playerId TEXT NOT NULL,
  eventType TEXT NOT NULL,
  timestamp INTEGER NOT NULL,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  confidence REAL NOT NULL,
  metadata TEXT, -- JSON string
  backtrackSeconds INTEGER,
  distanceToSpawn REAL,
  anomalyTime INTEGER,
  timeOutside INTEGER,
  exitDistance REAL,
  isValidated BOOLEAN DEFAULT 0,
  isRejected BOOLEAN DEFAULT 0,
  createdAt INTEGER NOT NULL
);
```

### Phase 2: Analysis Service and Workflow

#### 2.1 Create AnalysisService (`lib/services/analysis_service.dart`)

**Responsibilities:**
- Orchestrate event detection workflow
- Cache analysis results
- Manage analysis state
- Coordinate between detection and database services

```dart
class AnalysisService {
  static final AnalysisService _instance = AnalysisService._internal();
  factory AnalysisService() => _instance;
  
  final EventDetectionService _detectionService = EventDetectionService();
  final DatabaseService _databaseService = DatabaseService();
  
  // Analysis state management
  final Map<String, AnalysisResult> _analysisCache = {};
  final StreamController<AnalysisProgress> _progressController = 
      StreamController<AnalysisProgress>.broadcast();
  
  // Main analysis method
  Future<AnalysisResult> analyzeSession(String sessionId, {
    bool forceReanalysis = false,
  });
  
  // Helper methods
  Future<GameEvent?> findGameStartEvent(List<GameEvent> events);
  Future<void> saveDetectedEvents(List<DetectedEvent> events);
  Future<List<DetectedEvent>> getDetectedEvents(String sessionId);
  
  // Validation methods
  Future<void> validateDetectedEvent(int eventId);
  Future<void> rejectDetectedEvent(int eventId);
  
  // Progress tracking
  Stream<AnalysisProgress> get analysisProgress => _progressController.stream;
}
```

#### 2.2 Analysis Workflow

```dart
class AnalysisResult {
  final String sessionId;
  final DateTime analyzedAt;
  final List<DetectedEvent> detectedSpawns;
  final List<DetectedEvent> detectedDeaths;
  final AnalysisMetrics metrics;
  final bool isComplete;
}

class AnalysisMetrics {
  final int totalGpsPoints;
  final int detectedSpawns;
  final int detectedDeaths;
  final double averageConfidence;
  final Duration analysisTime;
  final GameEvent? spawnPoint;
}

class AnalysisProgress {
  final String sessionId;
  final String stage; // 'loading', 'detecting_spawns', 'detecting_deaths', 'complete'
  final double progress; // 0.0 to 1.0
  final String? message;
}
```

### Phase 3: UI Integration

#### 3.1 Enhanced InsightsScreen

**New sections to add:**
1. **Analysis Status**: Show if analysis has been run
2. **Detected Events**: Display detected spawns/deaths with confidence scores
3. **Event Validation**: Allow users to confirm/reject detected events
4. **Analysis Metrics**: Show detection statistics
5. **Trigger Analysis**: Button to run/re-run analysis

**UI Components:**
```dart
// Analysis trigger button
Widget _buildAnalysisSection() {
  return Card(
    child: Column(
      children: [
        Text('Event Detection Analysis'),
        if (!_hasAnalysis) 
          ElevatedButton(
            onPressed: _runAnalysis,
            child: Text('Analyze Game Session'),
          )
        else
          Text('Last analyzed: ${_lastAnalysis}'),
      ],
    ),
  );
}

// Detected events display
Widget _buildDetectedEventsSection() {
  return ExpansionTile(
    title: Text('Detected Events (${_detectedEvents.length})'),
    children: _detectedEvents.map((event) => 
      DetectedEventTile(
        event: event,
        onValidate: () => _validateEvent(event.id),
        onReject: () => _rejectEvent(event.id),
      ),
    ).toList(),
  );
}

// Individual detected event
class DetectedEventTile extends StatelessWidget {
  final DetectedEvent event;
  final VoidCallback onValidate;
  final VoidCallback onReject;
  
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_getEventIcon(event.eventType)),
      title: Text(event.eventType),
      subtitle: Text(
        'Confidence: ${(event.confidence * 100).toStringAsFixed(1)}%\n'
        'Location: ${event.latitude.toStringAsFixed(6)}, ${event.longitude.toStringAsFixed(6)}'
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.green),
            onPressed: onValidate,
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: onReject,
          ),
        ],
      ),
    );
  }
}
```

#### 3.2 Analysis Progress Dialog

```dart
class AnalysisProgressDialog extends StatefulWidget {
  final String sessionId;
  
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Analyzing Game Session'),
      content: StreamBuilder<AnalysisProgress>(
        stream: AnalysisService().analysisProgress,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          
          final progress = snapshot.data!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: progress.progress),
              SizedBox(height: 16),
              Text(progress.message ?? progress.stage),
            ],
          );
        },
      ),
    );
  }
}
```

### Phase 4: Export and Data Management

#### 4.1 Enhanced ExportService

**Update CSV export to include detected events:**
```dart
class ExportService {
  Future<String?> exportToCsv({bool includeDetectedEvents = true}) async {
    final events = await _databaseService.getAllEvents();
    
    List<dynamic> allEvents = events;
    
    if (includeDetectedEvents) {
      final detectedEvents = await _databaseService.getAllDetectedEvents();
      allEvents = [...events, ...detectedEvents];
    }
    
    // Sort by timestamp
    allEvents.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return _convertEventsToCsv(allEvents);
  }
  
  String _convertEventsToCsv(List<dynamic> events) {
    final rows = <List<String>>[];
    
    // Enhanced CSV header
    rows.add([
      'Session ID', 'Player ID', 'Event Type', 'Timestamp', 'Date Time',
      'Latitude', 'Longitude', 'Altitude', 'Azimuth', 'Speed', 'Accuracy',
      'Is Detected', 'Confidence', 'Validation Status'
    ]);
    
    // Add rows for both manual and detected events
    for (final event in events) {
      rows.add(_convertEventToRow(event));
    }
    
    return const ListToCsvConverter().convert(rows);
  }
}
```

#### 4.2 Settings Integration

**Add analysis preferences to SettingsScreen:**
```dart
// Analysis settings section
Widget _buildAnalysisSettings() {
  return ExpansionTile(
    title: Text('Event Detection Settings'),
    children: [
      SwitchListTile(
        title: Text('Auto-analyze new sessions'),
        value: _autoAnalyze,
        onChanged: (value) => _updateAutoAnalyze(value),
      ),
      ListTile(
        title: Text('Detection Sensitivity'),
        subtitle: Slider(
          value: _sensitivity,
          min: 0.3,
          max: 0.9,
          divisions: 6,
          label: '${(_sensitivity * 100).round()}%',
          onChanged: (value) => _updateSensitivity(value),
        ),
      ),
      ListTile(
        title: Text('Clear Analysis Data'),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: _clearAnalysisData,
        ),
      ),
    ],
  );
}
```

### Phase 5: Performance and Optimization

#### 5.1 Background Processing

**Use Isolates for heavy computation:**
```dart
class EventDetectionService {
  Future<List<DetectedEvent>> detectEventsInBackground(
    List<GameEvent> events,
    DetectionParameters params,
  ) async {
    // Run detection in isolate to avoid blocking UI
    return await compute(_runDetectionAlgorithms, {
      'events': events,
      'params': params,
    });
  }
}

// Top-level function for isolate
Map<String, dynamic> _runDetectionAlgorithms(Map<String, dynamic> input) {
  final events = input['events'] as List<GameEvent>;
  final params = input['params'] as DetectionParameters;
  
  // Run detection algorithms
  final spawns = _detectSpawns(events, params);
  final deaths = _detectDeaths(events, params);
  
  return {
    'spawns': spawns,
    'deaths': deaths,
  };
}
```

#### 5.2 Caching Strategy

```dart
class AnalysisService {
  // Memory cache for recent analyses
  final LRUCache<String, AnalysisResult> _memoryCache = 
      LRUCache<String, AnalysisResult>(maxSize: 10);
  
  // Persistent cache in database
  Future<void> _cacheAnalysisResult(AnalysisResult result) async {
    _memoryCache[result.sessionId] = result;
    await _databaseService.saveAnalysisResult(result);
  }
  
  Future<AnalysisResult?> _getCachedAnalysis(String sessionId) async {
    // Check memory cache first
    if (_memoryCache.containsKey(sessionId)) {
      return _memoryCache[sessionId];
    }
    
    // Check database cache
    return await _databaseService.getAnalysisResult(sessionId);
  }
}
```

## Implementation Timeline

### Week 1: Core Algorithm Implementation
- [x] Port utility functions from notebook
- [x] Implement spawn detection algorithm
- [x] Implement death detection algorithm
- [x] Create DetectedEvent model
- [x] Add database schema extensions

### Week 2: Service Integration
- [x] Create EventDetectionService
- [x] Create AnalysisService
- [x] Implement analysis workflow
- [x] Add background processing support
- [x] Create unit tests for detection algorithms

### Week 3: UI Development
- [x] Enhance InsightsScreen with analysis features
- [x] Create analysis progress dialog
- [x] Add event validation UI
- [x] Implement analysis trigger functionality
- [x] Add settings for analysis preferences

### Week 4: Data Management and Polish
- [x] Update ExportService for detected events
- [x] Implement caching strategy
- [x] Add comprehensive error handling
- [x] Performance optimization
- [x] Integration testing

## Testing Strategy

### Unit Tests
- **EventDetectionService**: Test individual algorithms with known datasets
- **AnalysisService**: Test workflow orchestration and caching
- **DetectedEvent Model**: Test serialization and validation

### Integration Tests
- **End-to-end Analysis**: Full workflow from GPS data to detected events
- **UI Integration**: Test analysis trigger and result display
- **Export Integration**: Verify detected events in CSV exports

### Test Data
- Use sample data from `docs/analysis/data/sample-1.csv`
- Create synthetic test cases for edge conditions
- Test with various game session lengths and patterns

## Configuration and Tuning

### Default Parameters
```dart
class EventDetectionConfig {
  // Spawn Detection (conservative defaults)
  static const double spawnRadius = 25.0;
  static const double exitRadius = 35.0;
  static const int minTimeOutside = 30;
  
  // Death Detection (balanced defaults)
  static const double confidenceThreshold = 0.6;
  static const int maxBacktrackTime = 300;
  static const double clusterDistanceThreshold = 30.0;
  static const int clusterTimeThreshold = 120;
  
  // User-adjustable sensitivity
  static double getSensitivityAdjustedThreshold(double sensitivity) {
    // Map 0.3-0.9 sensitivity to 0.4-0.8 confidence threshold
    return 0.4 + (0.9 - sensitivity) * 0.4;
  }
}
```

### Advanced Settings (Future Enhancement)
- Custom spawn point definition (instead of game start)
- Adjustable algorithm parameters
- Different detection modes (aggressive, balanced, conservative)
- Manual spawn area definition on map

## Error Handling and Edge Cases

### Common Scenarios
1. **Insufficient GPS Data**: Handle sessions with too few location points
2. **Poor GPS Accuracy**: Filter out unreliable location data
3. **Short Game Sessions**: Skip analysis for sessions under threshold duration
4. **No Movement Patterns**: Handle stationary gameplay scenarios
5. **Multiple Spawn Areas**: Detect and handle games with multiple spawn zones

### Error Recovery
```dart
class AnalysisService {
  Future<AnalysisResult> analyzeSession(String sessionId) async {
    try {
      final events = await _loadSessionEvents(sessionId);
      
      // Validate data quality
      if (!_validateDataQuality(events)) {
        throw AnalysisException('Insufficient or poor quality GPS data');
      }
      
      // Run detection with timeout
      final result = await _runDetectionWithTimeout(events);
      
      await _cacheAnalysisResult(result);
      return result;
      
    } on AnalysisException {
      rethrow;
    } catch (e) {
      throw AnalysisException('Analysis failed: ${e.toString()}');
    }
  }
  
  bool _validateDataQuality(List<GameEvent> events) {
    // Check minimum data requirements
    final locationEvents = events.where((e) => e.eventType == 'LOCATION');
    if (locationEvents.length < 50) return false; // Need at least 50 GPS points
    
    // Check time span
    final timeSpan = events.last.timestamp - events.first.timestamp;
    if (timeSpan < 300000) return false; // Need at least 5 minutes
    
    // Check GPS accuracy
    final accurateEvents = events.where((e) => (e.accuracy ?? 100) < 20);
    if (accurateEvents.length < locationEvents.length * 0.7) return false;
    
    return true;
  }
}
```

## Security and Privacy Considerations

### Data Protection
- **Local Processing**: All analysis runs locally on device
- **No Cloud Dependencies**: No external APIs or services required
- **User Control**: Users control when analysis runs and what data is included
- **Data Retention**: Clear options to delete analysis results

### Performance Impact
- **Battery Usage**: Minimize impact through efficient algorithms and caching
- **Storage**: Compressed storage of analysis results
- **Memory Management**: Proper cleanup of analysis data structures
- **Background Processing**: Use isolates to prevent UI blocking

## Future Enhancements

### Advanced Features
1. **Machine Learning Models**: Train custom models on user data
2. **Team Analysis**: Multi-player event correlation
3. **Historical Trends**: Track improvement over time
4. **Game Mode Detection**: Automatic detection of game types
5. **Tactical Analysis**: Movement pattern insights

### Integration Possibilities
1. **Map Visualization**: Display detected events on satellite imagery
2. **Real-time Detection**: Live event detection during gameplay
3. **Social Features**: Share analysis results with team
4. **Tournament Mode**: Enhanced analysis for competitive play

## Conclusion

This implementation plan provides a comprehensive approach to integrating advanced event detection into the Flutter airsoft telemetry app. The phased approach ensures systematic development while maintaining the app's existing functionality and performance standards.

The key benefits of this implementation:
- **Enhanced User Experience**: Automatic detection of game events
- **Improved Data Quality**: Higher accuracy event recording
- **Performance Optimized**: Efficient algorithms with minimal battery impact
- **User Controlled**: Optional analysis with manual validation
- **Future Ready**: Architecture supports advanced features and ML integration

The implementation follows Flutter best practices and maintains consistency with the existing codebase architecture.

# Insights Feature Implementation Plan

## Overview
Transform the current placeholder Insights screen into a comprehensive analytics dashboard that allows users to select game sessions and view detailed KPIs and statistics. This implementation serves as the foundation for future advanced features including mapping visualization, time trend analysis, and AI-powered insights.

## Current State Analysis

**Data Model & Storage:**
- `GameEvent` model with fields: `gameSessionId`, `playerId`, `eventType`, `timestamp`, `latitude`, `longitude`, `altitude`, `azimuth`, `speed`, `accuracy`
- Event types include: `START`, `STOP`, `PAUSE`, `RESUME`, `LOCATION`, `HIT`, `SPAWN`, `KILL`
- SQLite database with indexed queries for performance
- Session IDs follow format: `session_${timestamp}`

**Existing Database Queries:**
- `getAllEvents()` - gets all events ordered by timestamp DESC
- `getEventsBySession(sessionId)` - filters events by session
- `getRecentEvents(limit)` - gets recent events with limit
- `getEventCount()` - total event count

**Current Insights Screen:**
- Placeholder with hardcoded data
- Basic UI structure already in place
- Currently shows: session summary, event breakdown, recent activity

## 1. Data Layer Enhancements

### New Database Queries (Add to `DatabaseService`)
```dart
// Get unique session IDs with basic metadata
Future<List<SessionSummary>> getSessionSummaries()

// Get all events for multiple sessions (for analytics)
Future<List<GameEvent>> getEventsBySessionIds(List<String> sessionIds)
```

### New Data Models

#### Session Summary Model (`lib/models/session_summary.dart`)
```dart
class SessionSummary {
  final String sessionId;
  final int startTimestamp;
  final int? endTimestamp;
  final String playerName;
  final int totalEvents;
  final DateTime startDate;
  
  SessionSummary({
    required this.sessionId,
    required this.startTimestamp,
    this.endTimestamp,
    required this.playerName,
    required this.totalEvents,
    required this.startDate,
  });
  
  String get displayName {
    final date = DateFormat('MMM dd, yyyy HH:mm').format(startDate);
    return '$date - $playerName';
  }
  
  Duration? get duration {
    if (endTimestamp == null) return null;
    return Duration(milliseconds: endTimestamp! - startTimestamp);
  }
}
```

#### Session KPIs Model (`lib/models/session_kpis.dart`)
```dart
class SessionKPIs {
  final String sessionId;
  final Duration? duration;
  final double distanceTraveled; // in meters
  final int kills;
  final int deaths; // HIT events
  final int spawns;
  final int kd; // kills-deaths
  final double avgSpeed; // m/s
  final String sessionDate;
  final int totalEvents;
  final bool isCompleteSession; // has both START and STOP events
  
  // Extended data for future features
  final List<GameEvent> locationEvents; // For mapping visualization
  final List<GameEvent> combatEvents; // For AI analysis patterns
  final Map<String, dynamic> rawMetrics; // Extensible metrics storage
  
  SessionKPIs({
    required this.sessionId,
    this.duration,
    required this.distanceTraveled,
    required this.kills,
    required this.deaths,
    required this.spawns,
    required this.kd,
    required this.avgSpeed,
    required this.sessionDate,
    required this.totalEvents,
    required this.isCompleteSession,
    required this.locationEvents,
    required this.combatEvents,
    required this.rawMetrics,
  });
  
  String get formattedDuration {
    if (duration == null) return 'Incomplete';
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes.remainder(60);
    final seconds = duration!.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
  
  String get formattedDistance {
    if (distanceTraveled < 1000) {
      return '${distanceTraveled.toStringAsFixed(0)} m';
    } else {
      return '${(distanceTraveled / 1000).toStringAsFixed(2)} km';
    }
  }
  
  String get formattedKD {
    return kd.toString();
  }
  
  // Future-ready data accessors
  List<LatLng> get movementPath => locationEvents
      .map((e) => LatLng(e.latitude, e.longitude))
      .toList();
      
  Map<String, int> get hourlyActivity {
    final Map<String, int> activity = {};
    for (final event in combatEvents) {
      final hour = DateTime.fromMillisecondsSinceEpoch(event.timestamp).hour;
      final key = '${hour.toString().padLeft(2, '0')}:00';
      activity[key] = (activity[key] ?? 0) + 1;
    }
    return activity;
  }
  
  double get combatEfficiency {
    if (kills + deaths == 0) return 0.0;
    return kills / (kills + deaths);
  }
}
```

## 2. Service Layer Implementation

### Analytics Service (`lib/services/analytics_service.dart`)
```dart
class AnalyticsService {
  final DatabaseService _databaseService = DatabaseService();
  
  // Calculate comprehensive KPIs for a session
  Future<SessionKPIs> calculateSessionKPIs(String sessionId) async {
    final events = await _databaseService.getEventsBySession(sessionId);
    
    if (events.isEmpty) {
      throw Exception('No events found for session $sessionId');
    }
    
    return SessionKPIs(
      sessionId: sessionId,
      duration: _calculateSessionDuration(events),
      distanceTraveled: _calculateTotalDistance(events),
      kills: _countEventType(events, 'KILL'),
      deaths: _countEventType(events, 'HIT'),
      spawns: _countEventType(events, 'SPAWN'),
      kd: _calculateKD(events),
      avgSpeed: _calculateAverageSpeed(events),
      sessionDate: _formatSessionDate(events),
      totalEvents: events.length,
      isCompleteSession: _isCompleteSession(events),
    );
  }
  
  // Calculate distance between GPS points using Haversine formula
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * 
        sin(dLon / 2) * sin(dLon / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
  
  // Calculate total distance traveled during session
  double _calculateTotalDistance(List<GameEvent> events) {
    final locationEvents = events
        .where((e) => e.eventType == 'LOCATION' || e.eventType == 'START' || e.eventType == 'STOP')
        .toList();
    
    if (locationEvents.length < 2) return 0.0;
    
    // Sort by timestamp to ensure correct order
    locationEvents.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    double totalDistance = 0.0;
    for (int i = 1; i < locationEvents.length; i++) {
      final prev = locationEvents[i - 1];
      final curr = locationEvents[i];
      
      // Filter out low accuracy readings
      if (prev.accuracy != null && prev.accuracy! > 20) continue;
      if (curr.accuracy != null && curr.accuracy! > 20) continue;
      
      totalDistance += calculateDistance(
        prev.latitude, prev.longitude,
        curr.latitude, curr.longitude,
      );
    }
    
    return totalDistance;
  }
  
  // Calculate session duration from START to STOP events
  Duration? _calculateSessionDuration(List<GameEvent> events) {
    final startEvent = events.firstWhere(
      (e) => e.eventType == 'START',
      orElse: () => null,
    );
    final stopEvent = events.firstWhere(
      (e) => e.eventType == 'STOP',
      orElse: () => null,
    );
    
    if (startEvent == null || stopEvent == null) return null;
    
    return Duration(milliseconds: stopEvent.timestamp - startEvent.timestamp);
  }
  
  // Calculate K-D
  int _calculateKD(List<GameEvent> events) {
    final kills = _countEventType(events, 'KILL');
    final deaths = _countEventType(events, 'HIT');
    return kills - deaths;
  }
  
  // Calculate average speed during movement
  double _calculateAverageSpeed(List<GameEvent> events) {
    final movementEvents = events
        .where((e) => e.speed != null && e.speed! > 0)
        .toList();
    
    if (movementEvents.isEmpty) return 0.0;
    
    final totalSpeed = movementEvents.fold<double>(
      0.0, 
      (sum, event) => sum + event.speed!,
    );
    
    return totalSpeed / movementEvents.length;
  }
  
  // Helper methods
  int _countEventType(List<GameEvent> events, String eventType) {
    return events.where((e) => e.eventType == eventType).length;
  }
  
  bool _isCompleteSession(List<GameEvent> events) {
    return events.any((e) => e.eventType == 'START') &&
           events.any((e) => e.eventType == 'STOP');
  }
  
  String _formatSessionDate(List<GameEvent> events) {
    final startEvent = events.firstWhere(
      (e) => e.eventType == 'START',
      orElse: () => events.first,
    );
    
    final date = DateTime.fromMillisecondsSinceEpoch(startEvent.timestamp);
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  double _toRadians(double degrees) => degrees * pi / 180;
}
```

### Enhanced Database Service Methods
```dart
// Add to existing DatabaseService class

/// Get unique session summaries ordered by start time (newest first)
Future<List<SessionSummary>> getSessionSummaries() async {
  final db = await database;
  
  // Get session metadata with aggregated info
  final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT 
      gameSessionId,
      MIN(timestamp) as startTimestamp,
      MAX(CASE WHEN eventType = 'STOP' THEN timestamp END) as endTimestamp,
      playerId,
      COUNT(*) as totalEvents
    FROM game_events 
    GROUP BY gameSessionId, playerId
    ORDER BY MIN(timestamp) DESC
  ''');
  
  return List.generate(maps.length, (i) {
    final startTimestamp = maps[i]['startTimestamp'] as int;
    return SessionSummary(
      sessionId: maps[i]['gameSessionId'] as String,
      startTimestamp: startTimestamp,
      endTimestamp: maps[i]['endTimestamp'] as int?,
      playerName: maps[i]['playerId'] as String,
      totalEvents: maps[i]['totalEvents'] as int,
      startDate: DateTime.fromMillisecondsSinceEpoch(startTimestamp),
    );
  });
}

/// Get events for multiple sessions (useful for batch analytics)
Future<List<GameEvent>> getEventsBySessionIds(List<String> sessionIds) async {
  if (sessionIds.isEmpty) return [];
  
  final db = await database;
  final placeholders = sessionIds.map((_) => '?').join(',');
  
  final List<Map<String, dynamic>> maps = await db.query(
    'game_events',
    where: 'gameSessionId IN ($placeholders)',
    whereArgs: sessionIds,
    orderBy: 'gameSessionId, timestamp ASC',
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
```

## 3. UI Components

### Session Selector Widget (`lib/widgets/session_selector.dart`)
```dart
class SessionSelector extends StatelessWidget {
  final List<SessionSummary> sessions;
  final String? selectedSessionId;
  final Function(String) onSessionSelected;
  final bool isLoading;
  
  const SessionSelector({
    super.key,
    required this.sessions,
    this.selectedSessionId,
    required this.onSessionSelected,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(AppConfig.standardPadding),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: AppConfig.standardPadding),
            Text('Loading sessions...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    
    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppConfig.standardPadding),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
        ),
        child: const Text(
          'No sessions found. Start a telemetry session to see analytics.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return DropdownButtonFormField<String>(
      value: selectedSessionId,
      decoration: InputDecoration(
        labelText: 'Select Session',
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
          borderSide: const BorderSide(color: AppConfig.primaryColor),
        ),
      ),
      dropdownColor: AppConfig.surfaceColor,
      style: const TextStyle(color: Colors.white),
      items: sessions.map((session) {
        return DropdownMenuItem<String>(
          value: session.sessionId,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                session.displayName,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${session.totalEvents} events${session.duration != null ? ' • ${session.duration!.inMinutes}m' : ' • Incomplete'}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onSessionSelected(value);
        }
      },
    );
  }
}
```

### KPI Cards Grid (`lib/widgets/kpi_cards_grid.dart`)
```dart
class KPICardsGrid extends StatelessWidget {
  final SessionKPIs? kpis;
  final bool isLoading;
  
  const KPICardsGrid({
    super.key,
    this.kpis,
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _LoadingGrid();
    }
    
    if (kpis == null) {
      return const _EmptyGrid();
    }
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildKPICard('Duration', kpis!.formattedDuration, Colors.blue)),
            const SizedBox(width: AppConfig.mediumPadding),
            Expanded(child: _buildKPICard('Distance', kpis!.formattedDistance, Colors.green)),
            const SizedBox(width: AppConfig.mediumPadding),
            Expanded(child: _buildKPICard('Kills', kpis!.kills.toString(), Colors.amber)),
          ],
        ),
        const SizedBox(height: AppConfig.standardPadding),
        Row(
          children: [
            Expanded(child: _buildKPICard('Deaths', kpis!.deaths.toString(), Colors.red)),
            const SizedBox(width: AppConfig.mediumPadding),
            Expanded(child: _buildKPICard('KD', kpis!.formattedKD, Colors.purple)),
            const SizedBox(width: AppConfig.mediumPadding),
            Expanded(child: _buildKPICard('Spawns', kpis!.spawns.toString(), Colors.cyan)),
          ],
        ),
      ],
    );
  }
  
  Widget _buildKPICard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConfig.standardPadding),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConfig.smallPadding),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildLoadingCard()),
            const SizedBox(width: AppConfig.mediumPadding),
            Expanded(child: _buildLoadingCard()),
            const SizedBox(width: AppConfig.mediumPadding),
            Expanded(child: _buildLoadingCard()),
          ],
        ),
        const SizedBox(height: AppConfig.standardPadding),
        Row(
          children: [
            Expanded(child: _buildLoadingCard()),
            const SizedBox(width: AppConfig.mediumPadding),
            Expanded(child: _buildLoadingCard()),
            const SizedBox(width: AppConfig.mediumPadding),
            Expanded(child: _buildLoadingCard()),
          ],
        ),
      ],
    );
  }
  
  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(AppConfig.standardPadding),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 80,
            height: 12,
            child: LinearProgressIndicator(),
          ),
          SizedBox(height: AppConfig.smallPadding),
          SizedBox(
            width: 60,
            height: 16,
            child: LinearProgressIndicator(),
          ),
        ],
      ),
    );
  }
}

class _EmptyGrid extends StatelessWidget {
  const _EmptyGrid();
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConfig.extraLargePadding),
      child: const Text(
        'Select a session to view analytics',
        style: TextStyle(color: Colors.grey, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}
```

### Event Breakdown Chart (`lib/widgets/event_breakdown_chart.dart`)
```dart
class EventBreakdownChart extends StatelessWidget {
  final SessionKPIs? kpis;
  
  const EventBreakdownChart({
    super.key,
    this.kpis,
  });
  
  @override
  Widget build(BuildContext context) {
    if (kpis == null) {
      return Container(
        padding: const EdgeInsets.all(AppConfig.standardPadding),
        child: const Text(
          'Select a session to view event breakdown',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    final events = [
      {'type': 'HIT', 'count': kpis!.deaths, 'color': Colors.red},
      {'type': 'KILL', 'count': kpis!.kills, 'color': Colors.amber},
      {'type': 'SPAWN', 'count': kpis!.spawns, 'color': Colors.green},
    ];
    
    final maxCount = events.map((e) => e['count'] as int).fold(0, (a, b) => a > b ? a : b);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Breakdown',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConfig.largePadding),
        ...events.map((event) => Padding(
          padding: const EdgeInsets.only(bottom: AppConfig.mediumPadding),
          child: _buildEventRow(
            event['type'] as String,
            event['count'] as int,
            event['color'] as Color,
            maxCount,
          ),
        )),
      ],
    );
  }
  
  Widget _buildEventRow(String eventType, int count, Color color, int maxCount) {
    return Row(
      children: [
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: AppConfig.mediumPadding),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
          ),
          child: Text(
            eventType,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: AppConfig.standardPadding),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: maxCount > 0 ? count / maxCount : 0,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConfig.mediumPadding),
        Text(
          count.toString(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
```

## 4. Insights Screen Redesign

### Updated Insights Screen (`lib/screens/insights_screen.dart`)
```dart
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  final DatabaseService _databaseService = DatabaseService();
  
  List<SessionSummary> _sessions = [];
  String? _selectedSessionId;
  SessionKPIs? _currentKPIs;
  bool _isLoadingSessions = true;
  bool _isLoadingKPIs = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      setState(() {
        _isLoadingSessions = true;
        _errorMessage = null;
      });
      
      final sessions = await _databaseService.getSessionSummaries();
      
      setState(() {
        _sessions = sessions;
        _isLoadingSessions = false;
        
        // Auto-select the most recent session if available
        if (sessions.isNotEmpty && _selectedSessionId == null) {
          _selectedSessionId = sessions.first.sessionId;
          _loadKPIsForSession(_selectedSessionId!);
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingSessions = false;
        _errorMessage = 'Failed to load sessions: $e';
      });
    }
  }

  Future<void> _loadKPIsForSession(String sessionId) async {
    try {
      setState(() {
        _isLoadingKPIs = true;
        _errorMessage = null;
      });
      
      final kpis = await _analyticsService.calculateSessionKPIs(sessionId);
      
      setState(() {
        _currentKPIs = kpis;
        _isLoadingKPIs = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingKPIs = false;
        _errorMessage = 'Failed to calculate analytics: $e';
      });
    }
  }

  void _onSessionSelected(String sessionId) {
    setState(() {
      _selectedSessionId = sessionId;
      _currentKPIs = null;
    });
    _loadKPIsForSession(sessionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      extendBody: false,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Insights', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadSessions,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(AppConfig.standardPadding),
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Selector
            SessionSelector(
              sessions: _sessions,
              selectedSessionId: _selectedSessionId,
              onSessionSelected: _onSessionSelected,
              isLoading: _isLoadingSessions,
            ),
            
            const SizedBox(height: AppConfig.extraLargePadding),
            
            // Error Message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(AppConfig.standardPadding),
                margin: const EdgeInsets.only(bottom: AppConfig.standardPadding),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: AppConfig.mediumPadding),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            
            // KPI Cards
            KPICardsGrid(
              kpis: _currentKPIs,
              isLoading: _isLoadingKPIs,
            ),
            
            const SizedBox(height: AppConfig.extraLargePadding),
            
            // Event Breakdown
            Expanded(
              child: SingleChildScrollView(
                child: EventBreakdownChart(kpis: _currentKPIs),
              ),
            ),
            
            // Navigation hint
            const Center(
              child: Text(
                'Swipe left/right to navigate',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 5. Implementation Tasks

### Phase 1: Models and Database Enhancement
1. **Create new data models**:
   - `SessionSummary` model (`lib/models/session_summary.dart`)
   - `SessionKPIs` model (`lib/models/session_kpis.dart`)

2. **Enhance DatabaseService**:
   - Add `getSessionSummaries()` method
   - Add `getEventsBySessionIds()` method

### Phase 2: Analytics Service
1. **Create AnalyticsService** (`lib/services/analytics_service.dart`):
   - Implement distance calculation using Haversine formula
   - Implement KPI calculations (duration, kills, deaths, K/D ratio)
   - Implement session validation and completeness checking
   - Add comprehensive error handling
   - **Future-ready design**: Structure data for mapping, trends, and AI analysis
   - Include placeholder methods for extended metrics and trend calculations

### Phase 3: UI Components
1. **Create reusable widgets**:
   - `SessionSelector` widget
   - `KPICardsGrid` widget  
   - `EventBreakdownChart` widget

2. **Design considerations**:
   - Loading states for all components
   - Empty states when no data available
   - Error states with retry options
   - Consistent dark theme styling
   - **Navigation hooks**: Prepare UI for future feature navigation
   - **Extensible layout**: Design to accommodate additional features

### Phase 4: Screen Integration
1. **Rebuild InsightsScreen**:
   - Integrate all new components
   - Add state management for session selection
   - Implement loading and error handling
   - Add refresh functionality
   - **Future feature placeholders**: Include disabled buttons/previews for upcoming features
   - **Navigation preparation**: Add method stubs for future feature navigation

### Phase 5: Testing and Polish
1. **Unit tests**:
   - Analytics calculations (distance, duration, K/D ratio)
   - Data model serialization/deserialization
   - Database query methods
   - **Extended metrics validation**: Test placeholder methods for future features

2. **Integration tests**:
   - End-to-end session selection workflow
   - Analytics calculation with real data
   - Error handling scenarios
   - **Future compatibility**: Ensure data structures support upcoming features

3. **Performance optimization**:
   - Caching for frequently accessed data
   - Background processing for heavy calculations
   - Memory management for large datasets
   - **Scalability**: Optimize for future multi-session analysis and mapping data

## 6. Key Algorithms

### Haversine Distance Calculation
```dart
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371000; // Earth's radius in meters
  
  final double dLat = _toRadians(lat2 - lat1);
  final double dLon = _toRadians(lon2 - lon1);
  
  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * 
      sin(dLon / 2) * sin(dLon / 2);
  
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}
```

### Session Completeness Check
```dart
bool _isCompleteSession(List<GameEvent> events) {
  return events.any((e) => e.eventType == 'START') &&
         events.any((e) => e.eventType == 'STOP');
}
```

## 7. Error Handling & Edge Cases

### Data Validation
- **Empty sessions**: Show appropriate empty states
- **Incomplete sessions**: Handle sessions without STOP events
- **Single event sessions**: Gracefully handle minimal data
- **Corrupted data**: Validate GPS coordinates and timestamps

### GPS Accuracy Filtering
- Filter out location events with accuracy > 20 meters for distance calculations
- Handle missing or invalid GPS data gracefully
- Provide fallback calculations when GPS data is unreliable

### Performance Considerations
- **No session limits**: Handle potentially large numbers of sessions efficiently
- **Lazy loading**: Load session summaries quickly, calculate detailed analytics on demand
- **Memory management**: Dispose of heavy objects when switching sessions
- **Background processing**: Calculate analytics without blocking UI

## 8. User Experience Features

### Loading States
- Skeleton loading for KPI cards
- Progress indicators for data fetching
- Smooth transitions between states

### Error Recovery
- Retry buttons for failed operations
- Clear error messages with actionable guidance
- Graceful degradation when partial data is available

### Accessibility
- Screen reader support for all analytics data
- High contrast colors for visual elements
- Keyboard navigation support

## 9. Future Enhancements & Integration Readiness

### Mapping Feature Integration
Our current implementation provides a solid foundation for the upcoming mapping feature:

**Data Structures Ready:**
- `SessionKPIs.locationEvents` - Contains all GPS coordinates for route visualization
- `SessionKPIs.movementPath` - Preprocessed LatLng list for mapping libraries
- `getLocationEventsForMapping()` - Optimized database query for map data
- Haversine distance calculation - Ready for route drawing and zone analysis

**Future Mapping Capabilities:**
- **Route Visualization**: Plot player movement path on interactive maps
- **Heat Maps**: Show activity intensity across different areas
- **Zone Analysis**: Identify hotspots, safe zones, and tactical positions
- **Multi-Session Overlay**: Compare movement patterns across sessions

### Time Trends Analysis Integration
The analytics service is structured to support comprehensive trend analysis:

**Trend-Ready Data:**
- `calculateTrendMetrics()` - Framework for multi-session analysis
- `getSessionsByDateRange()` - Time-based session filtering
- `SessionKPIs.hourlyActivity` - Temporal pattern data
- `SessionKPIs.rawMetrics` - Extensible metrics storage for trend calculations

**Future Trend Capabilities:**
- **Performance Evolution**: Track K/D ratio, distance, and accuracy improvements
- **Tactical Development**: Analyze changes in movement patterns and engagement styles
- **Seasonal Analysis**: Identify performance variations over time
- **Comparative Benchmarking**: Compare against historical performance

### AI-Powered Analysis Integration
Extended metrics collection prepares for AI-driven insights:

**AI-Ready Metrics:**
- `SessionKPIs.combatEvents` - Combat pattern data for tactical analysis
- Extended metrics: movement intensity, combat frequency, spatial distribution
- Reaction times and engagement duration data
- Temporal and spatial pattern recognition data

**Future AI Capabilities:**
- **Tactical Recommendations**: AI-suggested improvements based on performance patterns
- **Opponent Analysis**: Pattern recognition for competitive advantages
- **Skill Assessment**: Automated evaluation of tactical skills and decision-making
- **Predictive Analytics**: Forecast performance trends and optimal strategies

### Data Architecture Benefits
The current design provides several advantages for future features:

1. **Extensible Models**: `SessionKPIs.rawMetrics` allows adding new metrics without schema changes
2. **Efficient Queries**: Database methods optimized for batch processing and date ranges
3. **Modular Analytics**: Separate service layer enables easy extension for specialized analysis
4. **Future-Proof Navigation**: UI includes placeholder navigation for upcoming features
5. **Scalable Data Processing**: Performance optimizations support complex multi-session analysis

### Implementation Considerations for Future Features

**Mapping Feature:**
- Leverage existing location event structure
- Reuse distance calculation algorithms
- Extend UI components for map integration
- Utilize cached location data for performance

**Time Trends Feature:**
- Build upon session date filtering
- Extend analytics service trend methods
- Create new visualization components
- Implement data aggregation strategies

**AI Analysis Feature:**
- Utilize extended metrics collection
- Implement machine learning data pipelines
- Create AI insight presentation components
- Develop recommendation engines

This foundation ensures smooth integration of upcoming features while maintaining code quality and performance standards.

# Telemetry Data Collection Implementation Plan

## Overview
This document outlines the implementation plan for the telemetry data collection system in the Airsoft Telemetry Flutter application. The system will capture location data at configurable intervals, record game events with GPS coordinates, and provide data export capabilities.

## Current State Analysis
- ✅ Flutter project structure is established
- ✅ Basic UI screens (Home, Settings, Navigation) exist
- ✅ Location service with GPS access is implemented
- ✅ Game event model is defined
- ✅ SharedPreferences dependency is available
- ❌ No database implementation for persistent storage
- ❌ No preferences persistence (settings reset on app restart)
- ❌ No telemetry data collection or session management
- ❌ No event logging or CSV export functionality

## Implementation Plan

### 1. Database Layer
**Create Database Service** (`lib/services/database_service.dart`)
- Set up SQLite database with table for game events
- Schema: `id`, `gameSessionId`, `playerId`, `eventType`, `timestamp`, `latitude`, `longitude`, `altitude`, `azimuth`, `speed`, `accuracy`
- CRUD operations: insert, query, delete/clear
- Database initialization and migration support

**Database Schema:**
```sql
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
);
```

### 2. Telemetry Service
**Create Telemetry Service** (`lib/services/telemetry_service.dart`)
- Manage game session state (start/pause/resume/stop)
- Handle periodic location snapshots based on user interval setting
- Integrate with LocationService for position data
- Record events (HIT, SPAWN, KILL) with current location
- Generate unique session IDs using timestamps
- Stream session status and recent events for UI updates

**Key Features:**
- Session lifecycle management
- Configurable interval-based location tracking (1s-60s)
- Event recording with GPS coordinates
- Real-time position updates
- Session persistence across app lifecycle

### 3. Preferences Service
**Create Preferences Service** (`lib/services/preferences_service.dart`)
- Save/load player name and interval settings using SharedPreferences
- Provide settings persistence across app restarts
- Default value handling
- Settings validation

**Persistent Settings:**
- Player name (String)
- Update interval (String: '1s', '2s', '3s', '4s', '5s', '10s', '30s', '60s')

### 4. Enhanced Location Tracking
**Update LocationService** (`lib/services/location_service.dart`)
- Add configurable interval support based on user preferences
- Capture all available Position object metrics:
  - Latitude, Longitude
  - Altitude
  - Azimuth/Heading
  - Speed
  - Accuracy
- Stream position updates for continuous tracking
- Handle permission management

### 5. UI Integration

#### Update HomeScreen (`lib/screens/home_screen.dart`)
- Connect START button to telemetry service
- Add PAUSE/RESUME and STOP functionality
- Event buttons (HIT/SPAWN/KILL) record events with current location
- Show session status and tracking state
- Display current location data
- Handle session state changes

**UI States:**
- **Stopped**: Show START button, event buttons start new session
- **Running**: Show PAUSE and STOP buttons, event buttons enabled
- **Paused**: Show RESUME and STOP buttons, event buttons disabled

#### Update SettingsScreen (`lib/screens/settings_screen.dart`)
- Save/load preferences using PreferencesService
- Display real-time event log with lat/lng/altitude for each observation
- Connect Export Data and Clear Data buttons to database operations
- Show current session statistics
- Real-time location updates

**Event Log Format:**
```
HIT -- Lat: 40.7128, Lng: -74.0060, Alt: 10.5m @ 14:30:25
LOCATION -- Lat: 40.7129, Lng: -74.0061, Alt: 10.8m @ 14:30:27
SPAWN -- Lat: 40.7130, Lng: -74.0062, Alt: 11.0m @ 14:30:45
```

### 6. Data Export
**Add CSV Export** (`lib/services/export_service.dart`)
- Export all stored events to CSV format
- Include all telemetry fields (timestamp, coordinates, event type, etc.)
- Use platform file picker for save location
- CSV format with headers

**CSV Structure:**
```csv
ID,Session ID,Player ID,Event Type,Timestamp,Date/Time,Latitude,Longitude,Altitude,Azimuth,Speed,Accuracy
1,session_123,Player 1,START,1703434225000,2023-12-24 14:30:25,40.7128,-74.0060,10.5,45.2,0.0,3.5
2,session_123,Player 1,LOCATION,1703434227000,2023-12-24 14:30:27,40.7129,-74.0061,10.8,45.8,1.2,3.2
```

### 7. State Management
**Add Session State Management**
- Track current session status across screens
- Ensure data consistency between UI and services
- Handle app lifecycle (pause/resume/background)
- Provide reactive state updates to UI components

### 8. Key Features Implementation

#### ✅ Interval-based Location Snapshots
- User configurable intervals: 1s, 2s, 3s, 4s, 5s, 10s, 30s, 60s
- Automatic location recording during active sessions
- Event type: 'LOCATION' for automatic snapshots

#### ✅ Event Recording with GPS Coordinates
- Manual events: HIT, SPAWN, KILL
- Automatic events: START, PAUSE, RESUME, STOP, LOCATION
- All events include current position data

#### ✅ Session Management
- Unique session IDs (timestamp-based)
- Start/pause/resume/stop functionality
- Session persistence and recovery

#### ✅ Persistent Storage
- SQLite database for game events
- SharedPreferences for user settings
- Data integrity and error handling

#### ✅ Settings Persistence
- Player name and interval saved automatically
- Settings loaded on app startup
- Default value fallbacks

#### ✅ Real-time Event Log
- Display recent events with location data
- Show lat, lng, altitude for each observation
- Real-time updates during active sessions

#### ✅ CSV Data Export
- Export all events with complete metrics
- Platform-native file saving
- Human-readable timestamp formatting

#### ✅ Dark Theme UI
- Battery-optimized dark mode interface
- Consistent with existing design
- Clear visual feedback for session states

### 9. File Structure
```
lib/
├── services/
│   ├── database_service.dart      # SQLite operations
│   ├── telemetry_service.dart     # Core telemetry logic
│   ├── preferences_service.dart   # Settings persistence
│   ├── export_service.dart        # CSV export functionality
│   ├── location_service.dart      # Enhanced location tracking
│   └── app_config.dart           # Constants and config
├── models/
│   └── game_event.dart           # Data model (exists)
└── screens/
    ├── home_screen.dart          # Enhanced with telemetry controls
    ├── settings_screen.dart      # Enhanced with event log
    └── main_navigation_screen.dart # Navigation (exists)
```

### 10. Implementation Order
1. **Database Service**: Create SQLite database with game events table
2. **Preferences Service**: Implement settings persistence with SharedPreferences
3. **Enhanced Location Service**: Add configurable intervals and comprehensive position data
4. **Telemetry Service**: Core session management and event recording
5. **Home Screen Integration**: Connect UI controls to telemetry service
6. **Settings Screen Enhancement**: Add event log display and preferences integration
7. **Export Service**: Implement CSV export functionality
8. **Data Management**: Add clear data functionality
9. **Testing**: End-to-end workflow validation
10. **Polish**: Error handling, edge cases, and user experience improvements

### 11. Technical Considerations

#### Performance
- Efficient database operations with proper indexing
- Stream-based reactive updates to minimize UI rebuilds
- Background location tracking optimization

#### Battery Life
- Dark theme for OLED displays
- Configurable update intervals to balance accuracy vs. battery life
- Efficient GPS usage patterns

#### Data Integrity
- Transaction-based database operations
- Proper error handling and recovery
- Data validation at service boundaries

#### User Experience
- Clear visual feedback for session states
- Intuitive controls and status indicators
- Responsive UI updates without blocking

## Success Criteria
- ✅ User can start/pause/resume/stop telemetry sessions
- ✅ Location data is captured at user-configured intervals
- ✅ Events (HIT/SPAWN/KILL) are recorded with GPS coordinates
- ✅ Settings persist across app restarts
- ✅ Event log displays real-time telemetry data with lat/lng/altitude
- ✅ Data can be exported to CSV format
- ✅ All data can be cleared when needed
- ✅ UI provides clear feedback on session status
- ✅ App maintains dark theme and battery optimization

## Dependencies
- `sqflite: ^2.3.3` - SQLite database
- `shared_preferences: ^2.2.3` - Settings persistence
- `geolocator: ^12.0.0` - GPS location services
- `csv: ^6.0.0` - CSV export functionality
- `path_provider: ^2.1.3` - File system access

All dependencies are already included in `pubspec.yaml`.

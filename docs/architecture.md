# Architecture Overview

## **Service Layer Architecture**
```
┌───────────────────────────────────────────────────────────────┐
│                       Presentation Layer                      │
│   ┌───────────────┐   ┌───────────────┐   ┌─────────────────┐ │
│   │   HomeScreen  │   │   SettingsUI  │   │  InsightsScreen │ │
│   └───────────────┘   └───────────────┘   └─────────────────┘ │
└───────────────────────────────────────────────────────────────┘
                               │
┌───────────────────────────────────────────────────────────────┐
│                        Service Layer                          │
│   ┌───────────────┐   ┌───────────────┐   ┌─────────────────┐ │
│   │   Telemetry   │   │   Location    │   │    Database     │ │
│   │   Service     │◄──│   Service     │◄──│    Service      │ │
│   └───────────────┘   └───────────────┘   └─────────────────┘ │
│           │                                   │               │
│   ┌───────────────┐   ┌───────────────┐   ┌─────────────────┐ │
│   │  Preferences  │   │    Export     │   │   App Config    │ │
│   │   Service     │   │    Service    │   │                 │ │
│   └───────────────┘   └───────────────┘   └─────────────────┘ │
└───────────────────────────────────────────────────────────────┘
                               │
┌───────────────────────────────────────────────────────────────┐
│                         Data Layer                            │
│   ┌───────────────┐   ┌───────────────┐   ┌─────────────────┐ │
│   │   SQLite DB   │   │  SharedPrefs  │   │   File System   │ │
│   └───────────────┘   └───────────────┘   └─────────────────┘ │
└───────────────────────────────────────────────────────────────┘
```

## **Key Components**

### **Service Layer**
- **TelemetryService**: Core session management, event recording, and location tracking coordination
- **LocationService**: High-precision GPS operations with configurable intervals  
- **DatabaseService**: SQLite operations with optimized schema and indexing
- **PreferencesService**: User settings persistence and validation
- **ExportService**: CSV generation and platform-specific file operations

### **Data Models**
- **GameEvent Model**: Comprehensive data model with complete position metrics

## **Data Flow Architecture**

### **Telemetry Data Flow**
```
User Action → UI Screen → TelemetryService → LocationService → DatabaseService
     ↓              ↓            ↓               ↓               ↓
  Button Press → State Update → Event Creation → GPS Capture → SQLite Storage
     ↓              ↓            ↓               ↓               ↓
  CSV Export ← ExportService ← DatabaseService ← Query Events ← File System
```

### **Key Data Flows**
1. **Session Management**: User starts session → TelemetryService coordinates → LocationService begins GPS tracking → Events stored via DatabaseService
2. **Event Recording**: User taps HIT/SPAWN/KILL → Current GPS position captured → GameEvent created with coordinates → Stored in SQLite
3. **Data Export**: User exports session → DatabaseService queries events → ExportService generates CSV → File saved to device storage
4. **Settings Persistence**: User changes settings → PreferencesService validates → SharedPreferences storage → App restarts with new config

## **Domain Model (Airsoft-Specific)**

### **Core Entities**
- **Session**: Represents a complete Airsoft game session with timestamp-based unique IDs (format: `session_${timestamp}`)
- **GameEvent**: Individual events during gameplay (HIT, SPAWN, KILL, LOCATION, START, STOP, PAUSE, RESUME)
- **Location Data**: GPS coordinates with accuracy, altitude, speed, and azimuth
- **Player Context**: Session-specific player identification and configuration

### **Business Rules**
- Sessions use timestamp-based unique IDs for data integrity (format: `session_${DateTime.now().millisecondsSinceEpoch}`)
- Location events generated automatically at configured intervals (1-60 seconds) during active sessions only
- Manual events (HIT/SPAWN/KILL) always capture current GPS position and auto-start session if stopped
- All events timestamped with millisecond precision using `DateTime.now().millisecondsSinceEpoch`
- Events cannot be recorded during paused state (except RESUME events)
- NaN values from GPS sensors are converted to null before database storage

## **State Management Strategy**

### **UI State**
- **Flutter StatefulWidgets** for screen-level state management
- **Stream-based updates** from services for real-time data
- **Reactive UI patterns** that respond to service state changes via StreamSubscription listeners

### **Service State**
- **TelemetryService**: Maintains session state, active tracking status, and stream controllers for reactive updates
- **LocationService**: Manages GPS subscription and current position with Timer-based periodic tracking
- **DatabaseService**: Stateless - provides data access operations with SQLite backend
- **Singleton pattern** for service instances to ensure consistent state across the application

### **Repository Structure**
```
lib/
├── main.dart                    # Application entry point and app configuration
├── models/
│   └── game_event.dart         # Core data model with GPS and event data
├── screens/
│   ├── home_screen.dart        # Main tracking interface with start/stop controls
│   ├── insights_screen.dart    # Analytics and performance metrics (in development)
│   ├── main_navigation_screen.dart # Bottom navigation and screen coordination
│   └── settings_screen.dart    # Configuration for GPS intervals and preferences
├── services/
│   ├── app_config.dart         # Application-wide configuration constants
│   ├── database_service.dart   # SQLite operations and schema management
│   ├── export_service.dart     # CSV generation and file system operations
│   ├── location_service.dart   # GPS tracking and coordinate management
│   ├── preferences_service.dart # User settings persistence via SharedPreferences
│   └── telemetry_service.dart  # Core session management and event coordination
└── utils/
    ├── location_formatter.dart # GPS coordinate formatting utilities
    └── measure_formatter.dart  # Distance and measurement formatting

test/                           # Unit tests mirroring lib/ structure
integration_test/               # End-to-end testing for complete workflows
android/                        # Android-specific platform configuration
ios/                           # iOS-specific platform configuration
docs/                          # Project documentation and guides
```

## **Key Technologies & Dependencies**
- **Flutter SDK**: 3.4.3+ with Dart 3.0+
- **Database**: SQLite via `sqflite` package for local data storage
- **Location Services**: `geolocator` package for GPS tracking
- **Permissions**: `permission_handler` for runtime permissions
- **Storage**: `shared_preferences` for user settings, `path_provider` for file paths
- **Data Export**: `csv` package for telemetry data export

## **Architecture Patterns**

### **Service-Based Architecture**
- Keep business logic in service classes (`lib/services/`)
- Use proper separation of concerns between UI and business logic
- Maintain consistent error handling patterns
- Services communicate through dependency injection

### **Error Handling Strategy**
- **Service Level**: Simple try-catch patterns with graceful error handling and null return values
- **UI Level**: Basic error messages displayed via SnackBar widgets when operations fail
- **GPS Errors**: Silent error handling with null position returns when location unavailable
- **Database Errors**: Direct exceptions thrown with basic try-catch in UI components
- **Permission Errors**: Null returns from location service when permissions denied

### **Testing Architecture**
```
Unit Tests (test/)
├── Service Tests: Mocktail-based testing with async/await patterns
├── Model Tests: JSON serialization and data validation testing  
├── Stream Tests: Event emission and subscription behavior verification
└── Error Tests: Exception throwing and null handling validation

Integration Tests (integration_test/)
├── End-to-End Workflows: Complete user journeys with real services
├── Database Integration: SQLite operations with actual database instances
├── Location Integration: GPS testing with device location services
└── Export Integration: File system operations and CSV generation testing
```

**Testing Patterns:**
- **Mocking**: Extensive use of `mocktail` package for service dependencies
- **Stream Testing**: `expectLater()` with `emitsInOrder()` for reactive state verification
- **Async Testing**: Comprehensive `async/await` testing with timeout handling
- **Null Safety**: Explicit testing of null position handling and graceful degradation

### **Database & Storage**
- All persistent data should use the `DatabaseService` 
- Location data should be handled through `LocationService`
- User preferences should use `PreferencesService`
- Follow existing schema patterns for database tables

### **Performance Considerations**

#### **Battery Optimization**
- **Configurable GPS intervals**: 1-60 seconds to balance accuracy vs battery life
- **Location accuracy settings**: Use `LocationAccuracy.high` for Airsoft precision needs
- **Background processing**: Minimize wake locks and CPU usage during tracking
- **Screen optimization**: Dark theme reduces battery drain on OLED displays

#### **Memory & Storage**
- **Efficient data caching**: Stream caching in TelemetryService for UI reactivity
- **Database optimization**: Indexed queries for session and event lookups
- **Bulk operations**: Batch database writes for better performance
- **File system**: Async operations for CSV export to prevent UI blocking

#### **GPS & Location Tracking**
- **Permission handling**: Graceful degradation when location access denied
- **Accuracy validation**: Filter out low-accuracy GPS readings (>10 meters)
- **Outdoor optimization**: Settings tuned for typical Airsoft field environments
- **Data validation**: Sanity checks on speed, altitude, and coordinate ranges

#### **Real-time Responsiveness**
- **Stream-based architecture**: Immediate UI updates for location and event changes
- **Async operations**: All database and file operations run asynchronously
- **Error recovery**: Automatic retry mechanisms for transient failures
- **Session persistence**: App state survives background/foreground transitions

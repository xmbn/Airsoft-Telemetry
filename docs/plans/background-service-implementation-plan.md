# Background Service Implementation Plan

**Date**: July 2, 2025  
**Objective**: Implement background service for continuous telemetry data collection

## Current State Analysis

Your current implementation uses:
- **Timer-based location tracking** in `TelemetryService`
- **Foreground-only** operation (stops when app is backgrounded)
- **SQLite local storage** with reactive streams
- **Location permissions** already configured (including `ACCESS_BACKGROUND_LOCATION`)

## Proposed Architecture: Background Service + Foreground Coordinator

**Core Concept**: Always use a background service for location collection while the foreground app receives the data.

### Why This Approach Works Best

1. **Continuous data collection** even when app is backgrounded/screen off
2. **Consistent timing intervals** not affected by app lifecycle
3. **Battery optimization** through proper background service management
4. **Data integrity** - no missed location points during app transitions
5. **Seamless user experience** - sessions continue regardless of app state

## Technical Architecture

### Service Communication Flow

```
Background Service          Foreground App
├─ LocationService         ├─ TelemetryService (coordinator)
├─ DatabaseService         ├─ UI Components
├─ Timer-based tracking    ├─ Stream listeners
├─ SQLite writes           ├─ Manual event injection
└─ Notification mgmt       └─ Service commands
```

### Data Flow

- **Background → Database**: Continuous location writes
- **Database → Foreground**: Real-time data streams for UI
- **Foreground → Background**: Service control commands via method channels (e.g., start/stop session, inject manual events)
- **Background → Database**: All database writes (location, manual events, etc.) to prevent concurrency issues

### Service Communication Mechanism

- **Method Channels**: For service control commands (start/stop, configuration)
- **Event Channels**: For real-time status updates from background to foreground
- **Database Streams**: For data synchronization between background and foreground
- **Shared Preferences**: For service state persistence across app restarts

### Database Concurrency Strategy

- **Single Writer Pattern**: Only the background service writes to the database
- **Connection Pool**: Use SQLite connection pooling to handle concurrent reads
- **Transaction Management**: Wrap all database operations in transactions for atomicity
- **Isolation Levels**: Use appropriate isolation levels to prevent read anomalies

## Implementation Components

### 1. Background Service Core

```dart
class BackgroundTelemetryService {
  // Location tracking in background
  // Direct database writes
  // Service lifecycle management
  // Notification handling
}
```

### 2. Modified TelemetryService

```dart
class TelemetryService {
  // Remove direct location tracking
  // Become coordinator between UI and background service
  // Handle session state management
  // Provide data streams from database
}
```

### 3. Required Dependencies

```yaml
flutter_background_service: ^5.0.5
flutter_background_service_android: ^6.2.2
flutter_background_service_ios: ^5.0.1
```

### 4. Platform Permissions

**Android**: Foreground service, wake lock, background location  
**iOS**: Background location modes, background processing. 
> **Note**: iOS background execution is more restrictive. The OS can still terminate the service under memory pressure. The implementation should account for service restoration.

### 5. Testing & Mocking Strategy

> Generalize this then create a separate testing plan after implementation

```dart
// Mock location data for testing
class MockLocationService extends LocationService {
  // Simulate GPS coordinates without requiring device permissions
  // Enable automated testing of background service behavior
  // Test service lifecycle without actual background processing
}

// Integration test examples
- Service start/stop functionality
- Data persistence during app lifecycle changes
- Background service restoration after system termination
- Mock location data collection and database writes
```

## Key Technical Decisions

### Service Type

- Use **Foreground Service** with persistent notification
- Ensures continuous operation and user awareness
- Complies with modern Android/iOS background restrictions

### Data Architecture

- **Single SQLite database** shared between foreground and background
- **Background service** handles all location writes
- **Foreground app** handles UI updates and manual events

### Battery Optimization

- **Intelligent interval scaling**: Reduce location polling frequency when the device is stationary (detected via accelerometer) and increase it when motion is detected.
- Proper service lifecycle management
- Battery optimization exclusion requests

### Error Handling and Resilience

- **Permission Failures**: Gracefully handle cases where background location permission is denied or revoked mid-session. The service should stop and notify the user.
- **Sensor/GPS Failures**: Log errors if the location provider fails. Implement a retry mechanism with backoff.
- **Database Errors**: All database operations should be wrapped in try/catch blocks. Failures should be logged for debugging.
- **Service Crashes**: The service should be configured to restart automatically if the OS or an unhandled exception terminates it.

> create an error logging service that can be shared by user in a future feature update

### User Experience

- Persistent notification showing session status
- Seamless foreground/background transitions
- Service control from notification actions

### Notification Actions

- **Pause/Resume**: Toggle data collection without stopping the service
- **Stop Session**: End current session and stop background service
- **View Status**: Display current session metrics (time, locations recorded)
- **Quick Settings**: Access key service settings from notification

> there is too much here let's just have start stop pause resume and number of events in current session. it should also link back to the app

### iOS Background Limitations & Fallback Strategy

- **Background App Refresh**: Requires user permission and can be disabled
- **Memory Pressure**: iOS may terminate background services under low memory conditions
- **Fallback Strategy**: 
  - Detect service termination and attempt automatic restart
  - Notify user when background execution is restricted
  - Provide alternative "screen-on" mode for critical sessions
  - Log service interruptions for debugging and user awareness

## Implementation Strategy

### Phase 1: Foundation

- Add background service dependencies
- Create basic service structure
- Implement service start/stop mechanism

### Phase 2: Location Migration

- Move location tracking to background service
- Implement background database writes
- Add service communication layer

### Phase 3: Integration

- Modify TelemetryService to coordinate with background service
- Update UI to reflect background service state
- Handle app lifecycle transitions

### Phase 4: Optimization

- Battery usage optimization
- Service lifecycle testing
- Performance benchmarking

> insert a testing phase

### Phase 5: Documentation & Export Compatibility

- Update project documentation in `docs/` folder
- Update README.md with new service architecture
- Ensure CSV export compatibility with background data flow
- Document new service APIs and user-facing changes

## Expected Outcomes

### Immediate Benefits

- ✅ **Continuous telemetry** regardless of app state
- ✅ **Improved session reliability** during phone calls, notifications
- ✅ **Better user experience** with uninterrupted tracking
- ✅ **Professional-grade** data collection capability

### Technical Achievements

- ✅ **Robust background processing** architecture
- ✅ **Efficient battery usage** through proper service management
- ✅ **Scalable design** for future feature additions
- ✅ **Platform-optimized** implementation

## Next Steps

This approach transforms your app into a professional-grade background data collection system suitable for serious airsoft gaming scenarios where continuous tracking is essential.

**Ready for implementation** - all components are well-defined and can be implemented incrementally without breaking existing functionality.

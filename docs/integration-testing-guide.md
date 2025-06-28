# Integration Test Guide

This document provides instructions for running integration tests for the Airsoft Telemetry Flutter project.

## Over### Expected Test Results

### DatabaseService Integration:
- ✅ All CRUD operations work correctly
- ✅ Data persists between operations
- ✅ Complex queries filter properly (session-based, event type filtering)
- ✅ Null handling works correctly
- ✅ Event ordering works (timestamp DESC)
- ✅ Event counting and batch operations

### LocationService Integration:
- ✅ GPS position acquired (if permissions granted)
- ✅ Position streams work with real data
- ✅ Graceful permission handling
- ✅ Coordinate validation within expected ranges (-90/90 lat, -180/180 lng)
- ✅ Position metadata (accuracy, altitude, speed, heading) populated
- ⚠️ May fail if location services disabled
- ⚠️ May timeout on first run while acquiring GPS fix

### ExportService Integration:
- ✅ Export statistics generated correctly
- ✅ CSV files created with proper formatting
- ✅ Data aggregation and filtering work
- ✅ File operations complete successfully
- ✅ Export workflow handles edge cases

### TelemetryService Integration:
- ✅ Complete session workflows work
- ✅ Events are recorded correctly with proper session association
- ✅ Streams notify subscribers
- ✅ Auto-start functionality works
- ✅ Settings updates apply correctly
- ✅ Session state management (start/pause/resume/stop)
- ✅ Event caching and persistencehas four categories of integration tests:

1. **DatabaseService Integration Tests** - Test real database operations
2. **LocationService Integration Tests** - Test real GPS functionality  
3. **TelemetryService Integration Tests** - Test complete workflows and service interactions
4. **ExportService Integration Tests** - Test data export functionality and file operations

## Prerequisites

### For Android Device Testing:
1. Enable Developer Options on your Android device
2. Enable USB Debugging
3. Connect device via USB
4. Verify device is detected: `flutter devices`

### For Android Emulator Testing:
1. Start an Android emulator
2. Verify emulator is running: `flutter devices`

### For iOS Testing:
1. Use a physical iOS device or iOS Simulator
2. Ensure proper code signing and provisioning profiles

## Running Integration Tests

### 1. Database Service Integration Tests
Tests the SQLite database operations with real database instances.

```bash
# Run on connected device/emulator
flutter test integration_test/database_service_integration_test.dart

# Run with verbose output
flutter test integration_test/database_service_integration_test.dart --verbose
```

**What it tests:**
- Event insertion and retrieval
- Session-based filtering
- Data persistence
- Complex field handling
- Database lifecycle management

### 2. Location Service Integration Tests
Tests real GPS functionality and location permissions.

```bash
# Run on device (requires GPS capability)
flutter test integration_test/location_service_integration_test.dart
```

**Requirements:**
- Must run on physical device with GPS or emulator with location simulation
- Location permissions must be granted manually during test (if prompted)
- Requires active location services on the device

**What it tests:**
- Real GPS position acquisition with detailed coordinate validation
- Location permission handling and error states
- Position stream functionality and data accuracy
- App initialization with location services
- Position data fields validation (latitude, longitude, accuracy, altitude, speed, heading)
- Location service integration with real device sensors

### 3. ExportService Integration Tests
Tests data export functionality with real file operations and CSV generation.

```bash
# Run export service tests
flutter test integration_test/export_service_integration_test.dart
```

**What it tests:**
- Export statistics generation
- CSV file creation and formatting
- Data filtering and aggregation
- File system operations
- Export workflow validation

### 4. TelemetryService Integration Tests
Tests complete session workflows and service interactions.

```bash
# Run comprehensive telemetry workflow tests
flutter test integration_test/telemetry_service_integration_test.dart
```

**What it tests:**
- Complete session lifecycle (start/pause/resume/stop)
- Event recording and caching
- Stream notifications
- Auto-start functionality
- Location tracking integration
- Settings updates
- Data clearing operations

### 5. Run All Integration Tests
```bash
# Run all integration tests
flutter test integration_test/

# Run specific test by name pattern
flutter test integration_test/ --name "session lifecycle"
```

## Test Data Management

Integration tests create real data in the device's database. Each test:

1. **Setup**: Clears existing data before starting
2. **Execution**: Performs real operations  
3. **Cleanup**: Clears test data after completion

## Troubleshooting

### Common Issues:

**Device Not Found:**
```powershell
flutter devices
# If no devices, check USB connection or start emulator
```

**Permission Errors (Location Tests):**
- Grant location permissions manually when prompted
- Ensure location services are enabled on device
- For emulator: Enable location in extended controls

**Database Locked Errors:**
- Stop any running app instances before tests
- Restart device/emulator if persistence issues occur
- Clear app data if database corruption suspected

**Test Timeouts:**
- Location tests may take longer on first run (GPS acquisition)
- Increase timeout for slow devices or CI environments
- TelemetryService tests include timing-dependent operations

**Service Initialization Errors:**
- Ensure TelemetryService.initialize() completes before testing
- Check that all required permissions are granted
- Verify database is accessible and not locked by other processes

**Export Test Failures:**
- Check file system permissions for temp directory access
- Ensure sufficient storage space for CSV file creation
- Verify proper cleanup of temporary files

### Debug Mode:
```powershell
# Run with debug output
flutter test integration_test/telemetry_service_integration_test.dart --verbose --debug

# Debug specific test by name
flutter test integration_test/ --name "session lifecycle" --verbose

# Enable additional logging
flutter test integration_test/location_service_integration_test.dart --debug --verbose
```

### Platform-Specific Debugging:

**Android:**
- Use `flutter logs` to see system logs during test execution
- Check `adb logcat` for GPS and permission-related messages
- Verify GPS is enabled in emulator extended controls

**iOS:**
- Use Xcode Console for detailed system logs
- Check iOS Simulator location settings
- Verify proper code signing for device testing

## Expected Test Results

### DatabaseService Integration:
- ✅ All CRUD operations work correctly
- ✅ Data persists between operations
- ✅ Complex queries filter properly
- ✅ Null handling works correctly

### LocationService Integration:
- ✅ GPS position acquired (if permissions granted)
- ✅ Position streams work
- ✅ Graceful permission handling
- ⚠️ May fail if location services disabled

### TelemetryService Integration:
- ✅ Complete session workflows work
- ✅ Events are recorded correctly
- ✅ Streams notify subscribers
- ✅ Auto-start functionality works
- ✅ Settings updates apply correctly

## Performance Considerations

Integration tests are slower than unit tests because they:
- Use real databases and services
- Make actual GPS requests
- Perform real file I/O operations
- Wait for asynchronous operations
- Test complete service integrations

Typical execution times:
- DatabaseService: ~10-30 seconds
- LocationService: ~15-45 seconds (depends on GPS acquisition)
- ExportService: ~10-20 seconds
- TelemetryService: ~30-60 seconds (includes timing-dependent tests)

## CI/CD Integration

For automated testing in CI/CD pipelines:

```yaml
# Example GitHub Actions step
- name: Run Integration Tests
  run: |
    flutter test integration_test/database_service_integration_test.dart
    flutter test integration_test/export_service_integration_test.dart
    # Location and Telemetry tests may require emulator with location simulation
```

**Recommendations for CI/CD:**
- Run DatabaseService and ExportService tests in all environments
- LocationService tests require emulator with location simulation enabled
- TelemetryService tests may need longer timeouts in CI environments
- Consider splitting tests into separate jobs for parallel execution

Note: Location-dependent tests may require special emulator configuration in CI environments.

## Test Execution Patterns

### Test Isolation and Cleanup
All integration tests follow a consistent pattern for data isolation:

```bash
# Each test automatically:
# 1. Clears existing data in setUp()
# 2. Runs the test with fresh state
# 3. Cleans up test data in tearDown()
# 4. Properly closes resources in tearDownAll()
```

### Service Initialization
Integration tests properly initialize services:
- **DatabaseService**: Automatic initialization on first use
- **LocationService**: Requires permission handling
- **TelemetryService**: Explicit `initialize()` call required
- **ExportService**: Works with existing database data

### Test Data Patterns
Tests use realistic data patterns:
- **Session IDs**: Format like `integration_session_1`, `test_session_1`
- **Player IDs**: Format like `test_player_1`, `player_1`
- **Event Types**: `START`, `HIT`, `KILL`, `SPAWN`, `STOP`
- **Coordinates**: Realistic GPS coordinates (NYC area: 40.7128, -74.0060)
- **Timestamps**: Current time with offsets for ordering tests

## Windows-Specific Considerations

### PowerShell Commands
When running on Windows with PowerShell, use these commands:

```powershell
# Check available devices
flutter devices

# Run specific integration test
flutter test integration_test/database_service_integration_test.dart

# Run with verbose output for debugging
flutter test integration_test/database_service_integration_test.dart --verbose

# Run all integration tests
flutter test integration_test/
```

### Android Emulator on Windows
For Android emulator testing on Windows:

```powershell
# List available emulators
emulator -list-avds

# Start specific emulator
emulator -avd <emulator_name>

# Verify emulator is running
flutter devices
```

### File Paths and Export Testing
ExportService tests on Windows will:
- Use Windows-style file paths
- Create temporary files in the appropriate Windows temp directory
- Handle Windows file system permissions correctly

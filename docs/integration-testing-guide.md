# Integration Test Guide

This document provides instructions for running integration tests for the Airsoft Telemetry Flutter project.

## Overview

The project has three categories of integration tests:

1. **DatabaseService Integration Tests** - Test real database operations
2. **LocationService Integration Tests** - Test real GPS functionality  
3. **TelemetryService Integration Tests** - Test complete workflows and service interactions

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
- Location permissions may need to be granted manually during test

**What it tests:**
- Real GPS position acquisition
- Location permission handling
- Position stream functionality
- App initialization with location services

### 3. TelemetryService Integration Tests
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

### 4. Run All Integration Tests
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
```bash
flutter devices
# If no devices, check USB connection or start emulator
```

**Permission Errors (Location Tests):**
- Grant location permissions manually when prompted
- Ensure location services are enabled on device

**Database Locked Errors:**
- Stop any running app instances before tests
- Restart device/emulator if persistence issues occur

**Test Timeouts:**
- Location tests may take longer on first run
- Increase timeout if needed for slow devices

### Debug Mode:
```bash
# Run with debug output
flutter test integration_test/telemetry_service_integration_test.dart --verbose --debug
```

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

Typical execution times:
- DatabaseService: ~10-30 seconds
- LocationService: ~15-45 seconds (depends on GPS acquisition)
- TelemetryService: ~30-60 seconds (includes timing-dependent tests)

## CI/CD Integration

For automated testing in CI/CD pipelines:

```yaml
# Example GitHub Actions step
- name: Run Integration Tests
  run: |
    flutter test integration_test/database_service_integration_test.dart
    # Location and Telemetry tests may require emulator with location simulation
```

Note: Location-dependent tests may require special emulator configuration in CI environments.

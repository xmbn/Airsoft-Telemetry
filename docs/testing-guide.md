# Flutter Testing Guide

This guide covers best practices for testing Flutter applications, including unit tests, widget tests, and integration tests.

## Table of Contents

- [Testing Types Overview](#testing-types-overview)
- [Project Structure](#project-structure)
- [Unit Tests](#unit-tests)
- [Widget Tests](#widget-tests)
- [Integration Tests](#integration-tests)
- [Test Configuration](#test-configuration)
- [VS Code Setup](#vs-code-setup)
- [Running Tests](#running-tests)
- [Best Practices](#best-practices)

## Testing Types Overview

### Unit Tests
- **Purpose**: Test individual functions, methods, and classes in isolation
- **Speed**: Very fast (milliseconds)
- **Dependencies**: Use mocks to isolate code under test
- **Device Required**: No
- **When to Use**: Testing business logic, data models, services

### Widget Tests
- **Purpose**: Test UI components and their interactions
- **Speed**: Fast (seconds)
- **Dependencies**: Test widgets in isolation with mocked dependencies
- **Device Required**: No
- **When to Use**: Testing widget behavior, UI logic, user interactions

### Integration Tests
- **Purpose**: Test complete app flows with real services
- **Speed**: Slow (minutes)
- **Dependencies**: Use real services (GPS, network, database)
- **Device Required**: Yes (physical device or emulator)
- **When to Use**: End-to-end testing, critical user flows

## Project Structure

```
your_project/
├── dart_test.yaml                 # Test configuration
├── test/                          # Unit & Widget tests
│   ├── models/
│   │   └── user_test.dart
│   ├── services/
│   │   └── location_service_test.dart
│   ├── widgets/
│   │   └── custom_button_test.dart
│   └── utils/
│       └── validators_test.dart
├── integration_test/              # Integration tests
│   ├── app_test.dart
│   ├── location_flow_test.dart
│   └── user_journey_test.dart
└── .vscode/
    └── settings.json              # VS Code test settings
```

## Unit Tests

### Basic Setup

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:your_app/services/location_service.dart';

// Create mock classes
class MockGeolocator extends Mock implements GeolocatorPlatform {}

void main() {
  group('LocationService', () {
    late LocationService locationService;
    late MockGeolocator mockGeolocator;

    setUp(() {
      mockGeolocator = MockGeolocator();
      locationService = LocationService(geolocator: mockGeolocator);
    });

    test('returns null when permission denied', () async {
      // Arrange
      when(() => mockGeolocator.checkPermission())
          .thenAnswer((_) async => LocationPermission.denied);

      // Act
      final result = await locationService.getCurrentPosition();

      // Assert
      expect(result, isNull);
    }, tags: ['unit']);
  });
}
```

### Key Dependencies

Add to `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0  # For mocking
```

## Widget Tests

### Basic Widget Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/widgets/custom_button.dart';

void main() {
  group('CustomButton Widget', () {
    testWidgets('displays text and responds to tap', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: CustomButton(
            text: 'Test Button',
            onPressed: () => tapped = true,
          ),
        ),
      );

      // Verify text is displayed
      expect(find.text('Test Button'), findsOneWidget);

      // Tap the button
      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      // Verify callback was called
      expect(tapped, isTrue);
    }, tags: ['widget']);
  });
}
```

## Integration Tests

### Setup

Add to `pubspec.yaml`:

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
```

### Basic Integration Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:your_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('complete user flow works', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test real user interactions
      await tester.tap(find.text('Get Location'));
      await tester.pumpAndSettle();

      // Verify real behavior
      expect(find.text('Location found'), findsOneWidget);
    }, tags: ['integration']);
  });
}
```

## Test Configuration

### dart_test.yaml

Create `dart_test.yaml` in your project root:

```yaml
# Configuration for dart test runner
tags:
  unit:
    description: "Fast unit tests that use mocks and don't require devices"
  widget:
    description: "Widget tests for UI components"
  integration:
    description: "Integration tests that run on real devices with actual services"

# Default configuration
test_on: "vm"
timeout: 30s

# Override timeout for different test types
override:
  integration:
    timeout: 2m
  widget:
    timeout: 1m
```

## VS Code Setup

### .vscode/settings.json

```json
{
  "dart.testAdditionalArgs": [
    "--exclude-tags=integration"
  ]
}
```

This setting:
- Excludes slow integration tests when running tests via VS Code UI
- Keeps development workflow fast
- You can still run integration tests manually

## Running Tests

### Command Line

```powershell
# Run all unit tests (fast)
flutter test --tags=unit

# Run all widget tests
flutter test --tags=widget

# Run unit and widget tests (exclude integration)
flutter test --exclude-tags=integration

# Run only integration tests (requires device)
flutter test --tags=integration

# Run specific test file
flutter test test/services/location_service_test.dart

# Run specific test by name
flutter test --name "returns null when permission denied"

# Run all tests
flutter test

# Run tests with verbose output
flutter test -v

# Run tests and watch for changes
flutter test --watch
```

### VS Code

- **Click "Run" above test functions**: Runs individual tests (excludes integration by default)
- **Use Test Explorer**: Browse and run tests via sidebar
- **Command Palette**: `Dart: Run All Tests`

## Best Practices

### Test Organization

1. **Group related tests** using `group()`
2. **Use descriptive test names** that explain the scenario
3. **Follow AAA pattern**: Arrange, Act, Assert
4. **Tag your tests** for easy filtering

### Mocking Guidelines

1. **Mock external dependencies** (APIs, databases, sensors)
2. **Don't mock value objects** (models, DTOs)
3. **Use meaningful test data** that reflects real scenarios
4. **Verify interactions** when behavior matters

### Test Data

```dart
// Good: Meaningful test data
final testUser = User(
  id: 'user123',
  name: 'John Doe',
  email: 'john@example.com',
);

// Avoid: Generic test data
final testUser = User(
  id: '1',
  name: 'Test',
  email: 'test@test.com',
);
```

### Integration Test Tips

1. **Test critical user journeys** only
2. **Use real devices** for location/camera features
3. **Keep tests independent** - each test should clean up
4. **Test permission flows** explicitly
5. **Handle network conditions** (offline/online)

### Performance

1. **Run unit tests frequently** during development
2. **Run integration tests** before releases
3. **Use `setUp()` and `tearDown()`** for test fixtures
4. **Group fast and slow tests** with tags

### CI/CD Integration

```yaml
# Example GitHub Actions
- name: Run Unit Tests
  run: flutter test --exclude-tags=integration

- name: Run Integration Tests
  run: flutter test --tags=integration
  if: matrix.device == 'android'
```

## Common Patterns

### Testing Async Code

```dart
test('async method returns expected value', () async {
  when(() => mockService.fetchData())
      .thenAnswer((_) async => 'expected data');

  final result = await serviceUnderTest.getData();
  
  expect(result, equals('expected data'));
});
```

### Testing Streams

```dart
test('stream emits expected values', () async {
  final stream = serviceUnderTest.dataStream;
  
  expect(stream, emitsInOrder(['value1', 'value2', emitsDone]));
  
  serviceUnderTest.triggerStreamEvents();
});
```

### Testing Exceptions

```dart
test('throws exception when invalid input', () {
  expect(
    () => serviceUnderTest.processData('invalid'),
    throwsA(isA<ValidationException>()),
  );
});
```

## Troubleshooting

### Common Issues

1. **"No tests found"**: Check file names end with `_test.dart`
2. **Mock not working**: Ensure you're mocking the interface, not implementation
3. **Integration test fails**: Verify device is connected and permissions granted
4. **Timeout errors**: Increase timeout in `dart_test.yaml` for slow tests

### Debug Tips

1. **Use `printOnFailure()`** for debugging test failures
2. **Add `await tester.pump()`** after UI changes in widget tests
3. **Check test output** for detailed error messages
4. **Run single test** to isolate issues

This guide provides a foundation for comprehensive testing in Flutter applications. Adapt these practices to your specific project needs and team requirements.

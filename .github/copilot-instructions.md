# Airsoft Telemetry Flutter App - Copilot Instructions

This is a Flutter-based mobile application for Android and iOS designed for telemetry data collection during airsoft gaming sessions. The app tracks player movements, records game events, and exports detailed analytics with high-precision GPS coordinates and sensor data. Please follow these guidelines when contributing:

## Code Standards

### Required Before Each Commit
- Run `flutter analyze` to check for static analysis issues
- Run `dart format .` to ensure consistent code formatting across all Dart files
- Ensure all tests pass with `flutter test` before committing changes
- Follow the project's analysis options defined in `analysis_options.yaml`

### Development Flow
- Setup: `flutter pub get` to install dependencies
- Build (Android): `flutter build apk` or `flutter build appbundle`
- Build (iOS): `flutter build ios`
- Test: `flutter test` for unit tests, `flutter test integration_test/` for integration tests
- Run: `flutter run` for development, `flutter run --release` for release builds
- Clean: `flutter clean` to clean build artifacts when needed

## Repository Structure
- `lib/`: Main application source code
  - `main.dart`: Application entry point
  - `models/`: Data models and entities
  - `screens/`: UI screens and widgets
  - `services/`: Business logic and service classes
- `test/`: Unit tests for services and models
- `integration_test/`: Integration tests for end-to-end functionality
- `android/`: Android-specific platform code
- `ios/`: iOS-specific platform code
- `docs/`: Project documentation and implementation guides
- `web/`: Web platform assets (minimal support)

## Key Technologies & Dependencies
- **Flutter SDK**: 3.4.3+ with Dart 3.0+
- **Database**: SQLite via `sqflite` package for local data storage
- **Location Services**: `geolocator` package for GPS tracking
- **Permissions**: `permission_handler` for runtime permissions
- **Storage**: `shared_preferences` for user settings, `path_provider` for file paths
- **Data Export**: `csv` package for telemetry data export

## Key Guidelines

1. **Flutter Best Practices**: Follow Flutter and Dart conventions
   - Use `prefer_single_quotes` for strings
   - Use `package:` imports instead of relative imports for `lib/` files
   - Prefer `final` for local variables that won't be reassigned
   - Avoid positional boolean parameters

2. **Architecture Patterns**
   - Follow the existing service-based architecture
   - Keep business logic in service classes (`lib/services/`)
   - Use proper separation of concerns between UI and business logic
   - Maintain consistent error handling patterns

3. **Database & Storage**
   - All persistent data should use the `DatabaseService` 
   - Location data should be handled through `LocationService`
   - User preferences should use `PreferencesService`
   - Follow existing schema patterns for database tables

4. **Testing Requirements**
   - Write unit tests for all new service classes
   - Add integration tests for user-facing features
   - Test location services with mock data when possible
   - Ensure tests don't require actual device permissions

5. **Location & Permissions**
   - Always check permissions before accessing location services
   - Handle permission denied scenarios gracefully
   - Use appropriate location accuracy settings for airsoft gaming
   - Respect user privacy and data handling preferences

6. **Performance Considerations**
   - Be mindful of battery usage for location tracking
   - Implement efficient data caching strategies
   - Use background processing appropriately for telemetry collection
   - Optimize database queries and bulk operations

7. **Platform Compatibility**
   - Ensure features work on both Android and iOS
   - Handle platform-specific permission flows
   - Test on multiple screen sizes and orientations
   - Consider platform-specific UI guidelines

8. **Documentation**
   - Update relevant documentation in `docs/` folder for new features
   - Include code comments for complex business logic
   - Document any new service methods or API changes
   - Update README.md if user-facing features change

## Development Environment Setup

This project requires:
- Flutter SDK 3.4.3 or higher
- Dart SDK 3.0 or higher
- Android Studio/Xcode for platform-specific builds
- Physical device or emulator with location services for testing

## Telemetry & Gaming Context

Remember that this app is designed for airsoft gaming scenarios:
- Location tracking should be optimized for outdoor environments
- Consider typical airsoft game durations (30 minutes to several hours)
- Data export should provide meaningful insights for players
- UI should be usable with gloves and in various lighting conditions
- Battery efficiency is crucial for day-long events

## Current Development Status

The app is in active development with core telemetry features production-ready. When working on new features, check the `docs/` folder for implementation plans and current status of various components.

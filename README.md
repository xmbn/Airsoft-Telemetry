# Airsoft Telemetry Flutter

A production-ready Flutter application for comprehensive telemetry data collection during airsoft gaming sessions. Track player movements, record game events, and export detailed analytics with high-precision GPS coordinates and sensor data.

![Flutter](https://img.shields.io/badge/Flutter-3.4.3+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows-lightgrey.svg)
![Tests](https://img.shields.io/badge/Tests-84%20Passing-green.svg)
![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen.svg)

## ✨ Features

### 🎯 **Core Telemetry System**
- **Session Management**: Complete start/pause/resume/stop workflow with unique session IDs
- **Configurable Interval Tracking**: GPS snapshots at 1s, 2s, 3s, 4s, 5s, 10s, 30s, or 60s intervals
- **Manual Event Recording**: HIT, SPAWN, KILL events with precise GPS coordinates
- **Automatic Event Logging**: START, STOP, PAUSE, RESUME, and LOCATION events
- **Real-time Position Display**: Live latitude, longitude, and altitude updates

### 📍 **Advanced Location Services**
- **High-Precision GPS**: Comprehensive position data including altitude, speed, accuracy, and azimuth
- **Efficient Battery Usage**: Timer-based location tracking optimized for extended gaming sessions
- **Permission Management**: Seamless location permission handling with user-friendly prompts
- **Position Streaming**: Real-time location updates throughout the application

### 💾 **Robust Data Management**
- **SQLite Database**: Local storage with optimized schema for game events and sessions
- **Data Persistence**: All telemetry data stored locally with fast query performance
- **Session Filtering**: Retrieve events by session ID or time range
- **Data Integrity**: Atomic operations with proper error handling and validation

### ⚙️ **Persistent User Preferences**
- **Player Configuration**: Save player name and tracking interval settings
- **Automatic Persistence**: Settings automatically saved and restored across app sessions
- **Validation**: Input validation with fallback to sensible defaults
- **Bulk Preferences**: Efficient loading and saving of all user preferences

### 📊 **Data Export & Analytics**
- **CSV Export**: Complete event data export with human-readable timestamps
- **Platform Integration**: Native file saving using platform-specific APIs
- **Export Statistics**: Event counts, session duration, and data size information
- **Comprehensive Metrics**: All position data, timestamps, and event types included

### 🖥️ **Modern User Interface**
- **Dark Theme**: Battery-optimized interface perfect for outdoor gaming
- **Reactive Updates**: Real-time UI changes based on session state and location data
- **Intuitive Controls**: Context-aware buttons that adapt to current session state
- **Event Log**: Live display of recent events with formatted coordinates
- **Multi-Screen Navigation**: Home, Settings, and Insights screens with smooth transitions

## 🏗️ **Architecture**

### **Service Layer Architecture**
```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ HomeScreen  │  │ SettingsUI  │  │ InsightsScreen      │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                      Service Layer                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ Telemetry   │  │ Location    │  │ Database            │ │
│  │ Service     │◄─│ Service     │◄─│ Service             │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
│         │                                  │                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ Preferences │  │ Export      │  │ App Config          │ │
│  │ Service     │  │ Service     │  │                     │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ SQLite DB   │  │ SharedPrefs │  │ File System         │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### **Key Components**

- **TelemetryService**: Core session management, event recording, and location tracking coordination
- **LocationService**: High-precision GPS operations with configurable intervals  
- **DatabaseService**: SQLite operations with optimized schema and indexing
- **PreferencesService**: User settings persistence and validation
- **ExportService**: CSV generation and platform-specific file operations
- **GameEvent Model**: Comprehensive data model with complete position metrics

## 🚀 **Getting Started**

### **Prerequisites**
- Flutter SDK 3.4.3 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- Physical device for GPS testing (recommended)

### **Installation**

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd airsoft_telemetry_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### **Testing**

Run the comprehensive test suite:
```bash
# Unit tests
flutter test

# Integration tests  
flutter test integration_test/

# Static analysis
flutter analyze
```

## 📱 **Usage Guide**

### **Starting a Session**
1. Open the app and navigate to the **Settings** screen by swiping right
2. Configure your **Player Name** and **Update Interval** in Settings
3. Return to the **Home** screen.
4. Press **START** to begin telemetry collection
5. Use **HIT**, **SPAWN**, **KILL** buttons to record manual events
6. **PAUSE/RESUME** or **STOP** the session as needed

### **Viewing Data**
- **Settings Screen**: View real-time event log with coordinates
- **Live Position**: Monitor current GPS location and accuracy
- **Session Status**: Track active session state and recent events

### **Exporting Data**
1. Navigate to **Settings** screen
2. Press **Export Data** button
3. Choose save location using platform file picker
4. Data exported as CSV with complete telemetry metrics

### **Data Management**
- **Clear All Data**: Remove all events with confirmation dialog
- **Session Filtering**: Data organized by unique session IDs
- **Automatic Backup**: All data persisted locally in SQLite database

## 🧪 **Testing**

### **Test Coverage**
- **84 Total Tests**: Comprehensive coverage across all components
- **100% Pass Rate**: All tests currently passing
- **Unit Tests**: Service layer, models, and business logic
- **Integration Tests**: End-to-end workflows and database operations
- **Widget Tests**: UI component validation

### **Test Categories**
```
test/
├── database_service_test.dart        # Database operations
├── export_service_test.dart          # CSV export functionality  
├── game_event_test.dart              # Data model validation
├── location_service_test.dart        # GPS operations
├── preferences_service_test.dart     # Settings persistence
├── telemetry_service_test.dart       # Core telemetry logic
└── telemetry_service_cache_test.dart # Stream caching

integration_test/
├── database_service_integration_test.dart  # End-to-end DB testing
├── export_service_integration_test.dart    # Export workflows  
├── location_service_integration_test.dart  # GPS integration
└── telemetry_service_integration_test.dart # Complete workflows
```

## 📋 **Dependencies**

### **Core Dependencies**
- **sqflite**: SQLite database operations
- **geolocator**: High-precision GPS location services  
- **shared_preferences**: User settings persistence
- **csv**: CSV data export functionality
- **path_provider**: File system access for exports
- **permission_handler**: Runtime permission management

### **Development Dependencies**
- **flutter_test**: Unit and widget testing framework
- **integration_test**: End-to-end testing capabilities

## 🔧 **Configuration**

### **Location Tracking Intervals**
Configure automatic GPS snapshot frequency:
- **1-5 seconds**: High precision for detailed tracking
- **10-30 seconds**: Balanced accuracy and battery life  
- **60 seconds**: Battery optimized for extended sessions

### **Event Types**
- **Manual Events**: HIT, SPAWN, KILL (user-triggered)
- **Session Events**: START, PAUSE, RESUME, STOP (automatic)
- **Location Events**: LOCATION (interval-based automatic)

### **Data Export Format**
CSV export includes:
- Session ID, Player ID, Event Type
- Timestamp (milliseconds and human-readable)
- Complete GPS data (lat, lng, altitude, azimuth, speed, accuracy)

## 🏆 **Production Status**

### **Quality Metrics**
- ✅ **Feature Complete**: All planned functionality implemented
- ✅ **Test Coverage**: 84 tests with 100% pass rate
- ✅ **Code Quality**: Professional architecture with proper error handling
- ✅ **Performance**: Optimized for battery life and memory usage
- ✅ **User Experience**: Intuitive interface with real-time feedback

### **Deployment Ready**
- ✅ **Production Build**: Ready for release compilation
- ✅ **Platform Support**: Android, iOS, and Windows compatibility
- ✅ **Error Handling**: Comprehensive validation and recovery
- ✅ **Data Integrity**: Robust persistence and export capabilities

## 📄 **Documentation**

- **Implementation Plan**: `docs/telemetry-implementation-plan.md`
- **Testing Guide**: `docs/testing-guide.md`
- **Integration Testing**: `docs/integration-testing-guide.md`
- **Implementation Assessment**: `docs/implementation-assessment-june-2025.md`

## 🤝 **Contributing**

This is a production-ready application with comprehensive testing. When contributing:

1. Run tests before submitting changes: `flutter test`
2. Follow the existing architecture patterns
3. Add tests for new functionality
4. Update documentation as needed

## 🏆 **Key Achievements**

### **Implementation Excellence**
- **Complete Feature Set**: All originally planned features implemented and working
- **Exceeded Expectations**: Additional features like Insights screen and advanced caching
- **Professional Quality**: Production-ready code with comprehensive error handling
- **Comprehensive Testing**: 84 tests covering all major functionality

### **Technical Highlights**
- **Stream-Based Architecture**: Real-time reactive updates throughout the UI
- **Efficient Resource Management**: Proper disposal and memory optimization
- **Battery Optimization**: Timer-based GPS tracking instead of continuous polling
- **Data Integrity**: Atomic database operations with validation

### **User Experience**
- **Intuitive Interface**: Context-aware controls that adapt to session state
- **Real-Time Feedback**: Live position updates and event logging
- **Dark Theme**: Battery-optimized UI perfect for outdoor gaming
- **Seamless Navigation**: Multi-screen app with smooth transitions

## 📄 **License**

This project is available for use in airsoft gaming applications and educational purposes.

---

**Status**: Production Ready ✅  
**Last Updated**: June 28, 2025  
**Version**: 1.0.0+1

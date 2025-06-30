# **AIRSOFT** Telemetry Mobile App

A comprehensive **Flutter mobile application** for Android and iOS devices designed for telemetry data collection during **airsoft** gaming sessions. Track player movements, record game events, and export detailed analytics with high-precision GPS coordinates and sensor data. **Currently in active development** with core telemetry features production-ready and advanced insights features in development.

![Flutter](https://img.shields.io/badge/Flutter-3.4.3+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)
![Tests](https://img.shields.io/badge/Tests-84%20Passing-green.svg)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow.svg)
![Contributors](https://img.shields.io/badge/Contributors-Welcome-brightgreen.svg)

## 🤝 **Looking for Contributors!**

**We're actively seeking contributors to help make this the ultimate AIRSOFT telemetry app!** Whether you're an **airsofter** who codes, a Flutter developer, a field tester, or a data enthusiast - we'd love your help. This project demonstrates innovative human-AI collaboration in software development, and we welcome contributors of all skill levels.

**Ready to contribute?** Jump to our [Contributing & Development](#-contributing--development) section to get started!

## 📋 **Table of Contents**

- [✨ Features](#✨-features)
- [🏗️ Architecture](#🏗️-architecture)
- [🤝 Contributing & Development](#🤝-contributing--development)
- [🚀 Getting Started](#🚀-getting-started)
- [📱 App Usage Guide](#📱-app-usage-guide)
- [🧪 Testing](#🧪-testing)
- [📋 Dependencies](#📋-dependencies)
- [🔧 Configuration](#🔧-configuration)
- [🚀 Development Status](#🚀-development-status)
- [📄 Documentation](#📄-documentation)
- [🏆 Current Achievements](#🏆-current-achievements)
- [📄 License](#📄-license)

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

### 📈 **Game Insights & Analytics** *(In Development)*
- **Session Selection**: Choose from all recorded game sessions for analysis
- **Performance KPIs**: Kill/Death ratio, distance traveled, session duration, and average speed
- **Combat Analytics**: Track KILL, HIT, and SPAWN events with detailed statistics
- **Movement Analysis**: Calculate total distance traveled using GPS coordinates
- **Session Comparison**: Compare performance metrics across multiple gaming sessions
- **Real-time Calculations**: Automatic computation of averages, totals, and derived metrics
- **Future Features Planned**: Interactive movement maps, time-based trend analysis, AI-powered gameplay insights

### 🖥️ **Modern User Interface**
- **Dark Theme**: Battery-optimized interface perfect for outdoor gaming
- **Reactive Updates**: Real-time UI changes based on session state and location data
- **Intuitive Controls**: Context-aware buttons that adapt to current session state
- **Event Log**: Live display of recent events with formatted coordinates
- **Multi-Screen Navigation**: Home, Settings, and Insights screens with smooth transitions

[↑ Back to Table of Contents](#📋-table-of-contents)

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

[↑ Back to Table of Contents](#📋-table-of-contents)

## 🤝 **Contributing & Development**

### **AI-Powered Development**
This project demonstrates the power of human-AI collaboration in software development. While the app was **conceptualized, designed, and orchestrated by a human developer**, the codebase is **written and managed by AI** (GitHub Copilot and Claude). This approach allows for rapid prototyping, comprehensive testing, and consistent code quality while maintaining human oversight for architecture decisions and feature planning.

### **Contributors Welcome!**
We actively welcome contributions from developers and **AIRSOFT** enthusiasts! Whether you're:
- **Airsofters who code**: Help us build features you'd actually use in the field
- **Developers interested in Flutter**: Learn modern app development patterns
- **Field testers**: Test the app during real **AIRSOFT** games and provide feedback
- **Data enthusiasts**: Help analyze telemetry data and suggest new insights

### **How to Contribute**
1. **Check the Issues tab** for available tasks and feature requests
2. **Fork the repository** and create a feature, bug, or refactor branch
3. **Test thoroughly** - we maintain high code quality standards requireing unit tests and integration tests
4. **Submit a pull request** with detailed description of changes

### **Available Tasks**
Check the **Issues tab** for current tasks including:
- Feature implementation (Insights dashboard, KPI calculations)
- UI/UX improvements and mobile optimization
- Testing and bug reports from field usage
- Documentation and code improvements
- Performance optimization and battery life enhancements

### **Field Testing Needed**
We especially need **AIRSOFT** players who can:
- Test GPS accuracy during actual games
- Provide feedback on battery usage during long sessions  
- Suggest new features based on real gameplay needs
- Report bugs and edge cases found in field conditions

### **Development Guidelines**
1. **Maintain test coverage**: Add tests for new functionality
2. **Follow existing patterns**: Use the established service-layer architecture
3. **Test on device**: GPS features require physical device testing
4. **Document changes**: Update relevant documentation files

### **Development Approach**
- **Human-guided AI development**: Strategic decisions by humans, implementation by AI
- **Test-driven development**: 84 comprehensive unit and integration tests ensure reliability
- **Production-quality code**: Professional architecture and error handling
- **Open collaboration**: Transparent development process with regular updates

[↑ Back to Table of Contents](#📋-table-of-contents)

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

📖 **For detailed testing instructions and guidelines, see our [Testing Guide](docs/testing-guide.md)**

[↑ Back to Table of Contents](#📋-table-of-contents)

## 📱 **App Usage Guide**

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

[↑ Back to Table of Contents](#📋-table-of-contents)

## 🧪 **Testing**

📖 **For comprehensive testing instructions and best practices, see our [Testing Guide](docs/testing-guide.md)**

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

[↑ Back to Table of Contents](#📋-table-of-contents)

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

[↑ Back to Table of Contents](#📋-table-of-contents)

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

[↑ Back to Table of Contents](#📋-table-of-contents)

## 🚀 **Development Status**

### **Production-Ready Components**
- ✅ **Core Telemetry System**: Complete session management and event recording
- ✅ **Location Services**: High-precision GPS tracking with configurable intervals
- ✅ **Data Management**: SQLite database with optimized queries and data integrity
- ✅ **Export Functionality**: CSV export with comprehensive telemetry data
- ✅ **User Interface**: Intuitive controls with real-time feedback and dark theme
- ✅ **Testing**: 84 comprehensive tests with 100% pass rate

### **In Development**
- 🔄 **Insights Dashboard**: Comprehensive analytics screen for session analysis
- 🔄 **Performance KPIs**: Calculate and display game performance metrics
- 🔄 **Session Comparison**: Compare statistics across multiple gaming sessions

### **Planned Features**
- 📋 **Background Service**: Enable app to continue to collect data in the background
- 📋 **Interactive Maps**: Visualize movement paths and event locations
- 📋 **Trend Analysis**: Time-based performance tracking and improvements
- 📋 **AI Insights**: Machine learning-powered gameplay pattern analysis

[↑ Back to Table of Contents](#📋-table-of-contents)

## 📄 **Documentation**

- **Implementation Plan**: [docs/telemetry-implementation-plan.md](docs/telemetry-implementation-plan.md)
- **Testing Guide**: [docs/testing-guide.md](docs/testing-guide.md)
- **Integration Testing**: [docs/integration-testing-guide.md](docs/integration-testing-guide.md)
- **Implementation Assessment**: [docs/implementation-assessment-june-2025.md](docs/implementation-assessment-june-2025.md)
- **Insights Feature Plan**: [docs/insights-feature-plan.md](docs/insights-feature-plan.md)
- **Location Direction Properties**: [docs/location_direction_properties.md](docs/location_direction_properties.md)

[↑ Back to Table of Contents](#📋-table-of-contents)

## 🏆 **Current Achievements**

### **Core System Excellence**
- **Production-Ready Telemetry**: Complete session management and GPS tracking system
- **Comprehensive Testing**: 84 tests covering all major functionality with 100% pass rate
- **Professional Architecture**: Service-layer design with proper separation of concerns
- **Robust Data Management**: SQLite database with optimized queries and data integrity

### **Technical Highlights**
- **Stream-Based Architecture**: Real-time reactive updates throughout the UI
- **Efficient Resource Management**: Proper disposal and memory optimization
- **Battery Optimization**: Timer-based GPS tracking instead of continuous polling
- **Cross-Platform Support**: Android, iOS, and Windows compatibility

### **User Experience**
- **Intuitive Interface**: Context-aware controls that adapt to session state
- **Real-Time Feedback**: Live position updates and event logging
- **Dark Theme**: Battery-optimized UI perfect for outdoor gaming
- **Export Functionality**: Complete CSV export of telemetry data

### **Development Innovation**
- **AI-Human Collaboration**: Demonstrating effective human-guided AI development
- **Open Development**: Transparent process welcoming community contributions
- **Field-Tested Approach**: Designed by **AIRSOFT** players for **AIRSOFT** players

[↑ Back to Table of Contents](#📋-table-of-contents)

## 📄 **License**

This project is not yet covered 

---

**Status**: In Active Development (Core Features Production-Ready) 🔄  
**Contributors**: Welcome - Check Issues Tab for Tasks 🤝  
**Last Updated**: June 29, 2025  
**Version**: 1.0.0+1

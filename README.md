# **Airsoft** Telemetry Mobile App

A comprehensive **Flutter mobile application** for Android and iOS devices designed for telemetry data collection during **Airsoft** gaming sessions. Track player movements, record game events, and export detailed analytics with high-precision GPS coordinates and sensor data. **Currently in active development** with core telemetry features production-ready and advanced insights features in development.

![Flutter](https://img.shields.io/badge/Flutter-3.4.3+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)
![Tests](https://img.shields.io/badge/Tests-84%20Passing-green.svg)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow.svg)
![Contributors](https://img.shields.io/badge/Contributors-Welcome-brightgreen.svg)

## 🚀 **How It Works**

Ever wonder how far you walked during that intense **Airsoft** battle? This app transforms your mobile device into a comprehensive telemetry system that tracks every aspect of your gameplay:

1. **📍 Start Tracking**: Press start and the app begins collecting your GPS location at configurable intervals (every 1-60 seconds)
2. **🎯 Record Events**: Tap HIT, SPAWN, or KILL buttons to log combat events with precise coordinates  
3. **📊 Analyze Performance**: View real-time data and export detailed analytics to discover patterns in your gameplay
4. **🤖 AI Insights**: *(Coming Soon)* Machine learning analysis to identify movement patterns, tactical tendencies, and performance improvements
5. **📈 Improve Gameplay**: Use data-driven insights to enhance your **Airsoft** strategy and performance

**No backend required** - everything runs entirely on your device, with optional AI analysis through your personal Gemini API, making the app easy to run and maintain without external dependencies.

## 🤝 **Looking for Contributors!**

**We're actively seeking contributors to help make this the ultimate Airsoft telemetry app!** Whether you're an **Airsofter** who codes, a Flutter developer, a field tester, or a data enthusiast - we'd love your help.

**Ready to contribute?** Jump to our [Contributing & Development](#🤝-contributing--development) section to get started!

## 🤝 **AI-Powered Development**

This project showcases an innovative approach to software development through **human-AI collaboration**. Understanding this development model helps explain the project's rapid progress, comprehensive testing, and consistent code quality.

### **The Collaboration Model**

- **Human Leadership**: Strategic decisions, feature planning, architecture design, and quality oversight
- **AI Implementation**: Code writing, test creation, documentation, and iterative development
- **Continuous Feedback**: Human guidance shapes AI output, ensuring practical and user-focused solutions

### **Why This Approach Works**

**Rapid Prototyping**: AI can quickly implement features based on human specifications, allowing for fast iteration and testing of ideas.

**Comprehensive Testing**: AI naturally creates thorough test suites (84 tests with 100% pass rate), ensuring reliability from the start.

**Consistent Quality**: AI follows established patterns and best practices consistently across the entire codebase.

**Documentation Excellence**: AI maintains up-to-date documentation and clear code comments throughout development.

### **Human Oversight Areas**

- **Feature Prioritization**: Deciding what **Airsoft** players actually need
- **User Experience**: Ensuring the app works well in field conditions  
- **Technical Architecture**: Making strategic decisions about app structure and dependencies
- **Community Management**: Engaging with contributors and managing feedback

### **Benefits for Contributors**

- **Clean Codebase**: Well-structured, thoroughly tested code that's easy to understand and extend
- **Excellent Documentation**: Comprehensive guides and clear inline documentation
- **Consistent Patterns**: Established architectural patterns make contributing straightforward
- **Active Maintenance**: Regular updates and responsive issue resolution

## 📋 **Table of Contents**

- [🚀 How It Works](#🚀-how-it-works)
- [✨ Features](#✨-features)
- [🏗️ Architecture](#🏗️-architecture)
- [🤝 AI-Powered Development](#🤝-ai-powered-development)
- [🤝 Contributing & Development](#🤝-contributing--development)
- [🚀 Getting Started](#🚀-getting-started)
- [📱 App Usage Guide](#📱-app-usage-guide)
- [🧪 Testing](#🧪-testing)
- [📋 Dependencies](#📋-dependencies)
- [🔧 Configuration](#🔧-configuration)
- [🚀 Development Status](#🚀-development-status)
- [📄 Documentation](#📄-documentation)
- [📄 License](#📄-license)

## ✨ Features

### 🎯 **Core Telemetry System**
- **Session Management**: Complete start/pause/resume/stop workflow with unique session IDs
- **Configurable GPS Tracking**: Location snapshots at 1s, 2s, 3s, 4s, 5s, 10s, 30s, or 60s intervals
- **Event Recording**: Manual HIT, SPAWN, KILL events + automatic session events with precise GPS coordinates
- **Real-time Updates**: Live position display with latitude, longitude, altitude, speed, accuracy, and azimuth

### 💾 **Data Management & Export**
- **Local SQLite Storage**: All telemetry data stored locally with optimized queries and fast performance
- **CSV Export**: Complete event data export with timestamps and comprehensive GPS metrics
- **Data Persistence**: Settings and session data automatically saved and restored
- **Session Organization**: Events organized by unique session IDs for easy analysis

### 📈 **Game Insights** *(In Development)*
- **Performance Analytics**: Kill/Death ratio, distance traveled, session duration, and movement statistics
- **Session Comparison**: Compare performance metrics across multiple gaming sessions
- **Real-time Calculations**: Automatic computation of gameplay metrics and derived statistics

### 🖥️ **Modern User Interface**
- **Dark Theme**: Battery-optimized interface perfect for outdoor gaming
- **Multi-Screen Navigation**: Home, Settings, and Insights screens with intuitive swipe navigation
- **Reactive Updates**: Real-time UI changes based on session state and GPS data
- **Context-Aware Controls**: Buttons adapt to current session state for optimal user experience

### 🔒 **Privacy & Independence**
- **No Backend Required**: Everything runs entirely on your device - no servers, no cloud dependencies
- **Local Data Storage**: All telemetry data stored securely in local SQLite database
- **Optional AI Analysis**: Future AI insights powered by your personal Gemini API (optional)
- **Complete Control**: You own and control all your gameplay data

[↑ Back to Table of Contents](#📋-table-of-contents)

## 🏗️ **Architecture**

### **Service Layer Architecture**
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

### **Key Components**

- **TelemetryService**: Core session management, event recording, and location tracking coordination
- **LocationService**: High-precision GPS operations with configurable intervals  
- **DatabaseService**: SQLite operations with optimized schema and indexing
- **PreferencesService**: User settings persistence and validation
- **ExportService**: CSV generation and platform-specific file operations
- **GameEvent Model**: Comprehensive data model with complete position metrics

[↑ Back to Table of Contents](#📋-table-of-contents)

## 🤝 **Contributing & Development**

### **Contributors Welcome!**
We actively welcome contributions from developers and **Airsoft** enthusiasts! Whether you're:
- **Airsofters who code**: Help us build features you'd actually use in the field
- **Developers interested in Flutter**: Learn modern app development patterns
- **Field testers**: Test the app during real **Airsoft** games and provide feedback
- **Data enthusiasts**: Help analyze telemetry data and suggest new insights

### **How to Contribute**
1. **Check the Issues tab** for available tasks and feature requests
2. **Fork the repository** and create a feature, bug, or refactor branch.
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
We especially need **Airsoft** players who can:
- Test GPS accuracy during actual games.
- Provide feedback on battery usage during long sessions  
- Suggest new features based on real gameplay needs
- Report bugs and edge cases found in field conditions

### **Development Guidelines**
1. **Maintain test coverage**: Add tests for new functionality
2. **Follow existing patterns**: Use the established service-layer architecture
3. **Test on device**: GPS features require physical device testing
4. **Document changes**: Update relevant documentation files

### **Development Approach**
- **Test-driven development**: 84 comprehensive unit and integration tests ensure reliability
- **Production-quality code**: Professional architecture and error handling
- **Open collaboration**: Transparent development process with regular updates
- **AI-assisted development**: See [AI-Powered Development](#🤝-ai-powered-development) for details

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

📖 **For complete usage instructions and gameplay tips, see our [User Guide](docs/user-guide.md)**

**Quick Start**: Configure settings → Press START → Record events (HIT/SPAWN/KILL) → Export data for analysis

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

- **User Guide**: [docs/user-guide.md](docs/user-guide.md)
- **Implementation Plan**: [docs/telemetry-implementation-plan.md](docs/telemetry-implementation-plan.md)
- **Testing Guide**: [docs/testing-guide.md](docs/testing-guide.md)
- **Integration Testing**: [docs/integration-testing-guide.md](docs/integration-testing-guide.md)
- **Implementation Assessment**: [docs/implementation-assessment-june-2025.md](docs/implementation-assessment-june-2025.md)
- **Insights Feature Plan**: [docs/insights-feature-plan.md](docs/insights-feature-plan.md)
- **Location Direction Properties**: [docs/location_direction_properties.md](docs/location_direction_properties.md)

[↑ Back to Table of Contents](#📋-table-of-contents)



## 📄 **License**

This project is not yet covered by any particular license

---

**Status**: In Active Development (Core Features Production-Ready) 🔄  
**Contributors**: Welcome - Check Issues Tab for Tasks 🤝  
**Last Updated**: June 29, 2025  
**Version**: 1.0.0+1

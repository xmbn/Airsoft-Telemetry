# Airsoft Telemetry Mobile App

A comprehensive Flutter mobile application for Android and iOS devices designed for telemetry data collection during **Airsoft** gaming sessions. Track player movements, record game events, and export detailed analytics with high-precision GPS coordinates and sensor data.

![Flutter](https://img.shields.io/badge/Flutter-3.4.3+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)
![Tests](https://img.shields.io/badge/Tests-84%20Passing-green.svg)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow.svg)
![Contributors](https://img.shields.io/badge/Contributors-Welcome-brightgreen.svg)

> **Note**: This project is developed through human-AI collaboration. Most of the code is written and maintained by AI, orchestrated under human guidance and oversight by experienced programmers.

## How It Works & Features

Transform your mobile device into a comprehensive telemetry system for Airsoft gameplay with these core capabilities:

- **🎯 Session Management**: Start tracking and the app begins collecting GPS location at configurable intervals (1-60 seconds) with complete start/pause/resume/stop workflow
- **📍 Event Recording**: Tap HIT, SPAWN, or KILL buttons to log combat events with precise coordinates, plus automatic session events 
- **📊 Data Analysis**: View real-time data and receive AI-powered analysis and recommendations for better gameplay (in development)
- **💾 Local Storage**: SQLite database stores all telemetry data locally with CSV export functionality
- **🖥️ Modern Interface**: Dark theme optimized for outdoor gaming with intuitive controls and real-time feedback
- **🔒 Privacy First**: No backend required - all data stored locally on your device (except optional AI analysis)

## Getting Started

### Prerequisites
- Flutter SDK 3.4.3 or higher
- Dart SDK 3.0 or higher
- Android Studio or VS Code with Flutter extensions
- Physical device for GPS testing (emulator GPS simulation is unreliable)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/xmbn/Airsoft-Telemetry.git
   cd Airsoft-Telemetry
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

4. **Grant permissions** (when prompted on device)
   - Location access (required for GPS tracking)
   - Storage access (required for CSV export)

## Documentation

- **User Guide**: [docs/user-guide.md](docs/user-guide.md)
- **Contributing**: [docs/contributing.md](docs/contributing.md)
- **Architecture**: [docs/architecture.md](docs/architecture.md)
- **Testing Guide**: [docs/testing/testing-guide.md](docs/testing/testing-guide.md)
- **Integration Testing**: [docs/testing/integration-testing-guide.md](docs/testing/integration-testing-guide.md)
- **Detailed Information**: [docs/archive/readme-archive.md](docs/archive/readme-archive.md)

---

**Status**: In Active Development (Core Features Production-Ready)  
**Contributors**: Welcome - Check Issues Tab for Tasks  
**Version**: 1.0.0+1

For comprehensive project details, technical architecture, testing guides, and contribution guidelines, see the [documentation folder](docs/).

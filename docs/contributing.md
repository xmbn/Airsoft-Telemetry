# Contributing to Airsoft Telemetry Flutter App

We welcome contributions from developers and **Airsoft** enthusiasts! Whether you're an Airsofter who codes, a Flutter developer, field tester, or data enthusiast - we'd love your help.

## Getting Started

### Prerequisites
- Flutter SDK 3.4.3 or higher
- Dart SDK 3.0 or higher
- Android Studio or VS Code with Flutter extensions
- Physical device for GPS testing (emulator GPS simulation is unreliable)

### Setup
1. **Fork the repository** at https://github.com/xmbn/Airsoft-Telemetry
2. **Clone and setup**
   ```bash
   git clone https://github.com/YOUR-USERNAME/Airsoft-Telemetry.git
   cd Airsoft-Telemetry
   flutter pub get
   flutter run
   ```
3. **Grant permissions** when prompted (Location and Storage access)
4. **Verify setup**: `flutter test && flutter analyze`

## How to Contribute

1. Check the **Issues tab** for available tasks
2. Create a feature/bug/refactor branch from your fork
3. Make changes following our code standards below
4. Test thoroughly on a physical device
5. Submit a pull request with detailed description

## What We Need

### Code Contributions
- Feature implementation (Insights dashboard, KPI calculations)
- UI/UX improvements and mobile optimization
- Documentation and code improvements
- Performance optimization and battery life enhancements

### Field Testing
We especially need **Airsoft** players who can:
- Test GPS accuracy during actual games
- Provide feedback on battery usage during long sessions
- Suggest new features based on real gameplay needs
- Report bugs and edge cases found in field conditions

## Code Standards

### Before Each Commit
```bash
dart format .
flutter analyze
flutter test
```

### Development Guidelines
- Add tests for new functionality
- Follow existing service-layer architecture patterns
- Test on physical device (GPS features required)
- Update relevant documentation

> **Note**: This project uses AI-assisted development. Most code is written and maintained by AI under human guidance. See [archive/readme-archive.md](archive/readme-archive.md) for details.

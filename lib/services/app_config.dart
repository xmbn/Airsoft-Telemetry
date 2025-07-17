import 'package:flutter/material.dart';

class AppConfig {
  // UI Constants
  static const double buttonBorderRadius = 10.0;
  static const double inputBorderRadius = 8.0;
  static const double standardPadding = 16.0;
  static const double smallPadding = 4.0;
  static const double mediumPadding = 8.0;
  static const double largePadding = 12.0;
  static const double extraLargePadding = 24.0;

  // Button Sizes
  static const double startButtonHeight = 60.0;
  static const double inputFieldHeight = 48.0;

  // Font Sizes
  static const double eventButtonFontSize = 24.0;
  static const double startButtonFontSize = 18.0;
  static const double sectionTitleFontSize = 16.0;

  // Intervals (in seconds)
  static const List<String> intervalOptions = [
    '1s',
    '2s',
    '3s',
    '4s',
    '5s',
    '10s',
    '30s',
    '60s'
  ];
  static const String defaultInterval = '2s';

  // Default Values
  static const String defaultPlayerName = 'Player 1';
  static const bool defaultIsTracking = false;
  static const bool defaultIsPaused = false;

  // App Info
  static const String appTitle = 'Airsoft Telemetry';
  static const String settingsTitle = 'Settings';
  static const String eventLogTitle = 'Event Log';

  // Button Labels
  static const String startLabel = 'START';
  static const String pauseLabel = 'PAUSE';
  static const String resumeLabel = 'RESUME';
  static const String stopLabel = 'STOP';
  static const String hitLabel = 'HIT';
  static const String spawnLabel = 'SPAWN';
  static const String killLabel = 'KILL';
  static const String exportDataLabel = 'Export Data';
  static const String clearDataLabel = 'Clear Data';

  // Input Labels
  static const String playerNameLabel = 'Player Name';
  static const String intervalLabel = 'Interval';
  static const String locationDataLabel = 'Location Data';
  static const String latitudeLabel = 'Latitude';
  static const String longitudeLabel = 'Longitude';
  static const String altitudeLabel = 'Altitude';
  static const String azimuthLabel = 'Azimuth';
  static const String speedLabel = 'Speed';
  static const String accuracyLabel = 'Accuracy';

  // Event Types
  static const String hitEvent = 'HIT';
  static const String spawnEvent = 'SPAWN';
  static const String killEvent = 'KILL';

  // Colors
  static const Color primaryColor = Colors.deepPurple;
  static const Color scaffoldBackgroundColor = Colors.black;
  static const Color primaryTextColor = Colors.white;
  static const Color disabledColor = Colors.grey;
  static const Color outlineColor = Colors.grey;
  static const Color surfaceColor = Color(0xFF212121); // Colors.grey[900]
  static const Color buttonBackgroundColor = Colors.black;
  static const Color hitColor = Colors.red;
  static const Color spawnColor = Colors.green;
  static const Color killColor = Colors.amber;
}

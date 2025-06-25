import 'package:shared_preferences/shared_preferences.dart';
import 'package:airsoft_telemetry_flutter/services/app_config.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  static const String _playerNameKey = 'player_name';
  static const String _intervalKey = 'update_interval';

  // Get player name
  Future<String> getPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_playerNameKey) ?? AppConfig.defaultPlayerName;
  }

  // Set player name
  Future<bool> setPlayerName(String playerName) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_playerNameKey, playerName);
  }

  // Get update interval
  Future<String> getUpdateInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_intervalKey) ?? AppConfig.defaultInterval;
  }

  // Set update interval
  Future<bool> setUpdateInterval(String interval) async {
    final prefs = await SharedPreferences.getInstance();
    if (AppConfig.intervalOptions.contains(interval)) {
      return await prefs.setString(_intervalKey, interval);
    }
    return false; // Invalid interval
  }

  // Convert interval string to seconds
  int getIntervalInSeconds(String interval) {
    switch (interval) {
      case '1s':
        return 1;
      case '2s':
        return 2;
      case '3s':
        return 3;
      case '4s':
        return 4;
      case '5s':
        return 5;
      case '10s':
        return 10;
      case '30s':
        return 30;
      case '60s':
        return 60;
      default:
        return 2; // Default to 2 seconds
    }
  }

  // Load all preferences at once
  Future<Map<String, String>> loadAllPreferences() async {
    final playerName = await getPlayerName();
    final interval = await getUpdateInterval();
    return {
      'playerName': playerName,
      'interval': interval,
    };
  }

  // Clear all preferences (for testing/reset)
  Future<bool> clearAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }
}

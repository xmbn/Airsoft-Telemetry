import 'package:flutter_test/flutter_test.dart';
import 'package:airsoft_telemetry_flutter/services/preferences_service.dart';
import 'package:airsoft_telemetry_flutter/services/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PreferencesService', () {
    late PreferencesService preferencesService;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      preferencesService = PreferencesService();
    });

    test('getPlayerName returns default when not set', () async {
      final playerName = await preferencesService.getPlayerName();
      expect(playerName, equals(AppConfig.defaultPlayerName));
    });

    test('setPlayerName and getPlayerName work correctly', () async {
      const testName = 'TestPlayer';
      await preferencesService.setPlayerName(testName);
      final playerName = await preferencesService.getPlayerName();
      expect(playerName, equals(testName));
    });

    test('getUpdateInterval returns default when not set', () async {
      final interval = await preferencesService.getUpdateInterval();
      expect(interval, equals(AppConfig.defaultInterval));
    });

    test('setUpdateInterval and getUpdateInterval work correctly', () async {
      const testInterval = '5s';
      await preferencesService.setUpdateInterval(testInterval);
      final interval = await preferencesService.getUpdateInterval();
      expect(interval, equals(testInterval));
    });

    test('setUpdateInterval rejects invalid intervals', () async {
      final result = await preferencesService.setUpdateInterval('invalid');
      expect(result, isFalse);
    });

    test('getIntervalInSeconds converts correctly', () {
      expect(preferencesService.getIntervalInSeconds('1s'), equals(1));
      expect(preferencesService.getIntervalInSeconds('2s'), equals(2));
      expect(preferencesService.getIntervalInSeconds('5s'), equals(5));
      expect(preferencesService.getIntervalInSeconds('10s'), equals(10));
      expect(preferencesService.getIntervalInSeconds('30s'), equals(30));
      expect(preferencesService.getIntervalInSeconds('60s'), equals(60));
      expect(preferencesService.getIntervalInSeconds('invalid'),
          equals(2)); // default
    });

    test('loadAllPreferences returns correct values', () async {
      await preferencesService.setPlayerName('TestPlayer');
      await preferencesService.setUpdateInterval('10s');

      final preferences = await preferencesService.loadAllPreferences();
      expect(preferences['playerName'], equals('TestPlayer'));
      expect(preferences['interval'], equals('10s'));
    });

    test('clearAllPreferences works correctly', () async {
      await preferencesService.setPlayerName('TestPlayer');
      await preferencesService.setUpdateInterval('10s');

      await preferencesService.clearAllPreferences();

      final playerName = await preferencesService.getPlayerName();
      final interval = await preferencesService.getUpdateInterval();

      expect(playerName, equals(AppConfig.defaultPlayerName));
      expect(interval, equals(AppConfig.defaultInterval));
    });
  });
}

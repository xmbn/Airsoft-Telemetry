import 'package:flutter/material.dart';
import 'package:airsoft_telemetry_flutter/services/app_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isTracking = AppConfig.defaultIsTracking;

  void _startSession() {
    setState(() {
      _isTracking = true;
    });
  }

  void _recordEvent(String eventType) {
    // TODO: Implement event recording logic
    print('Event recorded: $eventType');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      extendBody: false,
      extendBodyBehindAppBar: false,
      body: Container(
        padding: const EdgeInsets.all(AppConfig.standardPadding),
        color: Colors.black,
        child: Column(
          children: [
            // Start button
            SizedBox(
              width: double.infinity,
              height: AppConfig.startButtonHeight,
              child: OutlinedButton(
                onPressed: _isTracking ? null : _startSession,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _isTracking ? AppConfig.disabledColor : AppConfig.primaryTextColor),
                  backgroundColor: AppConfig.buttonBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                  ),
                ),
                child: Text(
                  AppConfig.startLabel,
                  style: TextStyle(
                    color: _isTracking ? AppConfig.disabledColor : AppConfig.primaryTextColor,
                    fontSize: AppConfig.startButtonFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConfig.extraLargePadding),
            
            // Event buttons (fill remaining space)
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (!_isTracking) _startSession();
                        _recordEvent(AppConfig.hitEvent);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppConfig.buttonBackgroundColor,
                        side: const BorderSide(color: AppConfig.hitColor),
                        minimumSize: const Size(double.infinity, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                        ),
                      ),
                      child: const Text(AppConfig.hitLabel, style: TextStyle(color: AppConfig.hitColor, fontSize: AppConfig.eventButtonFontSize)),
                    ),
                  ),
                  const SizedBox(height: AppConfig.largePadding),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (!_isTracking) _startSession();
                        _recordEvent(AppConfig.spawnEvent);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppConfig.buttonBackgroundColor,
                        side: const BorderSide(color: AppConfig.spawnColor),
                        minimumSize: const Size(double.infinity, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                        ),
                      ),
                      child: const Text(AppConfig.spawnLabel, style: TextStyle(color: AppConfig.spawnColor, fontSize: AppConfig.eventButtonFontSize)),
                    ),
                  ),
                  const SizedBox(height: AppConfig.largePadding),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (!_isTracking) _startSession();
                        _recordEvent(AppConfig.killEvent);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppConfig.buttonBackgroundColor,
                        side: const BorderSide(color: AppConfig.killColor),
                        minimumSize: const Size(double.infinity, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                        ),
                      ),
                      child: const Text(AppConfig.killLabel, style: TextStyle(color: AppConfig.killColor, fontSize: AppConfig.eventButtonFontSize)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

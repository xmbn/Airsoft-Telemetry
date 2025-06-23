import 'package:flutter/material.dart';
import '../services/app_config.dart';

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
        padding: EdgeInsets.all(AppConfig.standardPadding),
        color: Colors.black,
        child: SafeArea(
          child: Column(
            children: [
              // Start button
              SizedBox(
                width: double.infinity,
                height: AppConfig.startButtonHeight,
                child: OutlinedButton(
                  onPressed: _isTracking ? null : _startSession,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _isTracking ? Colors.grey : Colors.white),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                    ),
                  ),
                  child: Text(
                    AppConfig.startLabel,
                    style: TextStyle(
                      color: _isTracking ? Colors.grey : Colors.white,
                      fontSize: AppConfig.startButtonFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppConfig.extraLargePadding),
              
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
                          backgroundColor: Colors.black,
                          side: BorderSide(color: Colors.red),
                          minimumSize: Size(double.infinity, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                          ),
                        ),
                        child: Text(AppConfig.hitLabel, style: TextStyle(color: Colors.red, fontSize: AppConfig.eventButtonFontSize)),
                      ),
                    ),
                    SizedBox(height: AppConfig.largePadding),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          if (!_isTracking) _startSession();
                          _recordEvent(AppConfig.spawnEvent);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black,
                          side: BorderSide(color: Colors.green),
                          minimumSize: Size(double.infinity, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                          ),
                        ),
                        child: Text(AppConfig.spawnLabel, style: TextStyle(color: Colors.green, fontSize: AppConfig.eventButtonFontSize)),
                      ),
                    ),
                    SizedBox(height: AppConfig.largePadding),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          if (!_isTracking) _startSession();
                          _recordEvent(AppConfig.killEvent);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black,
                          side: BorderSide(color: Colors.amber),
                          minimumSize: Size(double.infinity, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                          ),
                        ),
                        child: Text(AppConfig.killLabel, style: TextStyle(color: Colors.amber, fontSize: AppConfig.eventButtonFontSize)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

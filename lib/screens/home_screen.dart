import 'package:airsoft_telemetry_flutter/utils/location_formatter.dart';
import 'package:airsoft_telemetry_flutter/utils/measure_formatter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:airsoft_telemetry_flutter/services/app_config.dart';
import 'package:airsoft_telemetry_flutter/services/telemetry_service.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TelemetryService _telemetryService = TelemetryService();
  SessionState _sessionState = SessionState.stopped;
  Position? _currentPosition;

  StreamSubscription<SessionState>? _sessionStateSubscription;
  StreamSubscription<Position?>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _initializeTelemetry();
  }

  Future<void> _initializeTelemetry() async {
    await _telemetryService.initialize();

    // Listen to session state changes
    _sessionStateSubscription =
        _telemetryService.sessionStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _sessionState = state;
        });
      }
    });

    // Listen to position updates
    _positionSubscription = _telemetryService.positionStream.listen((position) {
      if (mounted && position != null) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    // Set initial state
    setState(() {
      _sessionState = _telemetryService.sessionState;
      _currentPosition = _telemetryService.lastPosition;
    });
  }

  @override
  void dispose() {
    _sessionStateSubscription?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  void _startSession() async {
    await _telemetryService.startSession();
  }

  void _pauseSession() async {
    await _telemetryService.pauseSession();
  }

  void _resumeSession() async {
    await _telemetryService.resumeSession();
  }

  void _stopSession() async {
    await _telemetryService.stopSession();
  }

  void _recordEvent(String eventType) async {
    await _telemetryService.recordManualEvent(eventType);
  }

  Widget _buildControlButton() {
    switch (_sessionState) {
      case SessionState.stopped:
        return SizedBox(
          width: double.infinity,
          height: AppConfig.startButtonHeight,
          child: OutlinedButton(
            onPressed: _startSession,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppConfig.primaryTextColor),
              backgroundColor: AppConfig.buttonBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConfig.buttonBorderRadius),
              ),
            ),
            child: const Text(
              AppConfig.startLabel,
              style: TextStyle(
                color: AppConfig.primaryTextColor,
                fontSize: AppConfig.startButtonFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      case SessionState.running:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: AppConfig.startButtonHeight,
                child: OutlinedButton(
                  onPressed: _pauseSession,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                    backgroundColor: AppConfig.buttonBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConfig.buttonBorderRadius),
                    ),
                  ),
                  child: const Text(
                    AppConfig.pauseLabel,
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: AppConfig.startButtonFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConfig.mediumPadding),
            Expanded(
              child: SizedBox(
                height: AppConfig.startButtonHeight,
                child: OutlinedButton(
                  onPressed: _stopSession,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    backgroundColor: AppConfig.buttonBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConfig.buttonBorderRadius),
                    ),
                  ),
                  child: const Text(
                    AppConfig.stopLabel,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: AppConfig.startButtonFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      case SessionState.paused:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: AppConfig.startButtonHeight,
                child: OutlinedButton(
                  onPressed: _resumeSession,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    backgroundColor: AppConfig.buttonBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConfig.buttonBorderRadius),
                    ),
                  ),
                  child: const Text(
                    AppConfig.resumeLabel,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: AppConfig.startButtonFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConfig.mediumPadding),
            Expanded(
              child: SizedBox(
                height: AppConfig.startButtonHeight,
                child: OutlinedButton(
                  onPressed: _stopSession,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    backgroundColor: AppConfig.buttonBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConfig.buttonBorderRadius),
                    ),
                  ),
                  child: const Text(
                    AppConfig.stopLabel,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: AppConfig.startButtonFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
    }
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
            // Control buttons (start/pause/resume/stop)
            _buildControlButton(),
            const SizedBox(height: AppConfig.extraLargePadding),

            // Current position display
            if (_currentPosition != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConfig.mediumPadding),
                decoration: BoxDecoration(
                  border: Border.all(color: AppConfig.outlineColor),
                  borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Current Position',
                      style: TextStyle(
                        color: AppConfig.disabledColor,
                        fontSize: AppConfig.sectionTitleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConfig.smallPadding),
                    Text(
                      '${LocationFormatter.formatLatitude(_currentPosition!.latitude)}; '
                      '${LocationFormatter.formatLongitude(_currentPosition!.longitude)}; '
                      '${MeasureFormatter.formatAltitude(_currentPosition!.altitude)}',
                      style: const TextStyle(color: AppConfig.primaryTextColor, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConfig.extraLargePadding),
            ],

            // Event buttons (fill remaining space)
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _sessionState == SessionState.paused
                          ? null
                          : () => _recordEvent(AppConfig.hitEvent),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppConfig.buttonBackgroundColor,
                        side: BorderSide(
                            color: _sessionState == SessionState.paused
                                ? AppConfig.disabledColor
                                : AppConfig.hitColor),
                        minimumSize: const Size(double.infinity, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConfig.buttonBorderRadius),
                        ),
                      ),
                      child: Text(AppConfig.hitLabel,
                          style: TextStyle(
                              color: _sessionState == SessionState.paused
                                  ? AppConfig.disabledColor
                                  : AppConfig.hitColor,
                              fontSize: AppConfig.eventButtonFontSize)),
                    ),
                  ),
                  const SizedBox(height: AppConfig.largePadding),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _sessionState == SessionState.paused
                          ? null
                          : () => _recordEvent(AppConfig.spawnEvent),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppConfig.buttonBackgroundColor,
                        side: BorderSide(
                            color: _sessionState == SessionState.paused
                                ? AppConfig.disabledColor
                                : AppConfig.spawnColor),
                        minimumSize: const Size(double.infinity, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConfig.buttonBorderRadius),
                        ),
                      ),
                      child: Text(AppConfig.spawnLabel,
                          style: TextStyle(
                              color: _sessionState == SessionState.paused
                                  ? AppConfig.disabledColor
                                  : AppConfig.spawnColor,
                              fontSize: AppConfig.eventButtonFontSize)),
                    ),
                  ),
                  const SizedBox(height: AppConfig.largePadding),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _sessionState == SessionState.paused
                          ? null
                          : () => _recordEvent(AppConfig.killEvent),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppConfig.buttonBackgroundColor,
                        side: BorderSide(
                            color: _sessionState == SessionState.paused
                                ? AppConfig.disabledColor
                                : AppConfig.killColor),
                        minimumSize: const Size(double.infinity, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConfig.buttonBorderRadius),
                        ),
                      ),
                      child: Text(AppConfig.killLabel,
                          style: TextStyle(
                              color: _sessionState == SessionState.paused
                                  ? AppConfig.disabledColor
                                  : AppConfig.killColor,
                              fontSize: AppConfig.eventButtonFontSize)),
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

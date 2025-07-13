import 'package:airsoft_telemetry_flutter/utils/location_formatter.dart';
import 'package:airsoft_telemetry_flutter/utils/measure_formatter.dart';
import 'dart:async';

import 'package:airsoft_telemetry_flutter/services/location_service.dart';
import 'package:airsoft_telemetry_flutter/services/telemetry_service.dart';
import 'package:airsoft_telemetry_flutter/services/preferences_service.dart';
import 'package:airsoft_telemetry_flutter/services/export_service.dart';
import 'package:airsoft_telemetry_flutter/models/game_event.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:airsoft_telemetry_flutter/services/app_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TelemetryService _telemetryService = TelemetryService();
  final PreferencesService _preferencesService = PreferencesService();
  final LocationService _locationService = LocationService();
  final ExportService _exportService = ExportService();
  String _playerName = AppConfig.defaultPlayerName;
  String _selectedInterval = AppConfig.defaultInterval;
  List<GameEvent> _events = [];
  late final TextEditingController _playerNameController;
  Position? _currentPosition;

  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<Position?>? _telemetryPositionSubscription;
  StreamSubscription<List<GameEvent>>? _eventsSubscription;

  @override
  void initState() {
    super.initState();
    // Initialize controller immediately to prevent LateInitializationError
    _playerNameController = TextEditingController(text: _playerName);
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    // Initialize telemetry service
    await _telemetryService.initialize();

    // Load preferences
    final preferences = await _preferencesService.loadAllPreferences();
    _playerName = preferences['playerName'] ?? AppConfig.defaultPlayerName;
    _selectedInterval = preferences['interval'] ?? AppConfig.defaultInterval;

    // Update controller text with loaded preferences
    _playerNameController.text = _playerName;
    _playerNameController.addListener(() {
      if (mounted) {
        setState(() {
          _playerName = _playerNameController.text;
        });
        _savePlayerName();
      }
    });

    // Get initial position
    _locationService.getCurrentPosition().then((position) {
      if (mounted && position != null) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    // Listen to position updates
    _listenToLocationStream();
    _listenToTelemetryUpdates();

    // Set initial state
    if (mounted) {
      setState(() {});
    }
  }

  void _listenToLocationStream() {
    _positionStreamSubscription =
        _locationService.getPositionStream().listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });
  }

  void _listenToTelemetryUpdates() {
    // Immediately load cached events to avoid empty state
    _events = _telemetryService.cachedRecentEvents;

    // Listen to telemetry position updates
    _telemetryPositionSubscription =
        _telemetryService.positionStream.listen((position) {
      if (mounted && position != null) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    // Listen to recent events updates
    _eventsSubscription = _telemetryService.recentEventsStream.listen((events) {
      if (mounted) {
        setState(() {
          _events = events;
        });
      }
    });
  }

  Future<void> _savePlayerName() async {
    await _telemetryService.updatePlayerName(_playerName);
  }

  Future<void> _saveInterval() async {
    await _telemetryService.updateInterval(_selectedInterval);
  }

  Future<void> _exportData() async {
    if (!mounted) return;

    try {
      final stats = await _exportService.getExportStats();

      if (stats['eventCount'] == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No data to export')),
          );
        }
        return;
      }

      // Show confirmation dialog with stats
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppConfig.surfaceColor,
          title: const Text('Export Data',
              style: TextStyle(color: AppConfig.primaryTextColor)),
          content: Text(
            'Export ${stats['eventCount']} events from ${stats['sessionCount']} sessions?\n\nDate range: ${stats['dateRange']}',
            style: const TextStyle(color: AppConfig.primaryTextColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppConfig.primaryTextColor)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child:
                  const Text('Export', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        final filePath = await _exportService.exportToCsv();
        if (mounted && filePath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data exported to: $filePath')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _clearData() async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConfig.surfaceColor,
        title: const Text('Clear All Data',
            style: TextStyle(color: AppConfig.primaryTextColor)),
        content: const Text(
          'This will permanently delete all recorded events. This action cannot be undone.',
          style: TextStyle(color: AppConfig.primaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppConfig.primaryTextColor)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final count = await _telemetryService.clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted $count events')),
        );
      }
    }
  }

  // Returns only lat, long, alt, time (no event type)
  String _formatEventForDisplayNoType(GameEvent event) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(event.timestamp);
    final timeString = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    return '${LocationFormatter.formatLatitude(event.latitude)},'
        '${LocationFormatter.formatLongitude(event.longitude)},'
        '${MeasureFormatter.formatAltitude(event.altitude)} $timeString';
  }

  // Color coding for event types
  Color _getEventTypeColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'start':
        return Colors.green;
      case 'stop':
        return Colors.red;
      case 'hit':
        return Colors.orange;
      case 'move':
        return Colors.blue;
      default:
        return AppConfig.primaryTextColor;
    }
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _positionStreamSubscription?.cancel();
    _telemetryPositionSubscription?.cancel();
    _eventsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.all(AppConfig.standardPadding),
        color: AppConfig.scaffoldBackgroundColor,
        child: Column(
          children: [
            // Player name and interval
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: AppConfig.smallPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.only(left: AppConfig.largePadding),
                          child: Text(AppConfig.playerNameLabel,
                              style: TextStyle(color: AppConfig.disabledColor)),
                        ),
                        const SizedBox(height: AppConfig.smallPadding),
                        SizedBox(
                          height: AppConfig.inputFieldHeight,
                          child: TextFormField(
                            controller: _playerNameController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppConfig.outlineColor),
                                  borderRadius: BorderRadius.circular(
                                      AppConfig.inputBorderRadius)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppConfig.outlineColor),
                                  borderRadius: BorderRadius.circular(
                                      AppConfig.inputBorderRadius)),
                            ),
                            style: const TextStyle(
                                color: AppConfig.primaryTextColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: AppConfig.smallPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.only(left: AppConfig.largePadding),
                          child: Text(AppConfig.intervalLabel,
                              style: TextStyle(color: AppConfig.disabledColor)),
                        ),
                        const SizedBox(height: AppConfig.smallPadding),
                        SizedBox(
                          height: AppConfig.inputFieldHeight,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            dropdownColor: AppConfig.buttonBackgroundColor,
                            value: _selectedInterval,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppConfig.outlineColor),
                                  borderRadius: BorderRadius.circular(
                                      AppConfig.inputBorderRadius)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppConfig.outlineColor),
                                  borderRadius: BorderRadius.circular(
                                      AppConfig.inputBorderRadius)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppConfig.largePadding,
                                  vertical: AppConfig.smallPadding),
                            ),
                            items: AppConfig.intervalOptions
                                .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e,
                                        style: const TextStyle(
                                            color:
                                                AppConfig.primaryTextColor))))
                                .toList(),
                            onChanged: (value) => setState(() {
                              if (value != null) {
                                _selectedInterval = value;
                                _saveInterval();
                              }
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConfig.extraLargePadding),

            // Location Data
            const Text(
              AppConfig.locationDataLabel,
              style: TextStyle(
                  color: AppConfig.disabledColor,
                  fontSize: AppConfig.sectionTitleFontSize,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConfig.mediumPadding),
            Container(
              padding: const EdgeInsets.all(AppConfig.mediumPadding),
              decoration: BoxDecoration(
                  border: Border.all(color: AppConfig.outlineColor),
                  borderRadius:
                      BorderRadius.circular(AppConfig.inputBorderRadius)),
              alignment: Alignment.center,
              child: Center(
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: IntrinsicColumnWidth(),
                  },
                  children: [
                    // Latitude
                    TableRow(children: [
                      Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${AppConfig.latitudeLabel}:',
                          style: const TextStyle(color: AppConfig.primaryTextColor),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '  ${_currentPosition != null
                              ? LocationFormatter.formatLatitude(_currentPosition!.latitude)
                              : 'N/A'}',
                          style: const TextStyle(color: AppConfig.primaryTextColor),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      SizedBox(height: AppConfig.smallPadding),
                      SizedBox(height: AppConfig.smallPadding),
                    ]),
                    // Longitude
                    TableRow(children: [
                      Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${AppConfig.longitudeLabel}:',
                          style: const TextStyle(color: AppConfig.primaryTextColor),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '  ${_currentPosition != null
                              ? LocationFormatter.formatLongitude(_currentPosition!.longitude)
                              : 'N/A'}',
                          style: const TextStyle(color: AppConfig.primaryTextColor),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      SizedBox(height: AppConfig.smallPadding),
                      SizedBox(height: AppConfig.smallPadding),
                    ]),
                    // Altitude
                    TableRow(children: [
                      Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${AppConfig.altitudeLabel}:',
                          style: const TextStyle(color: AppConfig.primaryTextColor),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '  ${MeasureFormatter.formatAltitude(_currentPosition?.altitude)}',
                          style: const TextStyle(color: AppConfig.primaryTextColor),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      SizedBox(height: AppConfig.smallPadding),
                      SizedBox(height: AppConfig.smallPadding),
                    ]),
                    // Azimuth
                    TableRow(children: [
                      Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${AppConfig.azimuthLabel}:',
                          style: const TextStyle(color: AppConfig.primaryTextColor),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '  ${MeasureFormatter.formatAzimuth(_currentPosition?.heading)}',
                          style: const TextStyle(color: AppConfig.primaryTextColor),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      SizedBox(height: AppConfig.smallPadding),
                      SizedBox(height: AppConfig.smallPadding),
                    ]),
                    // Speed
                    TableRow(children: [
                      Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${AppConfig.speedLabel}:',
                          style: const TextStyle(color: AppConfig.primaryTextColor),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '  ${MeasureFormatter.formatSpeed(_currentPosition?.speed)}',
                          style: const TextStyle(color: AppConfig.primaryTextColor),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ]),
                    TableRow(children: [
                      SizedBox(height: AppConfig.smallPadding),
                      SizedBox(height: AppConfig.smallPadding),
                    ]),
                    // Accuracy
                    TableRow(children: [
                      Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${AppConfig.accuracyLabel}:',
                          style: const TextStyle(color: AppConfig.primaryTextColor),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '  ${MeasureFormatter.formatAccuracy(_currentPosition?.accuracy)}',
                          style: const TextStyle(color: AppConfig.primaryTextColor),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConfig.extraLargePadding),

            // Export and clear
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _exportData,
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppConfig.outlineColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConfig.buttonBorderRadius),
                        )),
                    child: const Text(AppConfig.exportDataLabel,
                        style: TextStyle(color: AppConfig.primaryTextColor)),
                  ),
                ),
                const SizedBox(width: AppConfig.mediumPadding),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearData,
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppConfig.outlineColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConfig.buttonBorderRadius),
                        )),
                    child: const Text(AppConfig.clearDataLabel,
                        style: TextStyle(color: AppConfig.primaryTextColor)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConfig.extraLargePadding),

            // Event log
            const Text(
              AppConfig.eventLogTitle,
              style: TextStyle(
                  color: AppConfig.disabledColor,
                  fontSize: AppConfig.sectionTitleFontSize,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConfig.mediumPadding),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppConfig.mediumPadding),
                decoration: BoxDecoration(
                    border: Border.all(color: AppConfig.outlineColor),
                    borderRadius:
                        BorderRadius.circular(AppConfig.inputBorderRadius)),
                child: ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    final eventTypeColor = _getEventTypeColor(event.eventType);
                    final eventTypeText = event.eventType;
                    final eventDetails = _formatEventForDisplayNoType(event);
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppConfig.smallPadding),
                      child: Row(
                        children: [
                          Text(
                            eventTypeText,
                            style: TextStyle(
                                color: eventTypeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              eventDetails,
                              style: const TextStyle(
                                  color: AppConfig.primaryTextColor, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
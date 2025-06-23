import 'dart:async';

import 'package:airsoft_telemetry_flutter/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/app_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _playerName = AppConfig.defaultPlayerName;
  String _selectedInterval = AppConfig.defaultInterval;
  final List<Map<String, String>> _events = [];
  late final TextEditingController _playerNameController;
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _playerNameController = TextEditingController(text: _playerName);
    _playerNameController.addListener(() {
      if (mounted) {
        setState(() {
          _playerName = _playerNameController.text;
        });
      }
    });
    _locationService.getCurrentPosition().then((position) {
      if (mounted && position != null) {
        setState(() {
          _currentPosition = position;
        });
      }
    });
    _listenToLocationStream();
  }

  void _listenToLocationStream() {
    _positionStreamSubscription = _locationService.getPositionStream().listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.all(AppConfig.standardPadding),
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
                    padding: EdgeInsets.only(right: AppConfig.smallPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: AppConfig.largePadding),
                          child: Text(AppConfig.playerNameLabel, style: TextStyle(color: AppConfig.disabledColor)),
                        ),
                        SizedBox(height: AppConfig.smallPadding),
                        SizedBox(
                          height: AppConfig.inputFieldHeight,
                          child: TextFormField(
                            controller: _playerNameController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: AppConfig.outlineColor),
                                  borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: AppConfig.outlineColor),
                                  borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius)),
                            ),
                            style: TextStyle(color: AppConfig.primaryTextColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(left: AppConfig.smallPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: AppConfig.largePadding),
                          child: Text(AppConfig.intervalLabel, style: TextStyle(color: AppConfig.disabledColor)),
                        ),
                        SizedBox(height: AppConfig.smallPadding),
                        SizedBox(
                          height: AppConfig.inputFieldHeight,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            dropdownColor: AppConfig.buttonBackgroundColor,
                            value: _selectedInterval,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: AppConfig.outlineColor),
                                  borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: AppConfig.outlineColor),
                                  borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius)),
                              contentPadding: EdgeInsets.symmetric(horizontal: AppConfig.largePadding, vertical: AppConfig.smallPadding),
                            ),
                            items: AppConfig.intervalOptions
                                .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e, style: TextStyle(color: AppConfig.primaryTextColor))))
                                .toList(),
                            onChanged: (value) => setState(() {
                              if (value != null) _selectedInterval = value;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConfig.extraLargePadding),
            
            // Location Data
            Text(
              AppConfig.locationDataLabel,
              style: TextStyle(color: AppConfig.disabledColor, fontSize: AppConfig.sectionTitleFontSize, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppConfig.mediumPadding),
            Container(
              padding: EdgeInsets.all(AppConfig.mediumPadding),
              decoration: BoxDecoration(
                  border: Border.all(color: AppConfig.outlineColor),
                  borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppConfig.latitudeLabel, style: TextStyle(color: AppConfig.primaryTextColor)),
                      Text('${_currentPosition?.latitude ?? 'N/A'}', style: TextStyle(color: AppConfig.primaryTextColor)),
                    ],
                  ),
                  SizedBox(height: AppConfig.smallPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppConfig.longitudeLabel, style: TextStyle(color: AppConfig.primaryTextColor)),
                      Text('${_currentPosition?.longitude ?? 'N/A'}', style: TextStyle(color: AppConfig.primaryTextColor)),
                    ],
                  ),
                  SizedBox(height: AppConfig.smallPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppConfig.azimuthLabel, style: TextStyle(color: AppConfig.primaryTextColor)),
                      Text('${_currentPosition?.heading ?? 'N/A'}', style: TextStyle(color: AppConfig.primaryTextColor)),
                    ],
                  ),
                  SizedBox(height: AppConfig.smallPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppConfig.speedLabel, style: TextStyle(color: AppConfig.primaryTextColor)),
                      Text('${_currentPosition?.speed ?? 'N/A'}', style: TextStyle(color: AppConfig.primaryTextColor)),
                    ],
                  ),
                  SizedBox(height: AppConfig.smallPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppConfig.accuracyLabel, style: TextStyle(color: AppConfig.primaryTextColor)),
                      Text('${_currentPosition?.accuracy ?? 'N/A'}', style: TextStyle(color: AppConfig.primaryTextColor)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppConfig.extraLargePadding),
            
            // Export and clear
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppConfig.outlineColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                        )),
                    child: Text(AppConfig.exportDataLabel, style: TextStyle(color: AppConfig.primaryTextColor)),
                  ),
                ),
                SizedBox(width: AppConfig.mediumPadding),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppConfig.outlineColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                        )),
                    child: Text(AppConfig.clearDataLabel, style: TextStyle(color: AppConfig.primaryTextColor)),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConfig.extraLargePadding),
            
            // Event log
            Text(
              AppConfig.eventLogTitle,
              style: TextStyle(color: AppConfig.disabledColor, fontSize: AppConfig.sectionTitleFontSize, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppConfig.mediumPadding),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(AppConfig.mediumPadding),
                decoration: BoxDecoration(
                    border: Border.all(color: AppConfig.outlineColor),
                    borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius)),
                child: ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final e = _events[index];
                    return Text(
                      '${e['type']} -- Lat: ${e['lat']}, Lng: ${e['lng']}, Az: ${e['az']} @ ${e['time']}',
                      style: TextStyle(color: AppConfig.primaryTextColor),
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

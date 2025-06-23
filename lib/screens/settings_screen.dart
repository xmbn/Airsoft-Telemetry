import 'package:flutter/material.dart';
import '../services/app_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _playerName = AppConfig.defaultPlayerName;
  String _selectedInterval = AppConfig.defaultInterval;
  bool _isTracking = AppConfig.defaultIsTracking;
  bool _isPaused = AppConfig.defaultIsPaused;
  final List<Map<String, String>> _events = [];
  late final TextEditingController _playerNameController;

  @override
  void initState() {
    super.initState();
    _playerNameController = TextEditingController(text: _playerName);
    _playerNameController.addListener(() {
      setState(() {
        _playerName = _playerNameController.text;
      });
    });
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(AppConfig.settingsTitle, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(AppConfig.standardPadding),
        color: Colors.black,
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
                          child: Text(AppConfig.playerNameLabel, style: TextStyle(color: Colors.grey)),
                        ),
                        SizedBox(height: AppConfig.smallPadding),
                        SizedBox(
                          height: AppConfig.inputFieldHeight,
                          child: TextFormField(
                            controller: _playerNameController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius)),
                            ),
                            style: TextStyle(color: Colors.white),
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
                          child: Text(AppConfig.intervalLabel, style: TextStyle(color: Colors.grey)),
                        ),
                        SizedBox(height: AppConfig.smallPadding),
                        SizedBox(
                          height: AppConfig.inputFieldHeight,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            dropdownColor: Colors.black,
                            value: _selectedInterval,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius)),
                              contentPadding: EdgeInsets.symmetric(horizontal: AppConfig.largePadding, vertical: AppConfig.smallPadding),
                            ),
                            items: AppConfig.intervalOptions
                                .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e, style: TextStyle(color: Colors.white))))
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
            
            // Session controls
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                        )),
                    child: Text(
                        _isTracking
                            ? (_isPaused ? AppConfig.resumeLabel : AppConfig.pauseLabel)
                            : AppConfig.startLabel,
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: AppConfig.mediumPadding),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                        )),
                    child: Text(AppConfig.stopLabel, style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConfig.extraLargePadding),
            
            // Export and clear
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                        )),
                    child: Text(AppConfig.exportDataLabel, style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: AppConfig.mediumPadding),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
                        )),
                    child: Text(AppConfig.clearDataLabel, style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConfig.extraLargePadding),
            
            // Event log
            Text(
              AppConfig.eventLogTitle,
              style: TextStyle(color: Colors.grey, fontSize: AppConfig.regularFontSize, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppConfig.mediumPadding),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(AppConfig.mediumPadding),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius)),
                child: ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final e = _events[index];
                    return Text(
                      '${e['type']} -- Lat: ${e['lat']}, Lng: ${e['lng']}, Az: ${e['az']} @ ${e['time']}',
                      style: TextStyle(color: Colors.white),
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

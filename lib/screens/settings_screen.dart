import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _playerName = '';
  String _selectedInterval = '2s';
  bool _isTracking = false;
  bool _isPaused = false;
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
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
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
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text('Player Name', style: TextStyle(color: Colors.grey)),
                        ),
                        SizedBox(height: 4),
                        SizedBox(
                          height: 48,
                          child: TextFormField(
                            controller: _playerNameController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8)),
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
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text('Interval', style: TextStyle(color: Colors.grey)),
                        ),
                        SizedBox(height: 4),
                        SizedBox(
                          height: 48,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            dropdownColor: Colors.black,
                            value: _selectedInterval,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            ),
                            items: ['1s', '2s', '3s', '4s', '5s', '10s', '30s', '60s']
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
            SizedBox(height: 24),
            
            // Session controls
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey)),
                    child: Text(
                        _isTracking
                            ? (_isPaused ? 'RESUME' : 'PAUSE')
                            : 'START',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey)),
                    child: Text('STOP', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // Export and clear
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey)),
                    child: Text('Export Data', style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey)),
                    child: Text('Clear Data', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // Event log
            Text(
              'Event Log',
              style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8)),
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

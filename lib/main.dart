import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airsoft Telemetry',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Airsoft Telemetry'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // State variables for Airsoft Telemetry UI
  String _playerName = '';
  String _selectedInterval = '2s';
  bool _isTracking = false;
  bool _isPaused = false;
  final List<Map<String, String>> _events = [];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        // remove AppBar title to avoid duplicate headers
        title: SizedBox.shrink(),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        color: Colors.black,
        child: Column(
          children: [
            // Title
            Text(
              'Airsoft Telemetry',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            // Player name and interval
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Player Name', style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 4),
                      TextFormField(
                        initialValue: _playerName,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        style: TextStyle(color: Colors.white),
                        onChanged: (value) => setState(() => _playerName = value),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Interval', style: TextStyle(color: Colors.grey)),
                      DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: Colors.black,
                        value: _selectedInterval,
                        items: ['1s', '2s', '3s', '4s', '5s', '10s', '30s', '60s']
                            .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e, style: TextStyle(color: Colors.white))))
                            .toList(),
                        onChanged: (value) => setState(() {
                          if (value != null) _selectedInterval = value;
                        }),
                        underline: Container(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
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
            SizedBox(height: 12),
            // Event buttons (fill full width)
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black,
                          side: BorderSide(color: Colors.red),
                          minimumSize: Size(double.infinity, 0)),
                      child: Text('HIT', style: TextStyle(color: Colors.red, fontSize: 24)),
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black,
                          side: BorderSide(color: Colors.green),
                          minimumSize: Size(double.infinity, 0)),
                      child: Text('SPAWN', style: TextStyle(color: Colors.green, fontSize: 24)),
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black,
                          side: BorderSide(color: Colors.amber),
                          minimumSize: Size(double.infinity, 0)),
                      child: Text('KILL', style: TextStyle(color: Colors.amber, fontSize: 24)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
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
            SizedBox(height: 12),
            // Event log
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8)),
              height: 120,
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
          ],
        ),
      ),
    );
  }
}

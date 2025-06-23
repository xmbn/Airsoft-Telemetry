import 'package:flutter/material.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isTracking = false;

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
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Airsoft Telemetry', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
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
            SizedBox(height: 24),
            
            // Start button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton(
                onPressed: _isTracking ? null : _startSession,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _isTracking ? Colors.grey : Colors.white),
                  backgroundColor: Colors.black,
                ),
                child: Text(
                  'START',
                  style: TextStyle(
                    color: _isTracking ? Colors.grey : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // Event buttons (fill remaining space)
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (!_isTracking) _startSession();
                        _recordEvent('HIT');
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.black,
                        side: BorderSide(color: Colors.red),
                        minimumSize: Size(double.infinity, 0),
                      ),
                      child: Text('HIT', style: TextStyle(color: Colors.red, fontSize: 24)),
                    ),
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (!_isTracking) _startSession();
                        _recordEvent('SPAWN');
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.black,
                        side: BorderSide(color: Colors.green),
                        minimumSize: Size(double.infinity, 0),
                      ),
                      child: Text('SPAWN', style: TextStyle(color: Colors.green, fontSize: 24)),
                    ),
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (!_isTracking) _startSession();
                        _recordEvent('KILL');
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.black,
                        side: BorderSide(color: Colors.amber),
                        minimumSize: Size(double.infinity, 0),
                      ),
                      child: Text('KILL', style: TextStyle(color: Colors.amber, fontSize: 24)),
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

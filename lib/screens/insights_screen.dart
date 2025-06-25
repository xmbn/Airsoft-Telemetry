import 'package:flutter/material.dart';
import 'package:airsoft_telemetry_flutter/services/app_config.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  // Sample data - replace with actual data from your service
  final Map<String, int> _eventCounts = {
    'HIT': 15,
    'SPAWN': 8,
    'KILL': 12,
  };

  final int _totalEvents = 35;
  final String _sessionDuration = '1h 23m';
  final String _lastEvent = 'KILL at 14:32';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      extendBody: false,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Insights', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: const EdgeInsets.all(AppConfig.standardPadding),
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Summary
            const Text(
              'Session Summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConfig.standardPadding),
            
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Total Events', _totalEvents.toString(), Colors.blue),
                ),
                const SizedBox(width: AppConfig.mediumPadding),
                Expanded(
                  child: _buildStatCard('Duration', _sessionDuration, Colors.green),
                ),
              ],
            ),
            const SizedBox(height: AppConfig.standardPadding),
            
            // Event Breakdown
            const Text(
              'Event Breakdown',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConfig.largePadding),
            
            // Event counts
            _buildEventRow('HIT', _eventCounts['HIT']!, Colors.red),
            const SizedBox(height: AppConfig.mediumPadding),
            _buildEventRow('SPAWN', _eventCounts['SPAWN']!, Colors.green),
            const SizedBox(height: AppConfig.mediumPadding),
            _buildEventRow('KILL', _eventCounts['KILL']!, Colors.amber),
            
            const SizedBox(height: AppConfig.extraLargePadding),
            
            // Recent Activity
            const Text(
              'Recent Activity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConfig.largePadding),
            
            Container(
              padding: const EdgeInsets.all(AppConfig.standardPadding),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Last Event:',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: AppConfig.smallPadding),
                  Text(
                    _lastEvent,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Navigation hint
            const Center(
              child: Text(
                'Swipe left/right to navigate',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConfig.standardPadding),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppConfig.inputBorderRadius),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConfig.smallPadding),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventRow(String eventType, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: AppConfig.mediumPadding),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(AppConfig.buttonBorderRadius),
          ),
          child: Text(
            eventType,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: AppConfig.standardPadding),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: count / _totalEvents,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConfig.mediumPadding),
        Text(
          count.toString(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

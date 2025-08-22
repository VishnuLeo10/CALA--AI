// lib/screens/water_tracker.dart
import 'package:flutter/material.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  int _glassesDrunk = 0;
  final int _dailyGoal = 8;

  void _incrementGlass() {
    if (_glassesDrunk < _dailyGoal) {
      setState(() {
        _glassesDrunk++;
      });
    }
  }

  void _resetGlasses() {
    setState(() {
      _glassesDrunk = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Tracker'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Daily Water Intake',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: _glassesDrunk / _dailyGoal,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                  ),
                ),
                Text(
                  '$_glassesDrunk / $_dailyGoal\nGlasses',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _incrementGlass,
              icon: const Icon(Icons.local_drink),
              label: const Text('Add Glass'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _resetGlasses,
              child: const Text('Reset'),
            )
          ],
        ),
      ),
    );
  }
}

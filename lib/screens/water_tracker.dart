import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  int _glassesDrunk = 0;
  final int _dailyGoal = 8;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _userId = _auth.currentUser!.uid;
    _loadWaterData();
  }

  // Load today's water intake from Firestore
  Future<void> _loadWaterData() async {
    final doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('water')
        .doc(_todayDocId())
        .get();

    if (doc.exists) {
      setState(() {
        _glassesDrunk = doc['glasses'] ?? 0;
      });
    }
  }

  // Increment glasses and save to Firestore
  Future<void> _incrementGlass() async {
    if (_glassesDrunk < _dailyGoal) {
      setState(() {
        _glassesDrunk++;
      });
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('water')
          .doc(_todayDocId())
          .set({'glasses': _glassesDrunk, 'updatedAt': FieldValue.serverTimestamp()});
    }
  }

  // Reset glasses and update Firestore
  Future<void> _resetGlasses() async {
    setState(() {
      _glassesDrunk = 0;
    });
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('water')
        .doc(_todayDocId())
        .set({'glasses': 0, 'updatedAt': FieldValue.serverTimestamp()});
  }

  // Use date string as document ID
  String _todayDocId() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
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

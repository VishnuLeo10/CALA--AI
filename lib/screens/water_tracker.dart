import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  // Define constants for easier management and changes in the future.
  static const int glassSizeMl = 250;
  static const int dailyGoalMl = 2500;

  int _waterConsumedMl = 0;
  bool _isLoading = true; // Added loading state for initial data fetch.

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _userId;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _userId = user.uid;
      _loadWaterData();
    } else {
      // Handle the unlikely case where user is null
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Generates a unique document ID for today's date (e.g., "2024-05-21").
  String _todayDocId() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Loads today's water intake from Firestore when the screen opens.
  Future<void> _loadWaterData() async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('water')
          .doc(_todayDocId())
          .get();

      if (mounted && docSnapshot.exists && docSnapshot.data() != null) {
        setState(() {
          _waterConsumedMl = docSnapshot.data()!['ml'] ?? 0;
        });
      }
    } catch (e) {
      // Handle potential errors, e.g., network issues
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading water data: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Updates the water intake in Firestore.
  /// This function is used for both adding and resetting water.
  Future<void> _updateWaterData(int newAmount) async {
    // Clamp the value to prevent it from going below zero.
    final clampedAmount = newAmount.clamp(
      0,
      10000,
    ); // 10 liters max, a safe upper limit

    setState(() {
      _waterConsumedMl = clampedAmount;
    });

    // Use .set with SetOptions(merge: true) to create the document if it
    // doesn't exist, or update it if it does. This is robust.
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('water')
        .doc(_todayDocId())
        .set({
          'ml': _waterConsumedMl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress as a value between 0.0 and 1.0
    double progress = (_waterConsumedMl / dailyGoalMl).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Tracker'),
        backgroundColor: Colors.lightBlue.shade400,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Daily Water Intake',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // The circular progress indicator visualizing the goal.
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 15,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.lightBlue.shade400,
                          ),
                        ),
                        Center(
                          child: Text(
                            '$_waterConsumedMl / $dailyGoalMl\nml',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Button to add a glass of water.
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _updateWaterData(_waterConsumedMl + glassSizeMl),
                      icon: const Icon(Icons.add),
                      label: const Text('Add One Glass (250ml)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Button to reset the count to zero.
                  TextButton.icon(
                    onPressed: () => _updateWaterData(0),
                    icon: const Icon(Icons.refresh, color: Colors.grey),
                    label: const Text(
                      'Reset Count',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
    );
  }
}

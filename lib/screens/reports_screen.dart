import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ✅ FIX: Removed unnecessary import of 'package:flutter/foundation.dart'

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<int> calories = [];
  List<int> water = [];
  List<double> bmi = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final uid = user!.uid;

    try {
      // Fetch calories
      final calSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('calories')
          .orderBy('date')
          .limit(7)
          .get();
      if (calSnapshot.docs.isNotEmpty) {
        calories = calSnapshot.docs.map((doc) => doc['value'] as int).toList();
      }

      // Fetch water intake
      final waterSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('water')
          .orderBy('date')
          .limit(7)
          .get();
      if (waterSnapshot.docs.isNotEmpty) {
        water = waterSnapshot.docs.map((doc) => doc['value'] as int).toList();
      }

      // Fetch BMI
      final bmiSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('bmi')
          .orderBy('date')
          .limit(7)
          .get();
      if (bmiSnapshot.docs.isNotEmpty) {
        bmi = bmiSnapshot.docs
            .map((doc) => (doc['value'] as num).toDouble())
            .toList();
      }
    } catch (e) {
      // debugPrint is available via material.dart, so no extra import is needed.
      debugPrint('Error fetching data: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load reports')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Weekly Summary",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),

                  if (calories.isEmpty && water.isEmpty && bmi.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text("No report data available yet."),
                      ),
                    )
                  else ...[
                    // Calories Card
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            "Calories (last 7 days):\n${calories.isNotEmpty ? calories.join(', ') : 'No data'}",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Water Intake Card
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            "Water Intake (ml, last 7 days):\n${water.isNotEmpty ? water.join(', ') : 'No data'}",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Latest BMI
                  Text(
                    "Latest BMI: ${bmi.isNotEmpty ? bmi.last.toStringAsFixed(1) : 'N/A'}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

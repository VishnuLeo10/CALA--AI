import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final user = FirebaseAuth.instance.currentUser;
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
    if (user == null) return;

    try {
      // Fetch calories
      final calSnapshot = await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('calories')
          .orderBy('date')
          .limit(7)
          .get();
      calories = calSnapshot.docs.map((doc) => (doc['value'] as int)).toList();

      // Fetch water intake
      final waterSnapshot = await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('water')
          .orderBy('date')
          .limit(7)
          .get();
      water = waterSnapshot.docs.map((doc) => (doc['value'] as int)).toList();

      // Fetch BMI
      final bmiSnapshot = await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('bmi')
          .orderBy('date')
          .limit(7)
          .get();
      bmi = bmiSnapshot.docs.map((doc) => (doc['value'] as double)).toList();
    } catch (e) {
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load reports')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Weekly Summary",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),

                  // Calories Card
                  Expanded(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          "Calories (last 7 days): ${calories.join(', ')}",
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
                          "Water Intake (ml, last 7 days): ${water.join(', ')}",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

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

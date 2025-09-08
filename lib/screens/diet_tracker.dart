// lib/screens/diet_tracker.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DietTrackerScreen extends StatefulWidget {
  const DietTrackerScreen({super.key});

  @override
  State<DietTrackerScreen> createState() => _DietTrackerScreenState();
}

class _DietTrackerScreenState extends State<DietTrackerScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _mealController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  void _addMeal() async {
    final user = _auth.currentUser;
    if (user == null) return;

    String meal = _mealController.text.trim();
    int? calories = int.tryParse(_caloriesController.text.trim());

    if (meal.isEmpty || calories == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('meals')
        .add({
      'meal': meal,
      'calories': calories,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _mealController.clear();
    _caloriesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text("User not logged in"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Tracker'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Today\'s Meals',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Meal input fields
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mealController,
                    decoration: const InputDecoration(
                      labelText: 'Meal Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Calories',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: _addMeal,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Meal list from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(user.uid)
                    .collection('meals')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final meals = snapshot.data!.docs;

                  if (meals.isEmpty) {
                    return const Center(child: Text("No meals added yet"));
                  }

                  return ListView(
                    children: meals.map((doc) {
                      final data = doc.data()! as Map<String, dynamic>;
                      return MealCard(
                        mealType: data['meal'] ?? '',
                        calories: data['calories'] ?? 0,
                      );
                    }).toList(),
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

class MealCard extends StatelessWidget {
  final String mealType;
  final int calories;

  const MealCard({super.key, required this.mealType, required this.calories});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: const Icon(Icons.restaurant, color: Colors.green),
        title: Text(mealType),
        subtitle: Text('$calories kcal'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Future: View meal details or edit
        },
      ),
    );
  }
}

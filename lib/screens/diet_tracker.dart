// lib/screens/diet_tracker.dart
import 'package:flutter/material.dart';

class DietTrackerScreen extends StatelessWidget {
  const DietTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            Expanded(
              child: ListView(
                children: const [
                  MealCard(mealType: 'Breakfast', calories: 320),
                  MealCard(mealType: 'Lunch', calories: 600),
                  MealCard(mealType: 'Dinner', calories: 450),
                  MealCard(mealType: 'Snacks', calories: 200),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Future logic: Add meal or use camera scanner
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Meal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            )
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
          // View meal details or edit
        },
      ),
    );
  }
}

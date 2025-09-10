// lib/screens/diet_tracker.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:intl/intl.dart'; // Add this import
import 'dart:typed_data';
import 'dart:convert';

class DietTrackerScreen extends StatefulWidget {
  const DietTrackerScreen({super.key});

  @override
  State<DietTrackerScreen> createState() => _DietTrackerScreenState();
}

class _DietTrackerScreenState extends State<DietTrackerScreen> {
  // Firebase & Controllers
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _mealController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  // State variables for Image & AI
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final gemini = Gemini.instance;
  bool _isAnalyzing = false;

  // --- AI Food Analysis Function ---
  Future<void> _analyzeImage() async {
    if (_imageFile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first")),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final imageBytes = await _imageFile!.readAsBytes();
      final promptText =
          "Analyze the food in this image and respond with ONLY a JSON object in this exact format: {\"food_name\": \"description of food\", \"estimated_calories\": \"number only\"}. Do not include any other text, explanations, or formatting.";

      final response = await gemini.prompt(
        parts: [Part.text(promptText), Part.bytes(imageBytes)],
      );

      final textResponse = response?.output?.trim();
      debugPrint("AI Response: $textResponse");

      if (textResponse != null && textResponse.isNotEmpty) {
        // Clean the response - remove any extra formatting
        String cleanResponse = textResponse
            .replaceAll(
              RegExp(r'```[\w]*'),
              '',
            ) // Remove all code block markers
            .trim();
        final foodName = _parseValue(cleanResponse, "food_name");
        final caloriesStr = _parseValue(cleanResponse, "estimated_calories");

        debugPrint("Parsed - Food: $foodName, Calories: $caloriesStr");

        if (foodName != null &&
            caloriesStr != null &&
            foodName.isNotEmpty &&
            caloriesStr.isNotEmpty) {
          _mealController.text = foodName;
          _caloriesController.text = caloriesStr.replaceAll(
            RegExp(r'[^\d]'),
            '',
          );

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Analysis complete!"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception(
            "Could not extract food information from AI response: $cleanResponse",
          );
        }
      } else {
        throw Exception("Received empty response from AI.");
      }
    } catch (e) {
      debugPrint("Analysis error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("AI Analysis Failed: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  // --- JSON Parsing Function ---
  String? _parseValue(String text, String key) {
    try {
      // First, try to find and extract JSON from the response
      final jsonMatch = RegExp(r'\{[^}]*\}').firstMatch(text);
      if (jsonMatch != null) {
        final jsonString = jsonMatch.group(0)!;

        // Try to parse as proper JSON first
        try {
          final Map<String, dynamic> jsonMap = json.decode(jsonString);
          final value = jsonMap[key];
          return value?.toString();
        } catch (_) {
          // If JSON parsing fails, use regex as fallback
        }
      }

      // Fallback: Use multiple regex patterns to handle different formats
      final patterns = [
        RegExp('"$key"\\s*:\\s*"([^"]*)"'),
        RegExp('"$key"\\s*:\\s*([^,}\\s]+)'),
        RegExp('$key\\s*:\\s*"([^"]*)"'),
        RegExp('$key\\s*:\\s*([^,}\\s]+)'),
      ];

      for (final pattern in patterns) {
        final match = pattern.firstMatch(text);
        if (match != null) {
          String? result = match.group(1)?.trim();
          if (result != null) {
            result = result.replaceAll('"', '');
          }
          return result;
        }
      }

      return null;
    } catch (e) {
      debugPrint("Parse error: $e");
      return null;
    }
  }

  // --- Image Picker Function ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to pick image: $e")));
    }
  }

  // --- Add Meal Function (without image upload) ---
  void _addMeal() async {
    final user = _auth.currentUser;
    if (user == null) return;

    String meal = _mealController.text.trim();
    int? calories = int.tryParse(_caloriesController.text.trim());

    if (meal.isEmpty || calories == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill meal and calorie fields")),
      );
      return;
    }

    // Save meal data with current timestamp
    await _firestore.collection('users').doc(user.uid).collection('meals').add({
      'meal': meal,
      'calories': calories,
      'timestamp': FieldValue.serverTimestamp(),
      'createdAt': DateTime.now().millisecondsSinceEpoch, // For immediate display
    });

    // Clear form and reset image
    _mealController.clear();
    _caloriesController.clear();
    setState(() {
      _imageFile = null;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Meal added successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // --- Delete Meal Function ---
  Future<void> _deleteMeal(String mealId, String mealName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Show confirmation dialog
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Meal'),
          content: Text('Are you sure you want to delete "$mealName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('meals')
            .doc(mealId)
            .delete();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Meal deleted successfully!"),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete meal: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- Format Timestamp Function ---
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      return 'Unknown time';
    }
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      // Same day - show time
      return DateFormat('h:mm a').format(dateTime);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      // Older - show date and time
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Tracker'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _imageFile != null
                  ? FutureBuilder<Uint8List>(
                      future: _imageFile!.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    )
                  : const Center(
                      child: Text(
                        "Add a photo of your meal",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gallery"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_imageFile != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _analyzeImage,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    _isAnalyzing ? "Analyzing..." : "Scan Meal with AI",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            TextField(
              controller: _mealController,
              decoration: const InputDecoration(
                labelText: 'Meal Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Calories (kcal)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Meal Entry'),
                onPressed: _addMeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Meals',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('meals')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text("No meals added yet.")),
                  );
                }
                final meals = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final doc = meals[index];
                    final data = doc.data()! as Map<String, dynamic>;
                    return MealCard(
                      mealId: doc.id,
                      mealType: data['meal'] ?? 'Unknown Meal',
                      calories: data['calories'] ?? 0,
                      timestamp: data['timestamp'] ?? data['createdAt'],
                      onDelete: _deleteMeal,
                      formatTimestamp: _formatTimestamp,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MealCard extends StatelessWidget {
  final String mealId;
  final String mealType;
  final int calories;
  final dynamic timestamp;
  final Function(String, String) onDelete;
  final String Function(dynamic) formatTimestamp;

  const MealCard({
    super.key,
    required this.mealId,
    required this.mealType,
    required this.calories,
    required this.timestamp,
    required this.onDelete,
    required this.formatTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: const Icon(Icons.restaurant, color: Colors.teal, size: 40),
        title: Text(
          mealType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$calories kcal'),
            const SizedBox(height: 4),
            Text(
              'Added: ${formatTimestamp(timestamp)}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => onDelete(mealId, mealType),
          tooltip: 'Delete meal',
        ),
        isThreeLine: true,
      ),
    );
  }
}

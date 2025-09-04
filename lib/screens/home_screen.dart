import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ✅ Made static const (since HomeScreen is StatelessWidget)
  static const List<Map<String, dynamic>> features = [
    {"title": "Diet Tracker", "icon": Icons.restaurant_menu, "route": "/diet"},
    {"title": "Water Tracker", "icon": Icons.water_drop, "route": "/water"},
    {"title": "BMI Calculator", "icon": Icons.monitor_weight, "route": "/bmi"},
    {"title": "Chatbot", "icon": Icons.chat_bubble_outline, "route": "/chatbot"},
    {"title": "Reports", "icon": Icons.bar_chart, "route": "/reports"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CALAI Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: features.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // ✅ 2 columns
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0, // ✅ Square cards
        ),
        itemBuilder: (context, index) {
          final feature = features[index];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, feature["route"]),
            child: Card(
              elevation: 6,
              shadowColor: Colors.teal.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(feature["icon"], size: 52, color: Colors.teal),
                    const SizedBox(height: 14),
                    Text(
                      feature["title"],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // --- MOCK DATA ---
  // In a real app, you would get this from your state management/database
  final String userName = "Joel"; // Let's assume you fetch the user's name
  final int caloriesConsumed = 1250;
  final int calorieGoal = 2000;
  final int waterConsumed = 1500; // in ml
  final int waterGoal = 2500; // in ml
  // --- END MOCK DATA ---

  @override
  Widget build(BuildContext context) {
    // Calculate progress for the UI
    double calorieProgress = (caloriesConsumed / calorieGoal).clamp(0.0, 1.0);
    double waterProgress = (waterConsumed / waterGoal).clamp(0.0, 1.0);

    return Scaffold(
      // A transparent app bar allows the body to scroll underneath for a modern feel
      appBar: AppBar(
        title: const Text("Your Dashboard"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Colors.grey[50], // A slightly off-white background
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          _buildGreeting(userName),
          const SizedBox(height: 24),
          _buildStatusDashboard(context, calorieProgress, waterProgress),
          const SizedBox(height: 24),
          _buildSectionHeader(context, "Quick Actions"),
          const SizedBox(height: 16),
          _buildFeatureGrid(context),
          const SizedBox(height: 24),
          _buildDailyTip(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Builds the personalized greeting section.
  Widget _buildGreeting(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hello, $name",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Text(
          "Ready to crush your goals today?",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  /// Builds the main status cards for calories and water.
  Widget _buildStatusDashboard(
    BuildContext context,
    double calProgress,
    double waterProgress,
  ) {
    return Row(
      children: [
        Expanded(
          child: _StatusCard(
            title: "Calories",
            consumed: caloriesConsumed,
            goal: calorieGoal,
            unit: "kcal",
            progress: calProgress,
            color: Colors.orange,
            icon: Icons.local_fire_department,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatusCard(
            title: "Water",
            consumed: waterConsumed,
            goal: waterGoal,
            unit: "ml",
            progress: waterProgress,
            color: Colors.blue,
            icon: Icons.water_drop,
          ),
        ),
      ],
    );
  }

  /// Builds a simple header for a section.
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
    );
  }

  /// Builds the grid of features like Diet Tracker, BMI, etc.
  Widget _buildFeatureGrid(BuildContext context) {
    const List<Map<String, dynamic>> features = [
      {
        "title": "Diet Tracker",
        "icon": Icons.restaurant_menu,
        "route": "/diet",
      },
      {"title": "Water Tracker", "icon": Icons.local_drink, "route": "/water"},
      {
        "title": "BMI Calculator",
        "icon": Icons.monitor_weight,
        "route": "/bmi",
      },
      {
        "title": "AI Chatbot",
        "icon": Icons.smart_toy_outlined,
        "route": "/chatbot",
      },
      {"title": "Reports", "icon": Icons.bar_chart, "route": "/reports"},
      {"title": "Logout", "icon": Icons.logout, "route": "/login"}, // Example
    ];

    return GridView.builder(
      // We use physics: NeverScrollableScrollPhysics() because the grid is inside a ListView.
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: features.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final feature = features[index];
        return _FeatureCard(
          title: feature["title"],
          icon: feature["icon"],
          onTap: () {
            // Special handling for logout or other non-push routes
            if (feature["route"] == "/login") {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            } else {
              Navigator.pushNamed(context, feature["route"]);
            }
          },
        );
      },
    );
  }

  /// Builds the "Daily Tip" card at the bottom.
  Widget _buildDailyTip(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: Colors.teal.shade800,
              size: 32,
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Daily Tip from CALAI",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Adding leafy greens to your lunch can boost your vitamin intake with minimal calories.",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HELPER WIDGETS FOR CLEANER CODE ---

/// A reusable card to display progress for a metric (Calories, Water).
class _StatusCard extends StatelessWidget {
  final String title;
  final int consumed;
  final int goal;
  final String unit;
  final double progress;
  final Color color;
  final IconData icon;

  const _StatusCard({
    required this.title,
    required this.consumed,
    required this.goal,
    required this.unit,
    required this.progress,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withAlpha(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withAlpha(30),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "$consumed",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: " / $goal $unit",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withAlpha(50),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      ),
    );
  }
}

/// A reusable card for the feature grid.
class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.teal),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

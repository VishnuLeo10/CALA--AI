import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ✅ FIX: Removed unused import 'dart:async'.
// import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final int calorieGoal = 2000;
  final int waterGoal = 2500;

  Map<String, Timestamp> _getTodayDateRange() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return {
      'start': Timestamp.fromDate(startOfToday),
      'end': Timestamp.fromDate(endOfToday),
    };
  }

  String _todayDocId() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in.")));
    }

    final dateRange = _getTodayDateRange();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Dashboard"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: Colors.grey[50],
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          _buildGreeting(user.uid),
          const SizedBox(height: 24),
          _buildStatusDashboard(user.uid, dateRange),
          const SizedBox(height: 24),
          _buildSectionHeader("Quick Actions"),
          const SizedBox(height: 16),
          _buildFeatureGrid(context),
          const SizedBox(height: 24),
          _buildDailyTip(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGreeting(String uid) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello...",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Loading your details...",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, User",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Ready to crush your goals today?",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final userName = userData['name'] ?? 'User';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, $userName",
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
      },
    );
  }

  Widget _buildStatusDashboard(String uid, Map<String, Timestamp> dateRange) {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .doc(uid)
                .collection('meals')
                .where('timestamp', isGreaterThanOrEqualTo: dateRange['start'])
                .where('timestamp', isLessThanOrEqualTo: dateRange['end'])
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // ✅ FIX: Renamed 'sum' to 'total' to avoid linting warning.
              int caloriesConsumed = snapshot.data!.docs.fold(
                0,
                (total, doc) =>
                    total +
                    ((doc.data() as Map<String, dynamic>)['calories'] as int? ??
                        0),
              );

              double calorieProgress = (caloriesConsumed / calorieGoal).clamp(
                0.0,
                1.0,
              );

              return _StatusCard(
                title: "Calories",
                consumed: caloriesConsumed,
                goal: calorieGoal,
                unit: "kcal",
                progress: calorieProgress,
                color: Colors.orange,
                icon: Icons.local_fire_department,
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
            stream: _firestore
                .collection('users')
                .doc(uid)
                .collection('water')
                .doc(_todayDocId())
                .snapshots(),
            builder: (context, snapshot) {
              int waterConsumed = 0;
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                waterConsumed = data['ml'] ?? 0;
              }

              double waterProgress = (waterConsumed / waterGoal).clamp(
                0.0,
                1.0,
              );

              return _StatusCard(
                title: "Water",
                consumed: waterConsumed,
                goal: waterGoal,
                unit: "ml",
                progress: waterProgress,
                color: Colors.blue,
                icon: Icons.water_drop,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
    );
  }

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
      {"title": "Logout", "icon": Icons.logout, "route": "/login"},
    ];

    return GridView.builder(
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
            if (feature["route"] == "/login") {
              FirebaseAuth.instance.signOut();
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

  Widget _buildDailyTip() {
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

// --- HELPER WIDGETS (Unchanged) ---
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

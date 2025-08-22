import 'package:flutter/material.dart';

// Import your screen files
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/diet_tracker.dart';
import 'screens/water_tracker.dart';
import 'screens/bmi_calculator.dart';
import 'screens/chatbot_screen.dart';

void main() {
  runApp(const CALAIApp());
}

class CALAIApp extends StatelessWidget {
  const CALAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CALAI - Diet App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/diet': (context) => const DietTrackerScreen(),
        '/water': (context) => const WaterTrackerScreen(),
        '/bmi': (context) => const BMICalculatorScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
      },
    );
  }
}

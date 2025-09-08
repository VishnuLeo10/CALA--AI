// lib/screens/bmi_calculator.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({super.key});

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  double _height = 160;
  double _weight = 60;
  double? _bmi;
  String _status = '';

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  void _calculateBMI() async {
    double heightInMeters = _height / 100;
    double bmi = _weight / pow(heightInMeters, 2);

    String status;
    if (bmi < 18.5) {
      status = 'Underweight';
    } else if (bmi < 24.9) {
      status = 'Normal';
    } else if (bmi < 29.9) {
      status = 'Overweight';
    } else {
      status = 'Obese';
    }

    setState(() {
      _bmi = bmi;
      _status = status;
    });

    // Save to Firestore for the current user
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('bmi_history').add({
        'bmi': bmi,
        'status': status,
        'height': _height,
        'weight': _weight,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Height (cm)',
              style: TextStyle(fontSize: 18),
            ),
            Slider(
              value: _height,
              min: 100,
              max: 220,
              divisions: 120,
              label: _height.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _height = value;
                });
              },
            ),
            Text('${_height.round()} cm', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const Text(
              'Weight (kg)',
              style: TextStyle(fontSize: 18),
            ),
            Slider(
              value: _weight,
              min: 30,
              max: 150,
              divisions: 120,
              label: _weight.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _weight = value;
                });
              },
            ),
            Text('${_weight.round()} kg', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _calculateBMI,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Calculate BMI',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
            if (_bmi != null)
              Column(
                children: [
                  Text(
                    'Your BMI is: ${_bmi!.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status: $_status',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}

// lib/screens/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for last 7 days (replace with backend later)
    final calories = [2000, 1800, 2200, 1900, 2100, 2300, 2000];
    final water = [1500, 1800, 2000, 1700, 1600, 1900, 1800];
    final bmi = [24.5, 24.6, 24.7, 24.6, 24.8, 24.7, 24.6];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Weekly Summary",
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),

            // 📊 Calories Chart
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                              return Text(days[value.toInt() % 7]);
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                      ),
                      barGroups: List.generate(
                        calories.length,
                        (i) => BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: calories[i].toDouble(),
                              color: Colors.teal,
                              width: 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 💧 Water Intake Line Chart
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                              return Text(days[value.toInt() % 7]);
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          spots: List.generate(
                            water.length,
                            (i) => FlSpot(i.toDouble(), water[i].toDouble()),
                          ),
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ⚖️ Latest BMI
            Text(
              "Latest BMI: ${bmi.last.toStringAsFixed(1)}",
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

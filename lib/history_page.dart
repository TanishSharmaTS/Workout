// history_page.dart
import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> workoutHistory = [
    {'date': '2024-11-01', 'workouts': 3, 'calories': 450},
    {'date': '2024-10-30', 'workouts': 2, 'calories': 320},
    // Add more mock data as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout History'),
      ),
      body: ListView.builder(
        itemCount: workoutHistory.length,
        itemBuilder: (context, index) {
          final workout = workoutHistory[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(workout['date']),
              subtitle: Text('Workouts: ${workout['workouts']}, Calories: ${workout['calories']} kcal'),
            ),
          );
        },
      ),
    );
  }
}

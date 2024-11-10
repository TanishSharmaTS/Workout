import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> workoutCompletions = [];

  @override
  void initState() {
    super.initState();
    _loadWorkoutCompletions();
  }

  Future<void> _loadWorkoutCompletions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> workoutCompletionStrings = prefs.getStringList('workoutCompletions') ?? [];
    setState(() {
      workoutCompletions = workoutCompletionStrings
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Workout History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: workoutCompletions.isEmpty
            ? Center(child: Text('No completed workouts yet'))
            : ListView.builder(
          itemCount: workoutCompletions.length,
          itemBuilder: (context, index) {
            return _buildWorkoutCard(workoutCompletions[index]);
          },
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> completion) {
    return Card(
      color: Colors.white, // Set card color to white
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _capitalizeWords(completion['workoutType']),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Completed on: ${_formatDate(DateTime.parse(completion['completionDate']))}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalizeWords(String text) {
    return text
        .split('_') // Split the string by underscores
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase() // Capitalize first letter of each word
        : '')
        .join(' '); // Join the words back with spaces
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
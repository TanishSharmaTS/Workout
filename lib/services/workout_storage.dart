import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> saveWorkoutDate(DateTime date) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> completedDates = prefs.getStringList('completedWorkouts') ?? [];

  // Prevent duplicate entries
  if (!completedDates.contains(date.toIso8601String())) {
    completedDates.add(date.toIso8601String());
    await prefs.setStringList('completedWorkouts', completedDates);
  }
}

Future<List<DateTime>> getCompletedWorkoutDates() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> dateStrings = prefs.getStringList('completedWorkouts') ?? [];

  // Convert stored date strings to DateTime objects
  return dateStrings.map((date) => DateTime.parse(date)).toList();
}

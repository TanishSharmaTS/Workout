import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'exercise_details.dart';
import '../data/exercise_data.dart';

class WorkoutDetailPage extends StatefulWidget {
  final String workoutType;

  WorkoutDetailPage({required this.workoutType});

  @override
  _WorkoutDetailPageState createState() => _WorkoutDetailPageState();
}

Color hexToColor(String hexCode) {
  return Color(int.parse('FF$hexCode', radix: 16));
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  List<Exercise> exercises = [];
  List<bool> exerciseCompleted = [];
  final ScrollController _scrollController = ScrollController();
  int totalWorkoutsCompleted = 0;
  int totalCaloriesBurned = 0;

  @override
  void initState() {
    super.initState();
    exercises = _getExercisesByWorkoutType(widget.workoutType);
    exerciseCompleted = List<bool>.filled(exercises.length, false);
    _loadTotalWorkoutsAndCalories(); // Load saved total values
    _checkIfWorkoutCompletedToday();
  }



  Future<void> _checkIfWorkoutCompletedToday() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime today = DateTime.now();

    for (int i = 0; i < exercises.length; i++) {
      String key = '${widget.workoutType}_exercise_${i}_${today.toIso8601String().substring(0, 10)}';
      bool isCompleted = prefs.getBool(key) ?? false;
      setState(() {
        exerciseCompleted[i] = isCompleted;
      });
    }
  }
  Future<void> _loadTotalWorkoutsAndCalories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      totalWorkoutsCompleted = prefs.getInt('totalWorkoutsCompleted') ?? 0;
      totalCaloriesBurned = prefs.getInt('totalCaloriesBurned') ?? 0;
    });
  }

  Future<void> _updateTotalWorkoutsAndCalories(int calories) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      totalWorkoutsCompleted += 1;
      totalCaloriesBurned += calories;
    });
    await prefs.setInt('totalWorkoutsCompleted', totalWorkoutsCompleted);
    await prefs.setInt('totalCaloriesBurned', totalCaloriesBurned);
  }

  @override
  Widget build(BuildContext context) {
    int completedCount = exerciseCompleted.where((completed) => completed).length;

    return Scaffold(
      backgroundColor:Colors.white,

      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color:Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Exercises (${completedCount}/${exercises.length} Completed)',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: hexToColor("393E46"),


      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      return _buildExerciseCard(context, exercises[index], index);
                    },
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hexToColor("393E46"),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (exercises.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExerciseDetailPage(
                            exercise: exercises[0],
                            index: 0,
                            totalExercises: exercises.length,
                            onComplete: _onExerciseComplete,
                            exercises: exercises,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    completedCount == 0 ? 'Start' : 'Continue ($completedCount/${exercises.length})',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise, int index) {
    return Card(
      color: exerciseCompleted[index] ? Colors.green.shade50 : Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(exercise.name),
        subtitle: Text('Reps/Time: ${exercise.repsOrTime}'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseDetailPage(
                exercise: exercise,
                index: index,
                totalExercises: exercises.length,
                onComplete: _onExerciseComplete,
                exercises: exercises,
              ),
            ),
          ).then((_) => _scrollToCurrentExercise(index));
        },
      ),
    );
  }

  void _onExerciseComplete(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime today = DateTime.now();

    setState(() {
      exerciseCompleted[index] = true;
    });

    String key = '${widget.workoutType}_exercise_${index}_${today.toIso8601String().substring(0, 10)}';
    await prefs.setBool(key, true);

    // Check if all exercises are completed
    if (exerciseCompleted.every((completed) => completed)) {
      int calories = _getCaloriesByWorkoutType(widget.workoutType);
      await _saveWorkoutCompletion(widget.workoutType);
      await _updateTotalWorkoutsAndCalories(calories);
      _checkAllCompleted();
    }
  }

  int _getCaloriesByWorkoutType(String workoutType) {
    switch (workoutType) {
      case 'upper_body_workout':
        return 200;
      case 'lower_body_workout':
        return 250;
      case 'full_body_workout':
        return 300;
      default:
        return 180;
    }
  }

  Future<void> _saveWorkoutCompletion(String workoutType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> workoutCompletions = prefs.getStringList('workoutCompletions') ?? [];

    workoutCompletions.add(jsonEncode({
      'workoutType': workoutType,
      'completionDate': DateTime.now().toIso8601String(),
    }));

    await prefs.setStringList('workoutCompletions', workoutCompletions);
  }

  void _checkAllCompleted() {
    if (exerciseCompleted.every((completed) => completed)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Workout Complete!"),
            content: Text("Great job! You've completed all exercises."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  void _scrollToCurrentExercise(int index) {
    _scrollController.animateTo(
      index * 100.0, // Adjust this value as needed for card height
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  List<Exercise> _getExercisesByWorkoutType(String workoutType) {
    switch (workoutType) {
      case 'upper_body_workout':
        return [
          Exercise(name: 'Push Up', repsOrTime: '3 sets of 12 reps'),
          Exercise(name: 'Bench Press', repsOrTime: '3 sets of 10 reps'),
          Exercise(name: 'Pull Up', repsOrTime: '2 sets of 8 reps'),
          Exercise(name: 'Shoulder Press', repsOrTime: '3 sets of 12 reps'),
        ];
      case 'lower_body_workout':
        return [
          Exercise(name: 'Squats', repsOrTime: '4 sets of 15 reps'),
          Exercise(name: 'Lunges', repsOrTime: '3 sets of 12 reps'),
          Exercise(name: 'Leg Press', repsOrTime: '3 sets of 10 reps'),
          Exercise(name: 'Deadlift', repsOrTime: '3 sets of 8 reps'),
        ];
      case 'full_body_workout':
        return [
          Exercise(name: 'Burpees', repsOrTime: '3 sets of 30 seconds'),
          Exercise(name: 'Mountain Climbers', repsOrTime: '3 sets of 30 seconds'),
          Exercise(name: 'Plank', repsOrTime: 'Hold for 60 seconds'),
          Exercise(name: 'Jumping Jacks', repsOrTime: '3 sets of 45 seconds'),
        ];
      default:
        return [];
    }
  }
}

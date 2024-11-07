import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'exercise_details.dart';
import 'exercise_data.dart';

class WorkoutDetailPage extends StatefulWidget {
  final String workoutType;

  WorkoutDetailPage({required this.workoutType});

  @override
  _WorkoutDetailPageState createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  List<Exercise> exercises = [];
  List<bool> exerciseCompleted = [];
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    exercises = _getExercisesByWorkoutType(widget.workoutType);
    exerciseCompleted = List<bool>.filled(exercises.length, false);
    _checkIfWorkoutCompletedToday();

  }


  Future<void> _checkIfWorkoutCompletedToday() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> workoutCompletions = prefs.getStringList('workoutCompletions') ?? [];
    DateTime today = DateTime.now();

    // Check if workout of this type was completed today
    bool isWorkoutCompletedToday = workoutCompletions.any((completionData) {
      Map<String, dynamic> completion = jsonDecode(completionData);
      String workoutType = completion['workoutType'];
      DateTime completionDate = DateTime.parse(completion['completionDate']);

      return workoutType == widget.workoutType &&
          completionDate.year == today.year &&
          completionDate.month == today.month &&
          completionDate.day == today.day;
    });

    // Update exercise completion state if workout is already completed today
    if (isWorkoutCompletedToday) {
      setState(() {
        exerciseCompleted.fillRange(0, exercises.length, true);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    int completedCount = exerciseCompleted.where((completed) => completed).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Exercises (${completedCount}/${exercises.length} Completed)'),
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
                    backgroundColor: Colors.blue,
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
        trailing: Icon(
          exerciseCompleted[index] ? Icons.check_circle : Icons.check_circle_outline,
          color: exerciseCompleted[index] ? Colors.green : null,
        ),
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
    setState(() {
      exerciseCompleted[index] = true;
    });

    if (exerciseCompleted.every((completed) => completed)) {
      await _saveWorkoutCompletion(widget.workoutType);
      _checkAllCompleted();
    }
  }

  Future<void> _saveWorkoutCompletion(String workoutType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> workoutCompletions = prefs.getStringList('workoutCompletions') ?? [];

    // Add the new completion as a JSON-encoded string
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
          Exercise(name: 'Burpees', repsOrTime: '3 sets of 30 seconds', img: 'assets/full_body/Burpee.jpg'),
          Exercise(name: 'Mountain Climbers', repsOrTime: '3 sets of 30 seconds', img: 'assets/full_body/mountainclimber.jpg'),
          Exercise(name: 'Plank', repsOrTime: 'Hold for 60 seconds', img: 'assets/full_body/plank.jpg'),
          Exercise(name: 'Jumping Jacks', repsOrTime: '3 sets of 45 seconds', img: 'assets/full_body/jumpingj.jpg'),
        ];
      default:
        return [];
    }
  }
}

import 'package:flutter/material.dart';

import 'exercise_details.dart';

class WorkoutDetailPage extends StatefulWidget {
  final String workoutType;

  WorkoutDetailPage({required this.workoutType});

  @override
  _WorkoutDetailPageState createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  List<Map<String, String>> exercises = [];
  List<bool> exerciseCompleted = []; // To track which exercises are done

  @override
  void initState() {
    super.initState();
    exercises = _getExercisesByWorkoutType(widget.workoutType);
    exerciseCompleted = List<bool>.filled(exercises.length, false); // Initialize completion status
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Exercises'),
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
                            exercise: exercises[0], // Start with the first exercise
                            index: 0,
                            totalExercises: exercises.length,
                            onComplete: _onExerciseComplete,
                            exercises: exercises, // Pass the list of exercises
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Start',
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

  Widget _buildExerciseCard(BuildContext context, Map<String, String> exercise, int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(exercise['name']!),
        subtitle: Text('Reps/Time: ${exercise['repsOrTime']}'),
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
                exercises: exercises, // Pass the list of exercises
              ),
            ),
          );
        },
      ),
    );
  }

  void _onExerciseComplete(int index) {
    setState(() {
      exerciseCompleted[index] = true;
    });
  }

  // Function to return exercise list based on workoutType
  List<Map<String, String>> _getExercisesByWorkoutType(String workoutType) {
    switch (workoutType) {
      case 'upper_body_workout':
        return [
          {'name': 'Push Up', 'repsOrTime': '3 sets of 12 reps'},
          {'name': 'Bench Press', 'repsOrTime': '3 sets of 10 reps'},
          {'name': 'Pull Up', 'repsOrTime': '2 sets of 8 reps'},
          {'name': 'Shoulder Press', 'repsOrTime': '3 sets of 12 reps'},
        ];
      case 'lower_body_workout':
        return [
          {'name': 'Squats', 'repsOrTime': '4 sets of 15 reps'},
          {'name': 'Lunges', 'repsOrTime': '3 sets of 12 reps'},
          {'name': 'Leg Press', 'repsOrTime': '3 sets of 10 reps'},
          {'name': 'Deadlift', 'repsOrTime': '3 sets of 8 reps'},
        ];
      case 'full_body_workout':
        return [
          {'name': 'Burpees', 'repsOrTime': '3 sets of 30 seconds'},
          {'name': 'Mountain Climbers', 'repsOrTime': '3 sets of 30 seconds'},
          {'name': 'Plank', 'repsOrTime': 'Hold for 1 minute'},
          {'name': 'Jumping Jacks', 'repsOrTime': '3 sets of 45 seconds'},
        ];
      default:
        return [];
    }
  }
}

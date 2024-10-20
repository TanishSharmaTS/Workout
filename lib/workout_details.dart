import 'package:flutter/material.dart';


class WorkoutDetailPage extends StatelessWidget {
  final String workoutType;

  WorkoutDetailPage({required this.workoutType});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> exercises = _getExercisesByWorkoutType(workoutType);

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
                // Workout title section
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      return _buildExerciseCard(exercises[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
          // "Start" button at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Add logic for starting the workout here
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

  Widget _buildExerciseCard(Map<String, String> exercise) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(exercise['name']!),
        subtitle: Text('Reps/Time: ${exercise['repsOrTime']}'),
        trailing: Icon(Icons.check_circle_outline), // Optional: Add logic for marking complete
      ),
    );
  }

  List<Map<String, String>> _getExercisesByWorkoutType(String workoutType) {
    // Replace this placeholder with actual data
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

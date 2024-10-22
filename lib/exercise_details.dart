import 'package:flutter/material.dart';

class ExerciseDetailPage extends StatelessWidget {
  final Map<String, String> exercise;
  final int index;
  final int totalExercises;
  final Function(int) onComplete;
  final List<Map<String, String>> exercises;

  ExerciseDetailPage({
    required this.exercise,
    required this.index,
    required this.totalExercises,
    required this.onComplete,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for the image - You can replace this with an actual image
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: Center(
                child: Text('Exercise Image Here'),
              ),
            ),
            SizedBox(height: 20),
            Text(
              exercise['name']!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              exercise['repsOrTime']!,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: index > 0
                      ? () {
                    // Navigate to the previous exercise without transition
                    Navigator.pushReplacement(
                      context,
                      _createNoTransitionRoute(
                        ExerciseDetailPage(
                          exercise: exercises[index - 1],
                          index: index - 1,
                          totalExercises: totalExercises,
                          onComplete: onComplete,
                          exercises: exercises,
                        ),
                      ),
                    );
                  }
                      : null, // Disable button if it's the first exercise
                  child: Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onComplete(index); // Mark the current exercise as done
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'DONE',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  onPressed: index < totalExercises - 1
                      ? () {
                    // Navigate to the next exercise without transition
                    Navigator.pushReplacement(
                      context,
                      _createNoTransitionRoute(
                        ExerciseDetailPage(
                          exercise: exercises[index + 1],
                          index: index + 1,
                          totalExercises: totalExercises,
                          onComplete: onComplete,
                          exercises: exercises,
                        ),
                      ),
                    );
                  }
                      : null, // Disable button if it's the last exercise
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Custom route with no transition effect
  Route _createNoTransitionRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero, // No transition duration
      reverseTransitionDuration: Duration.zero, // No reverse transition duration
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child; // Return the child without any animation
      },
    );
  }
}

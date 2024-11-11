import 'package:flutter/material.dart';
import 'dart:async';
import '../data/exercise_data.dart';

Color hexToColor(String hexCode) {
  return Color(int.parse('FF$hexCode', radix: 16));
}

class ExerciseDetailPage extends StatefulWidget {
  final Exercise exercise;
  final int index;
  final int totalExercises;
  final Function(int) onComplete;
  final List<Exercise> exercises;

  ExerciseDetailPage({
    required this.exercise,
    required this.index,
    required this.totalExercises,
    required this.onComplete,
    required this.exercises,
  });

  @override
  _ExerciseDetailPageState createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  Timer? _timer;
  int _remainingSeconds = 0;
  int _initialSeconds = 0;
  bool _isTimedExercise = false;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _isTimedExercise = _checkIfTimedExercise(widget.exercise.repsOrTime);
    if (_isTimedExercise) {
      _initializeTimer(widget.exercise.repsOrTime);
    }
  }

  void _initializeTimer(String repsOrTime) {
    final duration = _parseDuration(repsOrTime);
    if (duration != null) {
      setState(() {
        _remainingSeconds = duration.inSeconds;
        _initialSeconds = duration.inSeconds;
      });
    }
  }

  Duration? _parseDuration(String repsOrTime) {
    final regex = RegExp(r'(\d+)\s*(seconds?|minutes?)');
    final match = regex.firstMatch(repsOrTime.toLowerCase());
    if (match != null) {
      int value = int.parse(match.group(1)!);
      return match.group(2)!.contains('minute') ? Duration(minutes: value) : Duration(seconds: value);
    }
    return null;
  }

  bool _checkIfTimedExercise(String repsOrTime) {
    return repsOrTime.contains('seconds') || repsOrTime.contains('minutes');
  }

  void _startTimer() {
    if (_remainingSeconds > 0) {
      _isTimerRunning = true;
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _completeExercise();
          }
        });
      });
    }
  }

  void _pauseTimer() {
    _isTimerRunning = false;
    _timer?.cancel();
  }

  void _restartTimer() {
    _pauseTimer();
    setState(() {
      _remainingSeconds = _initialSeconds;
    });
  }

  void _completeExercise() {
    _pauseTimer();
    widget.onComplete(widget.index);
    _navigateToNextExercise();
  }

  Route _createNoTransitionRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }

  void _navigateToNextExercise() {
    if (widget.index < widget.totalExercises - 1) {
      Navigator.pushReplacement(
        context,
        _createNoTransitionRoute(
          ExerciseDetailPage(
            exercise: widget.exercises[widget.index + 1],
            index: widget.index + 1,
            totalExercises: widget.totalExercises,
            onComplete: widget.onComplete,
            exercises: widget.exercises,
          ),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _navigateToPreviousExercise() {
    if (widget.index > 0) {
      Navigator.pushReplacement(
        context,
        _createNoTransitionRoute(
          ExerciseDetailPage(
            exercise: widget.exercises[widget.index - 1],
            index: widget.index - 1,
            totalExercises: widget.totalExercises,
            onComplete: widget.onComplete,
            exercises: widget.exercises,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pauseTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = _initialSeconds > 0 ? _remainingSeconds / _initialSeconds : 1.0;

    return Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(
        backgroundColor:Colors.white,

      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 200,
                  color: Colors.grey.shade300,
                  child: Center(
                    child: widget.exercise.img != null // Check if img is not null
                        ? Image.asset(
                      widget.exercise.img!, // Use ! to assert that img is not null
                      fit: BoxFit.cover, // Adjust the image to fit the container
                    )
                        : Text('Exercise Image Here'), // Placeholder text
                  ),
                ),

                SizedBox(height: 20),
                Text(
                  widget.exercise.name,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  widget.exercise.repsOrTime,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                if (_isTimedExercise) ...[
                  SizedBox(height: 30),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          color: Colors.blueAccent,
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),
                      Text(
                        '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _isTimerRunning ? _pauseTimer : _startTimer,
                        child: Text(_isTimerRunning ? 'Pause' : 'Start'),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _restartTimer,
                        child: Text("Restart"),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _completeExercise,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: hexToColor("00ADB5"),

                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('DONE', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.index > 0 ? _navigateToPreviousExercise : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Previous', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.index < widget.totalExercises - 1
                              ? _navigateToNextExercise
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Skip', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}

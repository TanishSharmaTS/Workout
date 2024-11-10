class WorkoutCategory {
  final String categoryName;
  final String workoutType;
  final int numberOfExercises;
  final String estimatedTime;
  final String imagePath;
  final int calories;

  WorkoutCategory({
    required this.categoryName,
    required this.workoutType,
    required this.numberOfExercises,
    required this.estimatedTime,
    required this.imagePath,
    required this.calories
  });
}

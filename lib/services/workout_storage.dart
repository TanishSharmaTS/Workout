class WorkoutCompletion {
  final String workoutType;
  final DateTime completionDate;

  WorkoutCompletion({
    required this.workoutType,
    required this.completionDate,
  });

  // Method to retrieve completed dates for a particular workout type
  static List<DateTime> getCompletionDates(String workoutType, List<WorkoutCompletion> completions) {
    return completions
        .where((completion) => completion.workoutType == workoutType)
        .map((completion) => completion.completionDate)
        .toList();
  }
}

class LibraryTrainingStep {
  const LibraryTrainingStep({
    required this.name,
    required this.minutes,
    required this.detail,
  });

  final String name;
  final int minutes;
  final String detail;
}

class LibraryTrainingPlan {
  const LibraryTrainingPlan({
    required this.name,
    required this.level,
    required this.totalMinutes,
    required this.steps,
  });

  final String name;
  final String level;
  final int totalMinutes;
  final List<LibraryTrainingStep> steps;
}

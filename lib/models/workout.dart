import 'package:frontend/models/exercise.dart';

class Workout {
  Workout({required this.day, required this.exercises});

  DateTime dateCompleted = DateTime.now();
  final String day;
  final List<Exercise> exercises;

  factory Workout.fromJson(Map<String, dynamic> json) {
    final exerciseList = json['exercises'] as List;
    final List<Exercise> exercises =
        exerciseList.map((exercise) => Exercise.fromJson(exercise)).toList();

    Workout workout = Workout(day: json['day'], exercises: exercises);
    workout.dateCompleted = DateTime.parse(json['dateCompleted']);
    return workout;
  }

  Map<String, dynamic> toJson() {
    return {
      'dateCompleted': dateCompleted.toString(),
      'day': day,
      'exercises': exercises
          .map<Map<String, String>>((exercise) => exercise.toJson())
          .toList()
    };
  }
}

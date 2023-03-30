import 'package:frontend/models/exercise.dart';

class Workout {
  Workout({
    required this.id,
    required this.day,
    required this.exercises,
    required this.dateCompleted,
  });

  final String id;
  final DateTime? dateCompleted;
  final String day;
  final List<Exercise> exercises;

  factory Workout.fromJson(Map<String, dynamic> json) {
    final exerciseList = json['exercises'] as List;
    final List<Exercise> exercises = exerciseList
        .map(
          (exercise) => Exercise.fromJson(exercise),
        )
        .toList();

    final dateCompleted = json['dateCompleted'];

    return Workout(
      id: json['id'],
      day: json['day'],
      exercises: exercises,
      dateCompleted:
          dateCompleted != 'null' ? DateTime.parse(dateCompleted) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateCompleted': dateCompleted.toString(),
      'day': day,
      'exercises': exercises
          .map<Map<String, dynamic>>(
            (exercise) => exercise.toJson(),
          )
          .toList(),
    };
  }
}

import 'package:frontend/models/workout.dart';

class Week {
  const Week({required this.workouts});

  final List<Workout> workouts;

  factory Week.fromJson(Map<String, dynamic> json) {
    List workouts = json['workouts'];

    return Week(
      workouts: workouts
          .map(
            (workout) => Workout.fromJson(workout),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workouts': workouts
          .map(
            (workout) => workout.toJson(),
          )
          .toList(),
    };
  }
}

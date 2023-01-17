import 'dart:convert';
import 'dart:io';

import 'package:frontend/models/workout.dart';
import 'package:path_provider/path_provider.dart';

abstract class IWorkoutRepository {
  Future<void> saveWorkoutForExercisePlanById(
      Workout workout, String exercisePlanId);
  Future<List<Workout>> getWorkoutsForExercisePlanByDay(
      String day, String exercisePlanId);
}

class WorkoutRepository implements IWorkoutRepository {
  @override
  Future<void> saveWorkoutForExercisePlanById(
      Workout workout, String exercisePlanId) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();

    final Directory directory =
        Directory('${appDocDir.path}/${exercisePlanId}_info');

    final File file = File('${directory.path}/${workout.day}');

    if (file.existsSync()) {
      List<Workout> previousWorkouts =
          await getWorkoutsForExercisePlanByDay(workout.day, exercisePlanId);

      List<Workout> newWorkouts = [...previousWorkouts, workout];
      file.writeAsString(
          jsonEncode(newWorkouts.map((workout) => workout.toJson()).toList()));
    } else {
      await file.writeAsString(jsonEncode([workout.toJson()]));
    }
  }

  @override
  Future<List<Workout>> getWorkoutsForExercisePlanByDay(
      String day, String exercisePlanId) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();

    final Directory directory =
        Directory('${appDocDir.path}/${exercisePlanId}_info');

    final File file = File('${directory.path}/$day');

    if (file.existsSync()) {
      final String contents = await file.readAsString();
      List jsonWorkouts = jsonDecode(contents);
      List<Workout> workouts =
          jsonWorkouts.map((workout) => Workout.fromJson(workout)).toList();
      return workouts;
    }
    return [];
  }
}

final WorkoutRepository workoutRepository = WorkoutRepository();

import 'dart:convert';
import 'dart:io';

import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/models/week.dart';
import 'package:frontend/models/workout.dart';
import 'package:path_provider/path_provider.dart';

abstract class ISavedExercisePlanRepository {
  Future<void> saveCompletedExercisePlanToDevice(
      SavedExercisePlan exercisePlan);
  Future<void> removeCompletedExercisePlanFromDeviceById(String exercisePlanId);
  Future<List<SavedExercisePlan>> getCompletedExercisePlansFromDevice();
  Future<SavedExercisePlan> getCompletedExercisePlanFromDeviceById(
      String exercisePlanId);
}

class SavedExercisePlanRepository implements ISavedExercisePlanRepository {
  @override
  Future<void> saveCompletedExercisePlanToDevice(
      SavedExercisePlan exercisePlan) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();

    final Directory directory =
        await Directory('${appDocDir.path}/${exercisePlan.id}').create();

    final File file =
        File('${directory.path}/saved_exercise_plan_${exercisePlan.id}.txt');

    await file.writeAsString(
      jsonEncode(
        exercisePlan.toJson(),
      ),
      mode: FileMode.writeOnly,
    );
  }

  @override
  Future<List<SavedExercisePlan>> getCompletedExercisePlansFromDevice() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final completedExercisePlanFiles =
        appDocDir.listSync(recursive: true).whereType<File>().where(
              (file) =>
                  file.path.split('/').last.startsWith('saved_exercise_plan_'),
            );

    List<SavedExercisePlan> completedExercisePlans = await Future.wait(
      completedExercisePlanFiles.map(
        (file) async {
          final contents = await file.readAsString();

          return SavedExercisePlan.fromJson(
            jsonDecode(contents),
          );
        },
      ).toList(),
    );

    completedExercisePlans.sort(
      (plan1, plan2) {
        return -plan1.lastUsed.compareTo(plan2.lastUsed);
      },
    );
    return completedExercisePlans;
  }

  @override
  Future<SavedExercisePlan> getCompletedExercisePlanFromDeviceById(
      String exercisePlanId) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final File file = File(
        '${appDocDir.path}/$exercisePlanId/saved_exercise_plan_$exercisePlanId.txt');
    final contents = await file.readAsString();
    return SavedExercisePlan.fromJson(jsonDecode(contents));
  }

  @override
  Future<void> removeCompletedExercisePlanFromDeviceById(
      String exercisePlanId) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final File file = File('${appDocDir.path}/$exercisePlanId');
    await file.delete(recursive: true);
  }

  Future<void> addWeekToPlanById(String exercisePlanId) async {
    final plan = await getCompletedExercisePlanFromDeviceById(exercisePlanId);

    plan.weeks.add(
      const Week(
        workouts: [],
      ),
    );

    await saveCompletedExercisePlanToDevice(plan);
  }
}

final savedExercisePlanRepository = SavedExercisePlanRepository();

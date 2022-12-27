import 'dart:convert';
import 'dart:io';

import 'package:frontend/models/exercise.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:path_provider/path_provider.dart';

abstract class ICompletedExercisePlanRepository {
  Future<void> saveCompletedExercisePlansToDevice(
      CompletedExercisePlan exercisePlan);
  Future<void> removeCompletedExercisePlanFromDevice(
      CompletedExercisePlan exercisePlan);
  Future<List<CompletedExercisePlan>> getCompletedExercisePlansFromDevice();
}

class CompletedExercisePlanRepository
    implements ICompletedExercisePlanRepository {
  @override
  Future<void> saveCompletedExercisePlansToDevice(
      CompletedExercisePlan exercisePlan) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final File file = File(
        '${appDocDir.path}/completed_exercise_plan_${exercisePlan.id}.txt');

    file.writeAsString(jsonEncode(exercisePlan.toJson()));
  }

  @override
  Future<List<CompletedExercisePlan>>
      getCompletedExercisePlansFromDevice() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final completedExercisePlanFiles = appDocDir
        .listSync()
        .whereType<File>()
        .where((file) =>
            file.path.split('/').last.startsWith('completed_exercise_plan_'));

    List<CompletedExercisePlan> completedExercisePlans =
        await Future.wait(completedExercisePlanFiles.map((file) async {
      final contents = await file.readAsString();
      return CompletedExercisePlan.fromJson(jsonDecode(contents));
    }).toList());

    return completedExercisePlans;
  }

  @override
  Future<void> removeCompletedExercisePlanFromDevice(
      CompletedExercisePlan exercisePlan) async {
    // TODO: implement removeCompletedExercisePlanFromDevice
  }
}

final completedExercisePlanRepository = CompletedExercisePlanRepository();

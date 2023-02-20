import 'dart:convert';
import 'dart:io';

import 'package:frontend/models/exercise_plans.dart';
import 'package:path_provider/path_provider.dart';

abstract class ICompletedExercisePlanRepository {
  Future<void> saveCompletedExercisePlanToDevice(
      CompletedExercisePlan exercisePlan);
  Future<void> removeCompletedExercisePlanFromDevice(
      CompletedExercisePlan exercisePlan);
  Future<List<CompletedExercisePlan>> getCompletedExercisePlansFromDevice();
  Future<CompletedExercisePlan> getCompletedExercisePlanFromDeviceById(
      String exercisePlanId);
  Future<void> beginCompletedExercisePlanById(String exercisePlanId);
  Future<void> updateCompletedExercisePlanProgressById(
      String exercisePlanId, InProgressExercisePlan inProgressExercisePlan);
  Future<void> endCompletedExercisePlanById(String exercisePlanId);
}

class CompletedExercisePlanRepository
    implements ICompletedExercisePlanRepository {
  @override
  Future<void> saveCompletedExercisePlanToDevice(
      CompletedExercisePlan exercisePlan) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();

    final Directory directory =
        await Directory('${appDocDir.path}/${exercisePlan.id}_info').create();

    final File file = File(
        '${directory.path}/completed_exercise_plan_${exercisePlan.id}.txt');

    await file.writeAsString(jsonEncode(exercisePlan.toJson()));
  }

  @override
  Future<List<CompletedExercisePlan>>
      getCompletedExercisePlansFromDevice() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final completedExercisePlanFiles = appDocDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) =>
            file.path.split('/').last.startsWith('completed_exercise_plan_'));

    List<CompletedExercisePlan> completedExercisePlans =
        await Future.wait(completedExercisePlanFiles.map((file) async {
      final contents = await file.readAsString();
      return CompletedExercisePlan.fromJson(jsonDecode(contents));
    }).toList());

    completedExercisePlans.sort((plan1, plan2) {
      return -plan1.lastUsed.compareTo(plan2.lastUsed);
    });
    return completedExercisePlans;
  }

  @override
  Future<CompletedExercisePlan> getCompletedExercisePlanFromDeviceById(
      String exercisePlanId) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final File file = File(
        '${appDocDir.path}/${exercisePlanId}_info/completed_exercise_plan_$exercisePlanId.txt');
    final contents = await file.readAsString();
    return CompletedExercisePlan.fromJson(jsonDecode(contents));
  }

  @override
  Future<void> removeCompletedExercisePlanFromDevice(
      CompletedExercisePlan exercisePlan) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final File file = File('${appDocDir.path}/${exercisePlan.id}_info');
    await file.delete(recursive: true);
  }

  @override
  Future<void> beginCompletedExercisePlanById(String exercisePlanId) async {
    final completedExercisePlan =
        await getCompletedExercisePlanFromDeviceById(exercisePlanId);

    final CompletedExercisePlan newCompletedExercisePlan =
        CompletedExercisePlan(
      id: completedExercisePlan.id,
      planName: completedExercisePlan.planName,
      dayToExercisesMap: completedExercisePlan.dayToExercisesMap,
      isInProgress: true,
      lastUsed: DateTime.now(),
    );

    await saveCompletedExercisePlanToDevice(newCompletedExercisePlan);
  }

  @override
  Future<void> updateCompletedExercisePlanProgressById(String exercisePlanId,
      InProgressExercisePlan inProgressExercisePlan) async {
    final completedExercisePlan =
        await getCompletedExercisePlanFromDeviceById(exercisePlanId);

    final CompletedExercisePlan newCompletedExercisePlan =
        CompletedExercisePlan(
      id: completedExercisePlan.id,
      planName: completedExercisePlan.planName,
      dayToExercisesMap: inProgressExercisePlan.dayToExercisesMap,
      isInProgress: completedExercisePlan.isInProgress,
      lastUsed: DateTime.now(),
    );

    await saveCompletedExercisePlanToDevice(newCompletedExercisePlan);
  }

  @override
  Future<void> endCompletedExercisePlanById(String exercisePlanId) async {
    final completedExercisePlan =
        await getCompletedExercisePlanFromDeviceById(exercisePlanId);

    final CompletedExercisePlan newCompletedExercisePlan =
        CompletedExercisePlan(
      id: completedExercisePlan.id,
      planName: completedExercisePlan.planName,
      dayToExercisesMap: completedExercisePlan.dayToExercisesMap,
      isInProgress: false,
      lastUsed: DateTime.now(),
    );

    await saveCompletedExercisePlanToDevice(newCompletedExercisePlan);
  }
}

final completedExercisePlanRepository = CompletedExercisePlanRepository();

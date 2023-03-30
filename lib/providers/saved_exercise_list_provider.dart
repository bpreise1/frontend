import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/repository/saved_exercise_plan_repository.dart';

class SavedExercisePlansNotifier
    extends AsyncNotifier<List<SavedExercisePlan>> {
  @override
  FutureOr<List<SavedExercisePlan>> build() async {
    return savedExercisePlanRepository.getCompletedExercisePlansFromDevice();
  }

  Future<void> _updateCompletedPlans() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return savedExercisePlanRepository.getCompletedExercisePlansFromDevice();
    });
  }

  Future<void> saveCompletedExercisePlanToDevice(
      SavedExercisePlan exercisePlan) async {
    await savedExercisePlanRepository
        .saveCompletedExercisePlanToDevice(exercisePlan);

    _updateCompletedPlans();
  }

  Future<void> removeCompletedExercisePlanFromDevice(
      String exercisePlanId) async {
    await savedExercisePlanRepository
        .removeCompletedExercisePlanFromDeviceById(exercisePlanId);

    _updateCompletedPlans();
  }
}

final savedExerciseListProvider =
    AsyncNotifierProvider<SavedExercisePlansNotifier, List<SavedExercisePlan>>(
        SavedExercisePlansNotifier.new);

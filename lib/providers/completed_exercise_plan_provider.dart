import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/repository/completed_exercise_plan_repository.dart';

class CompletedExercisePlansNotifierState {
  const CompletedExercisePlansNotifierState({required this.exercisePlans});

  final List<CompletedExercisePlan> exercisePlans;

  List<CompletedExercisePlan> get completedExercisePlans => exercisePlans;

  CompletedExercisePlan getCompletedExercisePlanById(String id) {
    return completedExercisePlans.firstWhere((plan) => plan.id == id);
  }
}

class CompletedExercisePlansNotifier
    extends AsyncNotifier<CompletedExercisePlansNotifierState> {
  @override
  FutureOr<CompletedExercisePlansNotifierState> build() async {
    final exercisePlans = await completedExercisePlanRepository
        .getCompletedExercisePlansFromDevice();
    return CompletedExercisePlansNotifierState(exercisePlans: exercisePlans);
  }

  Future<void> _updateCompletedPlans() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final exercisePlans = await completedExercisePlanRepository
          .getCompletedExercisePlansFromDevice();
      return CompletedExercisePlansNotifierState(exercisePlans: exercisePlans);
    });
  }

  Future<void> saveCompletedExercisePlanToDevice(
      CompletedExercisePlan exercisePlan) async {
    await completedExercisePlanRepository
        .saveCompletedExercisePlanToDevice(exercisePlan);

    _updateCompletedPlans();
  }

  Future<void> removeCompletedExercisePlanFromDevice(
      CompletedExercisePlan exercisePlan) async {
    await completedExercisePlanRepository
        .removeCompletedExercisePlanFromDevice(exercisePlan);

    _updateCompletedPlans();
  }

  Future<void> beginCompletedExercisePlanById(String exercisePlanId) async {
    await completedExercisePlanRepository
        .beginCompletedExercisePlanById(exercisePlanId);

    _updateCompletedPlans();
  }

  Future<void> updateCompletedExercisePlanProgressById(String exercisePlanId,
      InProgressExercisePlan inProgressExercisePlan) async {
    await completedExercisePlanRepository
        .updateCompletedExercisePlanProgressById(
            exercisePlanId, inProgressExercisePlan);

    _updateCompletedPlans();
  }

  Future<void> endCompletedExercisePlanById(String exercisePlanId) async {
    await completedExercisePlanRepository
        .endCompletedExercisePlanById(exercisePlanId);

    _updateCompletedPlans();
  }
}

final completedExercisePlansProvider = AsyncNotifierProvider<
    CompletedExercisePlansNotifier,
    CompletedExercisePlansNotifierState>(CompletedExercisePlansNotifier.new);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/date_time_exercise.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/models/workout.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
import 'package:frontend/repository/workout_repository.dart';
import 'package:frontend/widgets/day_select_dropdown.dart';
import 'package:frontend/widgets/exercise_line_graph.dart';

class PlanMetricsPage extends StatelessWidget {
  const PlanMetricsPage({required this.exercisePlan, super.key});

  final CompletedExercisePlan exercisePlan;

  Map<String, List<DateTimeExercise>> _splitWorkoutListIntoDateTimeExercises(
      List<Workout> workoutList) {
    Map<String, List<DateTimeExercise>> splitExercises = {};

    for (final workout in workoutList) {
      for (final exercise in workout.exercises) {
        splitExercises[exercise.name] = [
          ...?splitExercises[exercise.name],
          DateTimeExercise(dateTime: workout.dateCompleted, exercise: exercise)
        ];
      }
    }

    return splitExercises;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(exercisePlan.planName)),
      body: Column(children: [
        DaySelectDropdown(provider: savedExercisePlanProvider),
        Consumer(builder: ((context, ref, child) {
          final String currentDay =
              ref.watch(savedExercisePlanProvider).currentDay;

          return FutureBuilder(
              future: workoutRepository.getWorkoutsForExercisePlanByDay(
                  currentDay, exercisePlan.id),
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (!snapshot.hasError) {
                    return Column(
                        children: _splitWorkoutListIntoDateTimeExercises(
                                snapshot.data!)
                            .entries
                            .map((entry) =>
                                ExerciseLineGraph(exercises: entry.value))
                            .toList());
                  }
                  return Center(child: Text(snapshot.error.toString()));
                }
                return Container();
              }));
        })),
      ]),
    );
  }
}

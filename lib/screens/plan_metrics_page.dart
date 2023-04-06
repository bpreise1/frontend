import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/date_time_exercise.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/models/workout.dart';
import 'package:frontend/providers/exercise_plan_provider.dart';
import 'package:frontend/repository/workout_repository.dart';
import 'package:frontend/widgets/day_select_dropdown.dart';
import 'package:frontend/widgets/exercise_line_graph.dart';
import 'package:frontend/widgets/exercise_list_item.dart';

class PlanMetricsPage extends StatelessWidget {
  const PlanMetricsPage({required this.exercisePlan, super.key});

  final SavedExercisePlan exercisePlan;

  List<List<DateTimeExercise>> _splitWorkoutListIntoDateTimeExercises(
      List<Workout> workoutList) {
    List<List<DateTimeExercise>> splitExercises =
        List.filled(workoutList[0].exercises.length, []);

    for (final workout in workoutList) {
      for (int i = 0; i < workout.exercises.length; i++) {
        splitExercises[i] = [
          ...splitExercises[i],
          if (workout.dateCompleted != null)
            DateTimeExercise(
                dateTime: workout.dateCompleted!,
                exercise: workout.exercises[i]),
        ];
      }
    }

    return splitExercises;
  }

  List<Workout> _getWorkoutsForExercisePlanByDay(String day) {
    List<Workout> workouts = [];

    for (final week in exercisePlan.weeks) {
      for (final workout in week.workouts) {
        if (workout.dateCompleted != null && workout.day == day) {
          workouts.add(workout);
        }
      }
    }

    return workouts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(exercisePlan.planName)),
      body: Column(
        children: [
          DaySelectDropdown(provider: savedExercisePlanProvider),
          Consumer(
            builder: ((context, ref, child) {
              final String currentDay =
                  ref.watch(savedExercisePlanProvider).currentDay;
              final workouts = _getWorkoutsForExercisePlanByDay(currentDay);

              return workouts.isEmpty
                  ? const Flexible(
                      child: Center(
                        child: Text(
                          'Complete a workout to begin tracking metrics',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView(
                        children:
                            _splitWorkoutListIntoDateTimeExercises(workouts)
                                .map(
                                  (exercises) => ExpansionTile(
                                    initiallyExpanded: true,
                                    title: ExerciseListItem(
                                        exercise: exercises.first.exercise),
                                    children: [
                                      ExerciseLineGraph(exercises: exercises)
                                    ],
                                  ),
                                )
                                .toList(),
                      ),
                    );
            }),
          ),
        ],
      ),
    );
  }
}

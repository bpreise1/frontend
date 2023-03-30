import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/models/week.dart';
import 'package:frontend/models/workout.dart';
import 'package:frontend/providers/saved_exercise_list_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'saved_exercise_plan_provider.g.dart';

@riverpod
class SavedExercisePlanNotifier extends _$SavedExercisePlanNotifier {
  @override
  SavedExercisePlan build(String exercisePlanId) {
    return ref
        .read(savedExerciseListProvider)
        .value!
        .firstWhere((plan) => plan.id == exercisePlanId);
  }

  Future<void> addWeek() async {
    final newPlan = SavedExercisePlan(
      id: state.id,
      planName: state.planName,
      dayToExercisesMap: state.dayToExercisesMap,
      weeks: [
        ...state.weeks,
        const Week(
          workouts: [],
        ),
      ],
      lastUsed: DateTime.now(),
    );

    await ref
        .read(
          savedExerciseListProvider.notifier,
        )
        .saveCompletedExercisePlanToDevice(newPlan);

    state = newPlan;
  }

  Future<void> addWorkout(Workout workout, int weekIndex) async {
    List<Week> newWeeks = [];
    for (int i = 0; i < state.weeks.length; i++) {
      if (i == weekIndex) {
        newWeeks.add(
          Week(
            workouts: [...state.weeks[i].workouts, workout],
          ),
        );
      } else {
        newWeeks.add(
          state.weeks[i],
        );
      }
    }

    final newPlan = SavedExercisePlan(
      id: state.id,
      planName: state.planName,
      dayToExercisesMap: state.dayToExercisesMap,
      weeks: newWeeks,
      lastUsed: DateTime.now(),
    );

    await ref
        .read(
          savedExerciseListProvider.notifier,
        )
        .saveCompletedExercisePlanToDevice(newPlan);

    state = newPlan;
  }

  Future<void> completeWorkout(String workoutId, int weekIndex) async {
    List<Week> newWeeks = [];
    for (int i = 0; i < state.weeks.length; i++) {
      if (i == weekIndex) {
        List<Workout> newWorkouts = [];

        for (final workout in state.weeks[i].workouts) {
          if (workout.id == workoutId) {
            newWorkouts.add(
              Workout(
                id: workout.id,
                day: workout.day,
                exercises: workout.exercises,
                dateCompleted: DateTime.now(),
              ),
            );
          } else {
            newWorkouts.add(workout);
          }
        }

        newWeeks.add(
          Week(workouts: newWorkouts),
        );
      } else {
        newWeeks.add(
          state.weeks[i],
        );
      }
    }

    final newPlan = SavedExercisePlan(
      id: state.id,
      planName: state.planName,
      dayToExercisesMap: state.dayToExercisesMap,
      weeks: newWeeks,
      lastUsed: DateTime.now(),
    );

    await ref
        .read(
          savedExerciseListProvider.notifier,
        )
        .saveCompletedExercisePlanToDevice(newPlan);

    state = newPlan;
  }

  Future<void> updateWorkout(int weekIndex, Workout workout) async {
    List<Week> newWeeks = [];

    for (int i = 0; i < state.weeks.length; i++) {
      if (i == weekIndex) {
        List<Workout> newWorkouts = [];

        for (final oldWorkout in state.weeks[i].workouts) {
          if (oldWorkout.id == workout.id) {
            newWorkouts.add(workout);
          } else {
            newWorkouts.add(oldWorkout);
          }
        }

        newWeeks.add(
          Week(workouts: newWorkouts),
        );
      } else {
        newWeeks.add(
          state.weeks[i],
        );
      }
    }

    final newPlan = SavedExercisePlan(
      id: state.id,
      planName: state.planName,
      dayToExercisesMap: state.dayToExercisesMap,
      weeks: newWeeks,
      lastUsed: DateTime.now(),
    );

    await ref
        .read(
          savedExerciseListProvider.notifier,
        )
        .saveCompletedExercisePlanToDevice(newPlan);

    state = newPlan;
  }
}

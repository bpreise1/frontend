import 'package:frontend/models/exercise.dart';
import 'package:frontend/models/workout.dart';
import 'package:frontend/providers/saved_exercise_plan_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'workout_provider.g.dart';

@riverpod
class WorkoutNotifier extends _$WorkoutNotifier {
  @override
  Workout build(String exercisePlanId, String workoutId, int weekIndex) {
    final plan = ref.watch(
      savedExercisePlanNotifierProvider(exercisePlanId),
    );

    return plan.weeks[weekIndex].workouts
        .firstWhere((workout) => workout.id == workoutId);
  }

  Future<void> updateReps(int exerciseIndex, int setIndex, String reps) async {
    final List<Exercise> newExercises = [];

    for (int e = 0; e < state.exercises.length; e++) {
      if (e == exerciseIndex) {
        final List<String> newReps = [];

        for (int s = 0; s < int.parse(state.exercises[e].sets); s++) {
          if (s == setIndex) {
            newReps.add(reps);
          } else {
            newReps.add(
              state.exercises[e].reps[s],
            );
          }
        }

        newExercises.add(
          Exercise(
            name: state.exercises[e].name,
            description: state.exercises[e].description,
            sets: state.exercises[e].sets,
            goalReps: state.exercises[e].goalReps,
            reps: newReps,
            weights: state.exercises[e].weights,
          ),
        );
      } else {
        newExercises.add(
          state.exercises[e],
        );
      }
    }

    final newWorkout = Workout(
        id: state.id,
        day: state.day,
        exercises: newExercises,
        dateCompleted: state.dateCompleted);

    await ref
        .read(
          savedExercisePlanNotifierProvider(exercisePlanId).notifier,
        )
        .updateWorkout(weekIndex, newWorkout);

    state = newWorkout;
  }

  Future<void> updateWeight(
      int exerciseIndex, int setIndex, String weight) async {
    final List<Exercise> newExercises = [];

    for (int e = 0; e < state.exercises.length; e++) {
      if (e == exerciseIndex) {
        final List<String> newWeights = [];

        for (int s = 0; s < int.parse(state.exercises[e].sets); s++) {
          if (s == setIndex) {
            newWeights.add(weight);
          } else {
            newWeights.add(
              state.exercises[e].weights[s],
            );
          }
        }

        newExercises.add(
          Exercise(
            name: state.exercises[e].name,
            description: state.exercises[e].description,
            sets: state.exercises[e].sets,
            goalReps: state.exercises[e].goalReps,
            reps: state.exercises[e].reps,
            weights: newWeights,
          ),
        );
      } else {
        newExercises.add(
          state.exercises[e],
        );
      }
    }

    final newWorkout = Workout(
        id: state.id,
        day: state.day,
        exercises: newExercises,
        dateCompleted: state.dateCompleted);

    await ref
        .read(
          savedExercisePlanNotifierProvider(exercisePlanId).notifier,
        )
        .updateWorkout(weekIndex, newWorkout);

    state = newWorkout;
  }
}

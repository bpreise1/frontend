import 'package:frontend/models/user_exception.dart';
import 'package:frontend/models/workout.dart';

UserException? validateWorkout(Workout workout) {
  for (final exercise in workout.exercises) {
    for (int i = 0; i < int.parse(exercise.sets); i++) {
      if (exercise.reps[i] == '' && exercise.weights[i] != '') {
        return UserException(
            message:
                'Set ${i + 1} of "${exercise.name} has empty reps but non-empty weight');
      } else if (exercise.reps[i] != '' && exercise.weights[i] == '') {
        return UserException(
            message:
                'Set ${i + 1} of "${exercise.name} has empty weight but non-empty reps');
      }
    }
  }

  return null;
}

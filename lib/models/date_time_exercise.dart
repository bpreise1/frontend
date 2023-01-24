import 'package:frontend/models/exercise.dart';

class DateTimeExercise {
  const DateTimeExercise({required this.dateTime, required this.exercise});

  final DateTime dateTime;
  final Exercise exercise;

  String get sets => exercise.sets;
  List<String> get reps => exercise.reps;
  List<String> get weights => exercise.weights;
  String get name => exercise.name;

  double getVolume() {
    double volume = 0;
    for (int i = 0; i < int.parse(sets); i++) {
      if (reps[i] == '' || weights[i] == '') {
        continue;
      }
      volume += double.parse(reps[i]) * double.parse(weights[i]);
    }
    return volume;
  }
}

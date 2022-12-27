import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise.dart';
import 'package:frontend/models/exercise_plans.dart';

class ExercisePlanState {
  const ExercisePlanState({
    required exercisePlan,
    this.currentDay = 'Day 1',
  }) : _exercisePlan = exercisePlan;

  final InProgressExercisePlan _exercisePlan;
  final String currentDay;

  InProgressExercisePlan get exercisePlan => _exercisePlan;
  Map<String, List<Exercise>> get dayToExercisesMap =>
      exercisePlan.dayToExercisesMap;
  String get planName => exercisePlan.planName;
  List<String> get days => exercisePlan.dayToExercisesMap.keys.toList();
  List<Exercise>? get exercises => exercisePlan.dayToExercisesMap[currentDay];
}

class ExercisePlanNotifier extends StateNotifier<ExercisePlanState> {
  ExercisePlanNotifier()
      : super(const ExercisePlanState(exercisePlan: InProgressExercisePlan()));

  void changePlanName(String name) {
    state = ExercisePlanState(
        exercisePlan: InProgressExercisePlan(
            planName: name, dayToExercisesMap: state.dayToExercisesMap),
        currentDay: state.currentDay);
  }

  void resetPlan() {
    state = const ExercisePlanState(exercisePlan: InProgressExercisePlan());
  }

  void addExercise(Exercise exercise) {
    final Map<String, List<Exercise>> newDayToExercisesMap = {};
    state.dayToExercisesMap.forEach((key, value) {
      if (key == state.currentDay) {
        List<Exercise> newExerciseList = List.from(value);
        newExerciseList.add(exercise);
        newDayToExercisesMap[key] = newExerciseList;
      } else {
        newDayToExercisesMap[key] = value;
      }
    });

    state = ExercisePlanState(
      exercisePlan: InProgressExercisePlan(
          planName: state.planName, dayToExercisesMap: newDayToExercisesMap),
      currentDay: state.currentDay,
    );
  }

  void removeExerciseAt(int index) {
    final Map<String, List<Exercise>> newDayToExercisesMap = {};
    state.dayToExercisesMap.forEach((key, value) {
      if (key == state.currentDay) {
        List<Exercise> newExerciseList = List.from(value);
        newExerciseList.removeAt(index);
        newDayToExercisesMap[key] = newExerciseList;
      } else {
        newDayToExercisesMap[key] = value;
      }
    });

    state = ExercisePlanState(
      exercisePlan: InProgressExercisePlan(
          planName: state.planName, dayToExercisesMap: newDayToExercisesMap),
      currentDay: state.currentDay,
    );
  }

  void moveExercise(int oldIndex, int newIndex) {
    final Map<String, List<Exercise>> newDayToExercisesMap = {};

    List<Exercise> newExerciseList = List.from(state.exercises!);
    if (newIndex >= oldIndex) newIndex--;
    newExerciseList.insert(newIndex, newExerciseList.removeAt(oldIndex));

    state.dayToExercisesMap.forEach((key, value) {
      if (key == state.currentDay) {
        newDayToExercisesMap[key] = newExerciseList;
      } else {
        newDayToExercisesMap[key] = value;
      }
    });

    state = ExercisePlanState(
        exercisePlan: InProgressExercisePlan(
            planName: state.planName, dayToExercisesMap: newDayToExercisesMap),
        currentDay: state.currentDay);
  }

  void addDay() {
    int numDayToAdd = state.days.length + 1;
    while (state.dayToExercisesMap.containsKey('Day $numDayToAdd')) {
      numDayToAdd++;
    }

    String day = 'Day $numDayToAdd';

    final newDayToExercisesMap =
        Map<String, List<Exercise>>.from(state.dayToExercisesMap);
    newDayToExercisesMap[day] = [];

    state = ExercisePlanState(
        exercisePlan: InProgressExercisePlan(
            planName: state.planName, dayToExercisesMap: newDayToExercisesMap),
        currentDay: day);
  }

  void updateDayName(String name) {
    assert(name != '', 'Day must not be empty');

    assert(
        state.currentDay == name || !state.dayToExercisesMap.containsKey(name),
        'Name "$name" can only be used once');

    final Map<String, List<Exercise>> newDayToExercisesMap = {};
    state.dayToExercisesMap.forEach((key, value) {
      if (key == state.currentDay) {
        List<Exercise> newExerciseList = value;
        newDayToExercisesMap[name] = newExerciseList;
      } else {
        newDayToExercisesMap[key] = value;
      }
    });

    state = ExercisePlanState(
        exercisePlan: InProgressExercisePlan(
            planName: state.planName, dayToExercisesMap: newDayToExercisesMap),
        currentDay: name);
  }

  void selectDay(String day) {
    state =
        ExercisePlanState(exercisePlan: state.exercisePlan, currentDay: day);
  }

  void removeDay(String day) {
    final newDayToExercisesMap =
        Map<String, List<Exercise>>.from(state.dayToExercisesMap);
    int indexToRemove = newDayToExercisesMap.keys.toList().indexOf(day);
    newDayToExercisesMap.remove(day);

    String newDay;
    if (indexToRemove == 0) {
      newDay = newDayToExercisesMap.keys.first;
    } else {
      newDay = newDayToExercisesMap.keys.toList()[indexToRemove - 1];
    }

    state = ExercisePlanState(
        exercisePlan: InProgressExercisePlan(
            planName: state.planName, dayToExercisesMap: newDayToExercisesMap),
        currentDay: newDay);
  }

  void updateSets(String day, int index, String sets) {
    final newDayToExercisesMap =
        Map<String, List<Exercise>>.from(state.dayToExercisesMap);

    Exercise exerciseToReplace = newDayToExercisesMap[day]![index];
    newDayToExercisesMap[day]![index] = Exercise(
        name: exerciseToReplace.name,
        description: exerciseToReplace.description,
        sets: sets,
        reps: exerciseToReplace.reps);

    state = ExercisePlanState(
        exercisePlan: InProgressExercisePlan(
            planName: state.planName, dayToExercisesMap: newDayToExercisesMap),
        currentDay: state.currentDay);
  }

  void updateReps(String day, int index, String reps) {
    final newDayToExercisesMap =
        Map<String, List<Exercise>>.from(state.dayToExercisesMap);

    Exercise exerciseToReplace = newDayToExercisesMap[day]![index];
    newDayToExercisesMap[day]![index] = Exercise(
        name: exerciseToReplace.name,
        description: exerciseToReplace.description,
        sets: exerciseToReplace.sets,
        reps: reps);

    state = ExercisePlanState(
      exercisePlan: InProgressExercisePlan(
          planName: state.planName, dayToExercisesMap: newDayToExercisesMap),
      currentDay: state.currentDay,
    );
  }
}

final exercisePlanProvider =
    StateNotifierProvider<ExercisePlanNotifier, ExercisePlanState>(
        ((ref) => ExercisePlanNotifier()));

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Exercise {
  const Exercise({
    required this.name,
    required this.description,
    required this.image,
    this.sets = '',
    this.reps = '',
  });

  final String name;
  final String description;
  final ImageProvider image;
  final String sets;
  final String reps;
}

class ExercisePlanState {
  const ExercisePlanState(
      {this.planName = 'My Plan',
      this.currentDay = 'Day 1',
      this.dayToExercisesMap = const {'Day 1': []}});

  final String planName;
  final String currentDay;
  final Map<String, List<Exercise>> dayToExercisesMap;

  List<String> get days => dayToExercisesMap.keys.toList();
  List<Exercise>? get exercises => dayToExercisesMap[currentDay];
}

class ExercisePlanNotifier extends StateNotifier<ExercisePlanState> {
  ExercisePlanNotifier() : super(const ExercisePlanState());

  void changePlanName(String name) {
    state = ExercisePlanState(
        planName: name,
        currentDay: state.currentDay,
        dayToExercisesMap: state.dayToExercisesMap);
  }

  void resetPlan() {
    state = const ExercisePlanState();
  }

  void addExercise(Exercise exercise) {
    if (state.currentDay == '') {
      throw Exception('Add a day before adding exercises');
    }

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
        planName: state.planName,
        currentDay: state.currentDay,
        dayToExercisesMap: newDayToExercisesMap);
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
        planName: state.planName,
        currentDay: state.currentDay,
        dayToExercisesMap: newDayToExercisesMap);
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
        planName: state.planName,
        currentDay: state.currentDay,
        dayToExercisesMap: newDayToExercisesMap);
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
        planName: state.planName,
        currentDay: day,
        dayToExercisesMap: newDayToExercisesMap);
  }

  void updateDayName(String name) {
    if (name == '') {
      throw Exception('Day must not be empty');
    }

    if (state.currentDay != name && state.dayToExercisesMap.containsKey(name)) {
      throw Exception('Name "$name" can only be used once');
    }

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
        planName: state.planName,
        currentDay: name,
        dayToExercisesMap: newDayToExercisesMap);
  }

  void selectDay(String day) {
    state = ExercisePlanState(
        planName: state.planName,
        currentDay: day,
        dayToExercisesMap: state.dayToExercisesMap);
  }

  void removeDay(String day) {
    if (state.dayToExercisesMap.length == 1) {
      throw Exception('There must be at least one day in a plan');
    }

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
        planName: state.planName,
        currentDay: newDay,
        dayToExercisesMap: newDayToExercisesMap);
  }

  void updateSets(String day, int index, String sets) {
    final newDayToExercisesMap =
        Map<String, List<Exercise>>.from(state.dayToExercisesMap);

    Exercise exerciseToReplace = newDayToExercisesMap[day]![index];
    newDayToExercisesMap[day]![index] = Exercise(
        name: exerciseToReplace.name,
        description: exerciseToReplace.description,
        image: exerciseToReplace.image,
        sets: sets,
        reps: exerciseToReplace.reps);

    state = ExercisePlanState(
        planName: state.planName,
        currentDay: state.currentDay,
        dayToExercisesMap: newDayToExercisesMap);
  }

  void updateReps(String day, int index, String reps) {
    final newDayToExercisesMap =
        Map<String, List<Exercise>>.from(state.dayToExercisesMap);

    Exercise exerciseToReplace = newDayToExercisesMap[day]![index];
    newDayToExercisesMap[day]![index] = Exercise(
        name: exerciseToReplace.name,
        description: exerciseToReplace.description,
        image: exerciseToReplace.image,
        sets: exerciseToReplace.sets,
        reps: reps);

    state = ExercisePlanState(
        planName: state.planName,
        currentDay: state.currentDay,
        dayToExercisesMap: newDayToExercisesMap);
  }
}

final exercisePlanProvider =
    StateNotifierProvider<ExercisePlanNotifier, ExercisePlanState>(
        ((ref) => ExercisePlanNotifier()));

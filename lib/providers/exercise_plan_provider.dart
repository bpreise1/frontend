import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Exercise {
  const Exercise(
      {required this.name,
      required this.description,
      this.image,
      this.sets,
      this.reps,
      this.rest});

  final String name;
  final String description;
  final ImageProvider? image;
  final int? sets;
  final int? reps;
  final String? rest;
}

class ExercisePlanState {
  const ExercisePlanState(
      {this.planName = 'My Plan',
      this.day = 'Day 1',
      this.dayToExercisesMap = const {'Day 1': []}});

  final String planName;
  final String day;
  final Map<String, List<Exercise>> dayToExercisesMap;

  List<String> get days => dayToExercisesMap.keys.toList();
  List<Exercise>? get exercises => dayToExercisesMap[day];
}

class ExercisePlanNotifier extends StateNotifier<ExercisePlanState> {
  ExercisePlanNotifier() : super(const ExercisePlanState());

  void changePlanName(String name) {
    state = ExercisePlanState(
        planName: name,
        day: state.day,
        dayToExercisesMap: state.dayToExercisesMap);
  }

  void addExercise(Exercise exercise) {
    if (state.day == '') {
      throw Exception('Add a day before adding exercises');
    }

    final Map<String, List<Exercise>> newDayToExercisesMap = {};
    state.dayToExercisesMap.forEach((key, value) {
      if (key == state.day) {
        List<Exercise> newExerciseList = List.from(value);
        newExerciseList.add(exercise);
        newDayToExercisesMap[key] = newExerciseList;
      } else {
        newDayToExercisesMap[key] = value;
      }
    });

    state = ExercisePlanState(
        planName: state.planName,
        day: state.day,
        dayToExercisesMap: newDayToExercisesMap);
  }

  void removeExercise(Exercise exercise) {
    final Map<String, List<Exercise>> newDayToExercisesMap = {};
    state.dayToExercisesMap.forEach((key, value) {
      if (key == state.day) {
        List<Exercise> newExerciseList = List.from(value);
        newExerciseList.remove(exercise);
        newDayToExercisesMap[key] = newExerciseList;
      } else {
        newDayToExercisesMap[key] = value;
      }
    });

    state = ExercisePlanState(
        planName: state.planName,
        day: state.day,
        dayToExercisesMap: newDayToExercisesMap);
  }

  void moveExercise(int oldIndex, int newIndex) {
    final Map<String, List<Exercise>> newDayToExercisesMap = {};

    List<Exercise> newExerciseList = List.from(state.exercises!);
    if (newIndex >= oldIndex) newIndex--;
    newExerciseList.insert(newIndex, newExerciseList.removeAt(oldIndex));

    state.dayToExercisesMap.forEach((key, value) {
      if (key == state.day) {
        newDayToExercisesMap[key] = newExerciseList;
      } else {
        newDayToExercisesMap[key] = value;
      }
    });

    state = ExercisePlanState(
        planName: state.planName,
        day: state.day,
        dayToExercisesMap: newDayToExercisesMap);
  }

  void addDay(String day) {
    if (day == '') {
      throw Exception('Day must not be empty');
    }

    if (state.dayToExercisesMap.containsKey(day)) {
      throw Exception('Each day must have a unique name');
    }

    final newDayToExercisesMap =
        Map<String, List<Exercise>>.from(state.dayToExercisesMap);
    newDayToExercisesMap[day] = [];

    state = ExercisePlanState(
        planName: state.planName,
        day: day,
        dayToExercisesMap: newDayToExercisesMap);
  }

  void updateDayName(String name) {
    if (name == '') {
      throw Exception('Day must not be empty');
    }

    if (state.dayToExercisesMap.containsKey(name)) {
      throw Exception('Each day must have a unique name');
    }

    final Map<String, List<Exercise>> newDayToExercisesMap = {};
    state.dayToExercisesMap.forEach((key, value) {
      if (key == state.day) {
        List<Exercise> newExerciseList = value;
        newDayToExercisesMap[name] = newExerciseList;
      } else {
        newDayToExercisesMap[key] = value;
      }
    });

    state = ExercisePlanState(
        planName: state.planName,
        day: name,
        dayToExercisesMap: newDayToExercisesMap);
  }

  void selectDay(String day) {
    state = ExercisePlanState(
        planName: state.planName,
        day: day,
        dayToExercisesMap: state.dayToExercisesMap);
  }

  void removeDay(String day) {
    String newDay = state.dayToExercisesMap.length == 1
        ? ''
        : state.dayToExercisesMap.keys.last;

    final newDayToExercisesMap =
        Map<String, List<Exercise>>.from(state.dayToExercisesMap);
    newDayToExercisesMap.remove(day);

    state = ExercisePlanState(
        planName: state.planName,
        day: newDay,
        dayToExercisesMap: newDayToExercisesMap);
  }
}

final exercisePlanProvider =
    StateNotifierProvider<ExercisePlanNotifier, ExercisePlanState>(
        ((ref) => ExercisePlanNotifier()));

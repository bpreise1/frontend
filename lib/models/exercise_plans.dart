import 'dart:convert';

import 'package:frontend/models/exercise.dart';
import 'package:uuid/uuid.dart';

class InProgressExercisePlan {
  const InProgressExercisePlan(
      {this.planName = 'My Plan',
      this.dayToExercisesMap = const {'Day 1': []}});

  final String planName;
  final Map<String, List<Exercise>> dayToExercisesMap;
}

class CompletedExercisePlan {
  CompletedExercisePlan(
      {required this.planName, required this.dayToExercisesMap});

  String id = const Uuid().v4();
  final String planName;
  Map<String, List<Exercise>> dayToExercisesMap;

  factory CompletedExercisePlan.fromJson(Map<String, dynamic> json) {
    jsonToExerciseList(List exerciseList) =>
        exerciseList.map((exercise) => Exercise.fromJson(exercise)).toList();

    Map plan = json['plan'] as Map;
    Map<String, List<Exercise>> parsedDayToExercisesMap = plan.map(
        (day, exerciseList) => MapEntry(day, jsonToExerciseList(exerciseList)));

    CompletedExercisePlan completedExercisePlan = CompletedExercisePlan(
        planName: json['planName'], dayToExercisesMap: parsedDayToExercisesMap);
    completedExercisePlan.id = json['id'];
    return completedExercisePlan;
  }

  Map<String, dynamic> toJson() {
    exerciseListToJson(List<Exercise> exerciseList) =>
        exerciseList.map((exercise) => exercise.toJson()).toList();
    return {
      'id': id,
      'planName': planName,
      'plan': dayToExercisesMap.map<String, List<Map<String, String>>>(
          (day, exerciseList) =>
              MapEntry(day, exerciseListToJson(exerciseList))),
    };
  }
}

import 'dart:convert';

import 'package:frontend/models/comment.dart';
import 'package:frontend/models/custom_user.dart';
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
      {required this.planName,
      required this.dayToExercisesMap,
      required this.lastUsed});

  String id = const Uuid().v4();
  final String planName;
  Map<String, List<Exercise>> dayToExercisesMap;
  bool isInProgress = false;
  DateTime lastUsed;

  factory CompletedExercisePlan.fromJson(Map<String, dynamic> json) {
    jsonToExerciseList(List exerciseList) =>
        exerciseList.map((exercise) => Exercise.fromJson(exercise)).toList();

    Map plan = json['plan'] as Map;
    Map<String, List<Exercise>> parsedDayToExercisesMap = plan.map(
        (day, exerciseList) => MapEntry(day, jsonToExerciseList(exerciseList)));

    CompletedExercisePlan completedExercisePlan = CompletedExercisePlan(
        planName: json['planName'],
        dayToExercisesMap: parsedDayToExercisesMap,
        lastUsed: DateTime.parse(json['lastUsed']));
    completedExercisePlan.id = json['id'];
    completedExercisePlan.isInProgress = json['isInProgress'];
    return completedExercisePlan;
  }

  Map<String, dynamic> toJson() {
    exerciseListToJson(List<Exercise> exerciseList) =>
        exerciseList.map((exercise) => exercise.toJson()).toList();
    return {
      'id': id,
      'planName': planName,
      'lastUsed': lastUsed.toString(),
      'isInProgress': isInProgress,
      'plan': dayToExercisesMap.map<String, List<Map<String, dynamic>>>(
          (day, exerciseList) =>
              MapEntry(day, exerciseListToJson(exerciseList))),
    };
  }
}

class PublishedExercisePlan {
  const PublishedExercisePlan({
    required this.id,
    required this.planName,
    required this.dayToExercisesMap,
    required this.description,
    required this.creatorUserId,
    required this.dateCreated,
    this.likedBy = const [],
    this.comments = const [],
  });

  final String id;
  final String planName;
  final Map<String, List<Exercise>> dayToExercisesMap;
  final String description;
  final String creatorUserId;
  final DateTime dateCreated;
  final List<String> likedBy;
  final List<Comment> comments;

  factory PublishedExercisePlan.fromJson(Map<String, dynamic> json) {
    jsonToExerciseList(List exerciseList) =>
        exerciseList.map((exercise) => Exercise.fromJson(exercise)).toList();

    Map plan = json['plan'] as Map;
    Map<String, List<Exercise>> parsedDayToExercisesMap = plan.map(
        (day, exerciseList) => MapEntry(day, jsonToExerciseList(exerciseList)));

    List comments = json['comments'];
    List likedBy = json['likedBy'];

    return PublishedExercisePlan(
      id: json['id'],
      planName: json['planName'],
      dayToExercisesMap: parsedDayToExercisesMap,
      description: json['description'],
      creatorUserId: json['creatorUserId'],
      dateCreated: DateTime.parse(json['dateCreated']),
      likedBy: likedBy.map((like) => like as String).toList(),
      comments: comments.map((comment) => Comment.fromJson(comment)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    exerciseListToJson(List<Exercise> exerciseList) =>
        exerciseList.map((exercise) => exercise.toJson()).toList();
    return {
      'id': id,
      'planName': planName,
      'plan': dayToExercisesMap.map<String, List<Map<String, dynamic>>>(
          (day, exerciseList) =>
              MapEntry(day, exerciseListToJson(exerciseList))),
      'description': description,
      'creatorUserId': creatorUserId,
      'dateCreated': dateCreated.toString(),
      'likedBy': likedBy,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }
}

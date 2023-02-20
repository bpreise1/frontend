import 'package:frontend/models/comment.dart';
import 'package:frontend/models/exercise.dart';

abstract class ExercisePlan {
  const ExercisePlan({required this.planName, required this.dayToExercisesMap});

  final String planName;
  final Map<String, List<Exercise>> dayToExercisesMap;
}

class InProgressExercisePlan extends ExercisePlan {
  const InProgressExercisePlan(
      {super.planName = 'My Plan',
      super.dayToExercisesMap = const {'Day 1': []}});
}

class CompletedExercisePlan extends ExercisePlan {
  CompletedExercisePlan(
      {required this.id,
      required super.planName,
      required super.dayToExercisesMap,
      this.isInProgress = false,
      required this.lastUsed});

  final String id;
  final bool isInProgress;
  final DateTime lastUsed;

  factory CompletedExercisePlan.fromJson(Map<String, dynamic> json) {
    jsonToExerciseList(List exerciseList) =>
        exerciseList.map((exercise) => Exercise.fromJson(exercise)).toList();

    Map plan = json['plan'] as Map;
    Map<String, List<Exercise>> parsedDayToExercisesMap = plan.map(
        (day, exerciseList) => MapEntry(day, jsonToExerciseList(exerciseList)));

    CompletedExercisePlan completedExercisePlan = CompletedExercisePlan(
      id: json['id'],
      planName: json['planName'],
      dayToExercisesMap: parsedDayToExercisesMap,
      isInProgress: json['isInProgress'],
      lastUsed: DateTime.parse(
        json['lastUsed'],
      ),
    );
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

class PublishedExercisePlan extends ExercisePlan {
  const PublishedExercisePlan({
    required this.id,
    required super.planName,
    required super.dayToExercisesMap,
    required this.description,
    required this.creatorUserId,
    required this.dateCreated,
    this.likedBy = const [],
    this.comments = const [],
    this.totalComments = 0,
  });

  final String id;
  final String description;
  final String creatorUserId;
  final DateTime dateCreated;
  final List<String> likedBy;
  final List<Comment> comments;
  final int totalComments;

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
      totalComments: json['totalComments'],
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
      'totalComments': totalComments,
    };
  }
}

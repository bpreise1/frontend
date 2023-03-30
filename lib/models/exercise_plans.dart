import 'package:frontend/models/comment.dart';
import 'package:frontend/models/exercise.dart';
import 'package:frontend/models/week.dart';

class ExercisePlan {
  const ExercisePlan({required this.planName, required this.dayToExercisesMap});

  final String planName;
  final Map<String, List<Exercise>> dayToExercisesMap;
}

class SavedExercisePlan extends ExercisePlan {
  SavedExercisePlan(
      {required this.id,
      required super.planName,
      required super.dayToExercisesMap,
      required this.weeks,
      required this.lastUsed});

  final String id;
  final DateTime lastUsed;
  List<Week> weeks;

  factory SavedExercisePlan.fromJson(Map<String, dynamic> json) {
    jsonToExerciseList(List exerciseList) =>
        exerciseList.map((exercise) => Exercise.fromJson(exercise)).toList();

    Map plan = json['plan'] as Map;
    Map<String, List<Exercise>> parsedDayToExercisesMap = plan.map(
        (day, exerciseList) => MapEntry(day, jsonToExerciseList(exerciseList)));

    List weeks = json['weeks'];

    SavedExercisePlan completedExercisePlan = SavedExercisePlan(
        id: json['id'],
        planName: json['planName'],
        dayToExercisesMap: parsedDayToExercisesMap,
        lastUsed: DateTime.parse(
          json['lastUsed'],
        ),
        weeks: weeks
            .map(
              (week) => Week.fromJson(week),
            )
            .toList());
    return completedExercisePlan;
  }

  Map<String, dynamic> toJson() {
    exerciseListToJson(List<Exercise> exerciseList) =>
        exerciseList.map((exercise) => exercise.toJson()).toList();
    return {
      'id': id,
      'planName': planName,
      'lastUsed': lastUsed.toString(),
      'plan': dayToExercisesMap.map<String, List<Map<String, dynamic>>>(
        (day, exerciseList) => MapEntry(
          day,
          exerciseListToJson(exerciseList),
        ),
      ),
      'weeks': weeks
          .map(
            (week) => week.toJson(),
          )
          .toList(),
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

import 'package:flutter/material.dart';
import 'package:frontend/models/exercise_plans.dart';

class CustomUser {
  const CustomUser({
    required this.username,
    this.publishedPlans = const [],
    this.progressPictures = const [],
    this.visibilitySettings = const {},
  });

  final String username;
  final List<PublishedExercisePlan> publishedPlans;
  final List<Image> progressPictures;
  final Map<String, dynamic> visibilitySettings;

  factory CustomUser.fromJson(Map<String, dynamic> json) {
    List plans = json['exercise_plans'];
    List<PublishedExercisePlan> publishedPlans =
        plans.map((plan) => PublishedExercisePlan.fromJson(plan)).toList();

    return CustomUser(
      username: json['username'],
      publishedPlans: publishedPlans,
      progressPictures: [],
      visibilitySettings: json['visibility_settings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'exercise_plans': publishedPlans.map((plan) => plan.toJson()).toList(),
      'progress_pictures': [],
      'visibilitySettings': visibilitySettings,
    };
  }
}

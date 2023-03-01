import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/models/progress_picture.dart';

class CustomUser {
  const CustomUser({
    required this.id,
    required this.username,
    this.publishedPlans = const [],
    this.visibilitySettings = const {},
    this.profilePicture,
    this.progressPictures = const [],
  });

  final String id;
  final String username;
  final List<PublishedExercisePlan> publishedPlans;
  final Map<String, dynamic> visibilitySettings;
  final Uint8List? profilePicture;
  final List<ProgressPicture> progressPictures;

  factory CustomUser.fromJson(Map<String, dynamic> json,
      {Uint8List? profilePicture,
      List<ProgressPicture> progressPictures = const []}) {
    List plans = json['exercise_plans'];
    List<PublishedExercisePlan> publishedPlans =
        plans.map((plan) => PublishedExercisePlan.fromJson(plan)).toList();

    return CustomUser(
      id: json['uid'],
      username: json['username'],
      publishedPlans: publishedPlans,
      visibilitySettings: json['visibility_settings'],
      profilePicture: profilePicture,
      progressPictures: progressPictures,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'username': username,
      'exercise_plans': publishedPlans.map((plan) => plan.toJson()).toList(),
      'visibility_settings': visibilitySettings,
    };
  }
}

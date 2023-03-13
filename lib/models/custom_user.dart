import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/models/progress_picture.dart';
import 'package:frontend/models/custom_user_info.dart';
import 'package:frontend/models/visibility_settings.dart';

class CustomUser {
  const CustomUser({
    required this.id,
    required this.username,
    this.publishedPlans = const [],
    this.visibilitySettings = const VisibilitySettings(),
    this.profilePicture,
    this.progressPictures = const [],
    this.followers = const [],
    this.followRequests = const [],
  });

  final String id;
  final String username;
  final List<PublishedExercisePlan> publishedPlans;
  final VisibilitySettings visibilitySettings;
  final Uint8List? profilePicture;
  final List<ProgressPicture> progressPictures;
  final List<String> followers;
  final List<CustomUserInfo> followRequests;

  factory CustomUser.fromJson(Map<String, dynamic> json,
      {Uint8List? profilePicture,
      List<ProgressPicture> progressPictures = const [],
      List<CustomUserInfo> followRequests = const []}) {
    List plans = json['exercise_plans'];
    List<PublishedExercisePlan> publishedPlans =
        plans.map((plan) => PublishedExercisePlan.fromJson(plan)).toList();
    List followers = json['followers'];

    return CustomUser(
      id: json['uid'],
      username: json['username'],
      publishedPlans: publishedPlans,
      visibilitySettings: VisibilitySettings.fromJson(
        json['visibility_settings'],
      ),
      profilePicture: profilePicture,
      progressPictures: progressPictures,
      followers: followers.map((follower) => follower as String).toList(),
      followRequests: followRequests,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': id,
      'username': username,
      'exercise_plans': publishedPlans.map((plan) => plan.toJson()).toList(),
      'visibility_settings': visibilitySettings.toJson(),
      'followers': followers,
      'follow_requests':
          followRequests.map((request) => request.toJson()).toList(),
    };
  }
}

class VisibilitySettings {
  const VisibilitySettings(
      {this.showExercisePlans = true,
      this.showProgressPictures = true,
      this.isPublicProfile = false});

  final bool isPublicProfile;
  final bool showExercisePlans;
  final bool showProgressPictures;

  VisibilitySettings.fromJson(Map<String, dynamic> json)
      : isPublicProfile = json['public_profile'],
        showExercisePlans = json['show_exercise_plans'],
        showProgressPictures = json['show_progress_pictures'];

  Map<String, dynamic> toJson() {
    return {
      'public_profile': isPublicProfile,
      'show_exercise_plans': showExercisePlans,
      'show_progress_pictures': showProgressPictures,
    };
  }
}

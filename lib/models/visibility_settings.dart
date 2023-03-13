class VisibilitySettings {
  const VisibilitySettings({this.isPublicProfile = false});

  final bool isPublicProfile;

  VisibilitySettings.fromJson(Map<String, dynamic> json)
      : isPublicProfile = json['public_profile'];

  Map<String, dynamic> toJson() {
    return {
      'public_profile': isPublicProfile,
    };
  }
}

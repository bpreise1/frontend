enum WeightMode { pounds, kilograms }

class UserPreferences {
  const UserPreferences({required this.weightMode});

  final WeightMode weightMode;

  UserPreferences.fromJson(Map<String, dynamic> json)
      : weightMode = WeightMode.values
            .firstWhere((element) => element.toString() == json['weightMode']);

  Map<String, dynamic> toJson() {
    return {'weightMode': weightMode.toString()};
  }
}

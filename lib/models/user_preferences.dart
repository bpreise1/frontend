enum WeightMode { pounds, kilograms }

class UserPreferences {
  const UserPreferences({required this.weightMode});

  final WeightMode weightMode;

  UserPreferences.fromJson(Map<String, dynamic> json)
      : weightMode = WeightMode.values.firstWhere(
            (element) => element.name.toString() == json['weightMode']);

  Map<String, dynamic> toJson() {
    return {'weightMode': weightMode.name.toString()};
  }
}

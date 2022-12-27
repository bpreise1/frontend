class Exercise {
  const Exercise({
    required this.name,
    required this.description,
    this.sets = '',
    this.reps = '',
  });

  final String name;
  final String description;
  final String sets;
  final String reps;

  Exercise.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        description = json['description'],
        sets = json['sets'],
        reps = json['reps'];

  Map<String, String> toJson() =>
      {'name': name, 'description': description, 'sets': sets, 'reps': reps};
}

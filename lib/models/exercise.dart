class Exercise {
  const Exercise({
    required this.name,
    required this.description,
    this.sets = '',
    this.reps = const [''],
  });

  final String name;
  final String description;
  final String sets;
  final List<String> reps;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    List jsonReps = json['reps'];
    List<String> reps = jsonReps.map((rep) => rep as String).toList();

    return Exercise(
        name: json['name'],
        description: json['description'],
        sets: json['sets'],
        reps: reps);
  }

  Map<String, dynamic> toJson() =>
      {'name': name, 'description': description, 'sets': sets, 'reps': reps};
}

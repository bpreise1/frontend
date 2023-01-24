class Exercise {
  const Exercise({
    required this.name,
    required this.description,
    this.sets = '',
    this.goalReps = const [''],
    this.reps = const [''],
    this.weights = const [''],
  });

  final String name;
  final String description;
  final String sets;
  final List<String> goalReps;
  final List<String> reps;
  final List<String> weights;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    List jsonReps = json['reps'];
    List<String> reps = jsonReps.map((rep) => rep as String).toList();

    List jsonGoalReps = json['goalReps'];
    List<String> goalReps = jsonGoalReps.map((rep) => rep as String).toList();

    List jsonWeights = json['weights'];
    List<String> weights =
        jsonWeights.map((weight) => weight as String).toList();

    return Exercise(
        name: json['name'],
        description: json['description'],
        sets: json['sets'],
        goalReps: goalReps,
        reps: reps,
        weights: weights);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'sets': sets,
        'goalReps': goalReps,
        'reps': reps,
        'weights': weights,
      };
}

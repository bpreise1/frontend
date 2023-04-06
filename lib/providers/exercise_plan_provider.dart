import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/models/user_exception.dart';

class ExercisePlanState {
  const ExercisePlanState({
    required exercisePlan,
    this.currentDay = 'Day 1',
    this.description = '',
  }) : _exercisePlan = exercisePlan;

  final ExercisePlan _exercisePlan;
  final String currentDay;
  final String description;

  ExercisePlan get exercisePlan => _exercisePlan;
  Map<String, List<Exercise>> get dayToExercisesMap =>
      exercisePlan.dayToExercisesMap;
  String get planName => exercisePlan.planName;
  List<String> get days => exercisePlan.dayToExercisesMap.keys.toList();
  List<Exercise>? get exercises => exercisePlan.dayToExercisesMap[currentDay];
}

class ExercisePlanNotifier extends StateNotifier<ExercisePlanState> {
  ExercisePlanNotifier()
      : super(
          const ExercisePlanState(
            exercisePlan: ExercisePlan(
              planName: "My Plan",
              dayToExercisesMap: {
                'Day 1': [],
              },
            ),
          ),
        );

  void changePlanName(String name) {
    state = ExercisePlanState(
      exercisePlan: ExercisePlan(
        planName: name,
        dayToExercisesMap: state.dayToExercisesMap,
      ),
      currentDay: state.currentDay,
      description: state.description,
    );
  }

  void resetPlan() {
    state = const ExercisePlanState(
      exercisePlan: ExercisePlan(
        planName: "My Plan",
        dayToExercisesMap: {
          'Day 1': [],
        },
      ),
    );
  }

  void addExercise(Exercise exercise) {
    final Map<String, List<Exercise>> newDayToExercisesMap = {};
    state.dayToExercisesMap.forEach((key, value) {
      if (key == state.currentDay) {
        List<Exercise> newExerciseList = List.from(value);
        newExerciseList.add(exercise);
        newDayToExercisesMap[key] = newExerciseList;
      } else {
        newDayToExercisesMap[key] = value;
      }
    });

    state = ExercisePlanState(
      exercisePlan: ExercisePlan(
          planName: state.planName, dayToExercisesMap: newDayToExercisesMap),
      currentDay: state.currentDay,
      description: state.description,
    );
  }

  void removeExerciseAt(int index) {
    final Map<String, List<Exercise>> newDayToExercisesMap = {};
    state.dayToExercisesMap.forEach((key, value) {
      if (key == state.currentDay) {
        List<Exercise> newExerciseList = List.from(value);
        newExerciseList.removeAt(index);
        newDayToExercisesMap[key] = newExerciseList;
      } else {
        newDayToExercisesMap[key] = value;
      }
    });

    state = ExercisePlanState(
        exercisePlan: ExercisePlan(
            planName: state.planName, dayToExercisesMap: newDayToExercisesMap),
        currentDay: state.currentDay,
        description: state.description);
  }

  void moveExercise(int oldIndex, int newIndex) {
    final Map<String, List<Exercise>> newDayToExercisesMap = {};

    List<Exercise> newExerciseList = List.from(state.exercises!);
    if (newIndex >= oldIndex) newIndex--;
    newExerciseList.insert(newIndex, newExerciseList.removeAt(oldIndex));

    state.dayToExercisesMap.forEach((key, value) {
      if (key == state.currentDay) {
        newDayToExercisesMap[key] = newExerciseList;
      } else {
        newDayToExercisesMap[key] = value;
      }
    });

    state = ExercisePlanState(
        exercisePlan: ExercisePlan(
            planName: state.planName, dayToExercisesMap: newDayToExercisesMap),
        currentDay: state.currentDay,
        description: state.description);
  }

  void addDay() {
    int numDayToAdd = state.days.length + 1;
    while (state.dayToExercisesMap.containsKey('Day $numDayToAdd')) {
      numDayToAdd++;
    }

    String day = 'Day $numDayToAdd';

    final newDayToExercisesMap =
        Map<String, List<Exercise>>.from(state.dayToExercisesMap);
    newDayToExercisesMap[day] = [];

    state = ExercisePlanState(
        exercisePlan: ExercisePlan(
            planName: state.planName, dayToExercisesMap: newDayToExercisesMap),
        currentDay: day,
        description: state.description);
  }

  void updateDayName(String name) {
    if (name == '') {
      throw const UserException(message: 'Day must not be empty');
    }

    if (state.currentDay != name && state.dayToExercisesMap.containsKey(name)) {
      throw UserException(message: 'Name "$name" can only be used once');
    }

    final Map<String, List<Exercise>> newDayToExercisesMap = {};
    state.dayToExercisesMap.forEach((key, value) {
      if (key == state.currentDay) {
        List<Exercise> newExerciseList = value;
        newDayToExercisesMap[name] = newExerciseList;
      } else {
        newDayToExercisesMap[key] = value;
      }
    });

    state = ExercisePlanState(
        exercisePlan: ExercisePlan(
            planName: state.planName, dayToExercisesMap: newDayToExercisesMap),
        currentDay: name,
        description: state.description);
  }

  void selectDay(String day) {
    if (day != state.currentDay) {
      state = ExercisePlanState(
          exercisePlan: state.exercisePlan,
          currentDay: day,
          description: state.description);
    }
  }

  void removeDay(String day) {
    final newDayToExercisesMap =
        Map<String, List<Exercise>>.from(state.dayToExercisesMap);
    int indexToRemove = newDayToExercisesMap.keys.toList().indexOf(day);
    newDayToExercisesMap.remove(day);

    String newDay;
    if (indexToRemove == 0) {
      newDay = newDayToExercisesMap.keys.first;
    } else {
      newDay = newDayToExercisesMap.keys.toList()[indexToRemove - 1];
    }

    state = ExercisePlanState(
        exercisePlan: ExercisePlan(
            planName: state.planName, dayToExercisesMap: newDayToExercisesMap),
        currentDay: newDay,
        description: state.description);
  }

  void updateSets(String day, int index, String sets) {
    int numSets = sets == '' ? 0 : int.parse(sets);

    final newDayToExercisesMap =
        Map<String, List<Exercise>>.from(state.dayToExercisesMap);

    final newReps = List.filled(numSets, '');

    final newWeights = List.filled(numSets, '');

    Exercise exerciseToReplace = newDayToExercisesMap[day]![index];

    final newGoalReps = List.filled(numSets, '');
    for (int i = 0; i < numSets; i++) {
      if (i < exerciseToReplace.goalReps.length) {
        newGoalReps[i] = exerciseToReplace.goalReps[i];
      }
    }

    newDayToExercisesMap[day]![index] = Exercise(
        name: exerciseToReplace.name,
        description: exerciseToReplace.description,
        sets: sets,
        goalReps: newGoalReps,
        reps: newReps,
        weights: newWeights);

    state = ExercisePlanState(
        exercisePlan: ExercisePlan(
            planName: state.planName, dayToExercisesMap: newDayToExercisesMap),
        currentDay: state.currentDay,
        description: state.description);
  }

  void updateGoalReps(String day, int index, int set, String goalReps) {
    final newDayToExercisesMap =
        Map<String, List<Exercise>>.from(state.dayToExercisesMap);

    Exercise exerciseToReplace = newDayToExercisesMap[day]![index];

    final newGoalReps = [...exerciseToReplace.goalReps];
    newGoalReps[set] = goalReps;

    newDayToExercisesMap[day]![index] = Exercise(
        name: exerciseToReplace.name,
        description: exerciseToReplace.description,
        sets: exerciseToReplace.sets,
        goalReps: newGoalReps,
        reps: exerciseToReplace.reps,
        weights: exerciseToReplace.weights);

    state = ExercisePlanState(
      exercisePlan: ExercisePlan(
          planName: state.planName, dayToExercisesMap: newDayToExercisesMap),
      currentDay: state.currentDay,
      description: state.description,
    );
  }

  void updateRepsForSet(String day, int index, int set, String reps) {
    final newDayToExercisesMap =
        Map<String, List<Exercise>>.from(state.dayToExercisesMap);

    Exercise exerciseToReplace = newDayToExercisesMap[day]![index];

    final newReps = [...exerciseToReplace.reps];
    newReps[set] = reps;

    newDayToExercisesMap[day]![index] = Exercise(
        name: exerciseToReplace.name,
        description: exerciseToReplace.description,
        sets: exerciseToReplace.sets,
        goalReps: exerciseToReplace.goalReps,
        reps: newReps,
        weights: exerciseToReplace.weights);

    state = ExercisePlanState(
        exercisePlan: ExercisePlan(
            planName: state.planName, dayToExercisesMap: newDayToExercisesMap),
        currentDay: state.currentDay,
        description: state.description);
  }

  void updateWeightForSet(String day, int index, int set, String weight) {
    final newDayToExercisesMap =
        Map<String, List<Exercise>>.from(state.dayToExercisesMap);

    Exercise exerciseToReplace = newDayToExercisesMap[day]![index];

    final newWeights = [...exerciseToReplace.weights];
    newWeights[set] = weight;

    newDayToExercisesMap[day]![index] = Exercise(
        name: exerciseToReplace.name,
        description: exerciseToReplace.description,
        sets: exerciseToReplace.sets,
        goalReps: exerciseToReplace.goalReps,
        reps: exerciseToReplace.reps,
        weights: newWeights);

    state = ExercisePlanState(
        exercisePlan: ExercisePlan(
            planName: state.planName, dayToExercisesMap: newDayToExercisesMap),
        currentDay: state.currentDay,
        description: state.description);
  }

  void editPlan(SavedExercisePlan exercisePlan) {
    final Map<String, List<Exercise>> newDayToExercisesMap = {};
    exercisePlan.dayToExercisesMap.forEach((day, exercises) {
      final newExerciseList = exercises.map((exercise) {
        final newReps = List.filled(int.parse(exercise.sets), '');

        final newWeights = List.filled(int.parse(exercise.sets), '');

        return Exercise(
          name: exercise.name,
          description: exercise.description,
          sets: exercise.sets,
          goalReps: exercise.goalReps,
          reps: newReps,
          weights: newWeights,
        );
      }).toList();
      newDayToExercisesMap[day] = newExerciseList;
    });

    state = ExercisePlanState(
      exercisePlan: ExercisePlan(
          planName: '${exercisePlan.planName} (Copy)',
          dayToExercisesMap: newDayToExercisesMap),
      currentDay: exercisePlan.dayToExercisesMap.keys.first,
    );
  }

  void setPlan(ExercisePlan exercisePlan) {
    //TODO: change currentDay logic
    state = ExercisePlanState(
        exercisePlan: exercisePlan,
        currentDay: exercisePlan.dayToExercisesMap.keys.first,
        description: state.description);
  }

  void setDescription(String description) {
    state = ExercisePlanState(
        exercisePlan: state.exercisePlan,
        currentDay: state.currentDay,
        description: description);
  }

  bool isEditing() {
    if (state.days.length == 1 &&
        state.currentDay == 'Day 1' &&
        (state.exercises == null || state.exercises!.isEmpty)) {
      return false;
    }
    return true;
  }
}

final createExercisePlanProvider =
    StateNotifierProvider<ExercisePlanNotifier, ExercisePlanState>(
        ((ref) => ExercisePlanNotifier()));

final savedExercisePlanProvider =
    StateNotifierProvider<ExercisePlanNotifier, ExercisePlanState>(
        ((ref) => ExercisePlanNotifier()));

final publishedExercisePlanProvider =
    StateNotifierProvider<ExercisePlanNotifier, ExercisePlanState>(
        (ref) => ExercisePlanNotifier());
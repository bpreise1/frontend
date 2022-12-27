import 'package:flutter/material.dart';
import 'package:frontend/models/exercise.dart';
import 'package:frontend/statics/all_exercises.dart';
import 'package:frontend/widgets/exercise_list_item.dart';

class ExerciseList extends StatefulWidget {
  const ExerciseList({super.key});

  @override
  State<ExerciseList> createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  List<Exercise> _exercises = allExercises;

  void _searchExercise(String query) {
    final suggestions = allExercises.where((exercise) {
      final String exerciseName = exercise.name.toLowerCase();
      final String input = query.toLowerCase();

      return exerciseName.contains(input);
    }).toList();

    setState(() {
      _exercises = suggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          onChanged: _searchExercise,
        ),
        Expanded(
            child: ListView(
          children: _exercises
              .map((exercise) => ExerciseListItem(
                    exercise: exercise,
                  ))
              .toList(),
        ))
      ],
    );
  }
}

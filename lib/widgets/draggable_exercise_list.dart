import 'package:flutter/material.dart';
import 'package:frontend/models/exercise.dart';
import 'package:frontend/statics/all_exercises.dart';
import 'package:frontend/widgets/draggable_exercise_list_item.dart';

class DraggableExerciseList extends StatefulWidget {
  const DraggableExerciseList({super.key});

  @override
  State<DraggableExerciseList> createState() => _DraggableExerciseListState();
}

class _DraggableExerciseListState extends State<DraggableExerciseList> {
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
              .map((exercise) => DraggableExerciseListItem(exercise: exercise))
              .toList(),
        ))
      ],
    );
  }
}

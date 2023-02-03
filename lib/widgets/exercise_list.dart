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
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onChanged: _searchExercise,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _exercises.length,
            prototypeItem: ExerciseListItem(
              exercise: allExercises.first,
            ),
            itemBuilder: (context, index) {
              return ExerciseListItem(
                exercise: _exercises[index],
              );
            },
          ),
        ),
      ],
    );
  }
}

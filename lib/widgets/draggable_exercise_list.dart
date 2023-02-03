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
            prototypeItem: DraggableExerciseListItem(
              exercise: allExercises.first,
            ),
            itemBuilder: (context, index) {
              return DraggableExerciseListItem(
                exercise: _exercises[index],
              );
            },
          ),
        )
      ],
    );
  }
}

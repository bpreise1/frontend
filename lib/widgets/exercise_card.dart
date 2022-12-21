import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/exercise_plan_provider.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard(
      {required this.exercise,
      this.isInsertedInCreatePlanList = false,
      super.key});

  final Exercise exercise;
  final bool isInsertedInCreatePlanList;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Row(
      children: [
        ImageIcon(exercise.image),
        Text(exercise.name),
        if (isInsertedInCreatePlanList)
          Consumer(builder: ((context, ref, child) {
            return IconButton(
                onPressed: () {
                  ref
                      .read(exercisePlanProvider.notifier)
                      .removeExercise(exercise);
                },
                icon: const Icon(Icons.delete));
          }))
      ],
    ));
  }
}

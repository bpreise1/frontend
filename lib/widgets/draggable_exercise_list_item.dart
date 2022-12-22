import 'package:flutter/material.dart';
import 'package:frontend/providers/exercise_plan_provider.dart';
import 'package:frontend/widgets/exercise_card.dart';
import 'package:frontend/widgets/exercise_list_item.dart';

class DraggableExerciseListItem extends StatelessWidget {
  const DraggableExerciseListItem({required this.exercise, super.key});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Draggable(
        data: exercise,
        feedback: ExerciseCard(exercise: exercise),
        childWhenDragging: ExerciseCard(exercise: exercise),
        child: ExerciseCard(exercise: exercise));
  }
}

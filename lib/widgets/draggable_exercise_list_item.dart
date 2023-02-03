import 'package:flutter/material.dart';
import 'package:frontend/models/exercise.dart';
import 'package:frontend/widgets/exercise_list_item.dart';

class DraggableExerciseListItem extends StatelessWidget {
  const DraggableExerciseListItem({required this.exercise, super.key});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable(
        delay: const Duration(milliseconds: 80),
        data: exercise,
        feedback: ExerciseListItem(
          imageSize: ImageSize.small,
          exercise: exercise,
          flexible: false,
        ),
        childWhenDragging:
            ExerciseListItem(imageSize: ImageSize.small, exercise: exercise),
        child:
            ExerciseListItem(imageSize: ImageSize.small, exercise: exercise));
  }
}

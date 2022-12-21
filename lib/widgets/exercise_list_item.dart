import 'package:flutter/material.dart';
import 'package:frontend/providers/exercise_plan_provider.dart';
import 'package:frontend/widgets/exercise_card.dart';

class ExerciseListItem extends StatelessWidget {
  const ExerciseListItem(
      {required this.exercise,
      this.isInsertedInCreatePlanList = false,
      super.key});

  final Exercise exercise;
  final bool isInsertedInCreatePlanList;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(exercise.name),
                  content: Column(
                    children: [Text(exercise.description)],
                  ),
                ));
      },
      child: ExerciseCard(
        exercise: exercise,
        isInsertedInCreatePlanList: isInsertedInCreatePlanList,
      ),
    );
  }
}

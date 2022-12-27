import 'package:flutter/material.dart';
import 'package:frontend/models/exercise_plans.dart';

class PlanListItem extends StatelessWidget {
  const PlanListItem(
      {required this.exercisePlan,
      this.children = const [],
      this.onTapEnabled = true,
      super.key});

  final CompletedExercisePlan exercisePlan;
  final List<Widget> children;
  final bool onTapEnabled;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: InkWell(
      onTap: onTapEnabled ? () {} : null,
      child: Card(
        child: Row(
          children: [Text(exercisePlan.planName), ...children],
        ),
      ),
    ));
  }
}

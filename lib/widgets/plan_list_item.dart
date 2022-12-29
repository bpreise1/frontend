import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/exercise_plan_provider.dart';
import 'package:frontend/screens/saved_plan_page.dart';

class PlanListItem extends ConsumerWidget {
  const PlanListItem(
      {required this.exercisePlan,
      this.children = const [],
      this.onTapEnabled = true,
      super.key});

  final CompletedExercisePlan exercisePlan;
  final List<Widget> children;
  final bool onTapEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
        child: InkWell(
      onTap: onTapEnabled
          ? () {
              ref
                  .read(savedExercisePlanProvider.notifier)
                  .setPlan(exercisePlan);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) =>
                          SavedPlanPage(exercisePlan: exercisePlan))));
            }
          : null,
      child: Card(
        child: Row(
          children: [Text(exercisePlan.planName), ...children],
        ),
      ),
    ));
  }
}
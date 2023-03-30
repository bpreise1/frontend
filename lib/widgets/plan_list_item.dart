import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/exercise_plan_provider.dart';
import 'package:frontend/screens/new_saved_plan_page.dart';
import 'package:frontend/screens/saved_plan_page.dart';

class PlanListItem extends ConsumerWidget {
  const PlanListItem(
      {required this.exercisePlan,
      this.children = const [],
      this.onTapEnabled = true,
      super.key});

  final SavedExercisePlan exercisePlan;
  final List<Widget> children;
  final bool onTapEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
        child: InkWell(
      onTap: onTapEnabled
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: ((context) => NewSavedPlanPage(
                        exercisePlanId: exercisePlan.id,
                      )),
                ),
              );
            }
          : null,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Text(
                exercisePlan.planName,
              ),
              const Spacer(),
              ...children
            ],
          ),
        ),
      ),
    ));
  }
}

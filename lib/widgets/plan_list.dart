import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/bottom_navigation_bar_provider.dart';
import 'package:frontend/providers/completed_exercise_plan_provider.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
import 'package:frontend/screens/plan_metrics_page.dart';
import 'package:frontend/widgets/plan_list_item.dart';

class PlanList extends ConsumerWidget {
  const PlanList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedExercisePlans = ref.watch(completedExercisePlansProvider);

    return completedExercisePlans.when(data: (data) {
      final List<CompletedExercisePlan> allPlans = data.exercisePlans;
      List<CompletedExercisePlan> plans = data.exercisePlans;

      return StatefulBuilder(builder: (context, setFilterState) {
        void searchExercise(String query) {
          final suggestions = allPlans.where((plan) {
            final String exerciseName = plan.planName.toLowerCase();
            final String input = query.toLowerCase();

            return exerciseName.contains(input);
          }).toList();

          setFilterState(() {
            plans = suggestions;
          });
        }

        return Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: searchExercise,
            ),
            Expanded(
                child: ListView(
              children: plans.map((plan) {
                return PlanListItem(
                  exercisePlan: plan,
                  children: [
                    IconButton(
                        onPressed: () {
                          ref
                              .read(savedExercisePlanProvider.notifier)
                              .setPlan(plan);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: ((context) =>
                                  PlanMetricsPage(exercisePlan: plan))));
                        },
                        icon: const Icon(Icons.bar_chart)),
                    IconButton(
                        onPressed: () {
                          void editPlanAndNavigate() {
                            ref
                                .read(createExercisePlanProvider.notifier)
                                .editPlan(plan);
                            ref
                                .read(bottomNavigationBarProvider.notifier)
                                .setNavigationBarIndex(2);
                          }

                          if (ref
                              .read(createExercisePlanProvider.notifier)
                              .isEditing()) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                      title: Text(
                                          'You are currently editing another plan in the Plan Creator. If you choose to edit "${plan.planName}," that progress will be overwritten. Are you sure you want to continue?'),
                                      content: Row(
                                        children: [
                                          OutlinedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('No')),
                                          OutlinedButton(
                                              onPressed: () {
                                                editPlanAndNavigate();
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Yes'))
                                        ],
                                      ));
                                });
                          } else {
                            editPlanAndNavigate();
                          }
                        },
                        icon: const Icon(Icons.edit)),
                    IconButton(
                        onPressed: () async {
                          await ref
                              .read(completedExercisePlansProvider.notifier)
                              .removeCompletedExercisePlanFromDevice(plan);
                        },
                        icon: const Icon(Icons.delete))
                  ],
                );
              }).toList(),
            ))
          ],
        );
      });
    }, loading: () {
      return Container();
    }, error: (error, stackTrace) {
      return Center(child: Text(error.toString()));
    });
  }
}

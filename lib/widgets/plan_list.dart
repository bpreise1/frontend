import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/bottom_navigation_bar_provider.dart';
import 'package:frontend/providers/completed_exercise_plan_provider.dart';
import 'package:frontend/providers/create_plan_stepper_provider.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
import 'package:frontend/screens/plan_metrics_page.dart';
import 'package:frontend/widgets/plan_list_item.dart';
import 'package:frontend/widgets/yes_no_dialog.dart';

class PlanList extends ConsumerWidget {
  const PlanList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedExercisePlans = ref.watch(completedExercisePlansProvider);

    return completedExercisePlans.when(data: (data) {
      final List<CompletedExercisePlan> allPlans = data.exercisePlans;
      List<CompletedExercisePlan> plans = data.exercisePlans;

      return plans.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Create a plan to begin tracking workouts',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 16)),
                  FloatingActionButton(
                    onPressed: () {
                      ref
                          .read(createPlanStepperProvider.notifier)
                          .setCreatePlanStepperIndex(0);
                      ref
                          .read(bottomNavigationBarProvider.notifier)
                          .setNavigationBarIndex(2);
                    },
                    child: const Icon(Icons.add),
                  )
                ],
              ),
            )
          : StatefulBuilder(builder: (context, setFilterState) {
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onChanged: searchExercise,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
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
                                      .read(createPlanStepperProvider.notifier)
                                      .setCreatePlanStepperIndex(0);
                                  ref
                                      .read(
                                          bottomNavigationBarProvider.notifier)
                                      .setNavigationBarIndex(2);
                                }

                                if (ref
                                    .read(createExercisePlanProvider.notifier)
                                    .isEditing()) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return YesNoDialog(
                                          title: Text(
                                            'You are currently editing another plan in the Plan Creator.\n\n If you choose to edit "${plan.planName}," that progress will be overwritten.\n\nAre you sure you want to continue?',
                                            textAlign: TextAlign.center,
                                          ),
                                          onNoPressed: () {
                                            Navigator.pop(context);
                                          },
                                          onYesPressed: () {
                                            editPlanAndNavigate();
                                            Navigator.pop(context);
                                          },
                                        );
                                      });
                                } else {
                                  editPlanAndNavigate();
                                }
                              },
                              icon: const Icon(Icons.edit)),
                          IconButton(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return YesNoDialog(
                                      title: Text(
                                        'If you delete "${plan.planName}," you will lose all metrics.\n\nAre you sure you want to continue?',
                                        textAlign: TextAlign.center,
                                      ),
                                      onNoPressed: () {
                                        Navigator.pop(context);
                                      },
                                      onYesPressed: () {
                                        ref
                                            .read(completedExercisePlansProvider
                                                .notifier)
                                            .removeCompletedExercisePlanFromDevice(
                                                plan);
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                );
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

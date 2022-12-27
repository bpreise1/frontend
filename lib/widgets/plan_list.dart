import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/bottom_navigation_bar_provider.dart';
import 'package:frontend/providers/exercise_plan_provider.dart';
import 'package:frontend/repository/completed_exercise_plan_repository.dart';
import 'package:frontend/widgets/plan_list_item.dart';

class PlanList extends StatelessWidget {
  const PlanList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: completedExercisePlanRepository
            .getCompletedExercisePlansFromDevice(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            assert(!snapshot.hasError && snapshot.data != null,
                'An error occured when retrieving plans');

            final List<CompletedExercisePlan> allPlans = snapshot.data!;
            List<CompletedExercisePlan> plans = snapshot.data!;

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
                  Expanded(child:
                      StatefulBuilder(builder: (context, setUpdatedState) {
                    return ListView(
                      children: plans
                          .map((plan) => PlanListItem(
                                exercisePlan: plan,
                                children: [
                                  Consumer(builder: (context, ref, child) {
                                    return IconButton(
                                        onPressed: () {
                                          void editPlanAndNavigate() {
                                            ref
                                                .read(exercisePlanProvider
                                                    .notifier)
                                                .editPlan(plan);
                                            ref
                                                .read(
                                                    bottomNavigationBarProvider
                                                        .notifier)
                                                .update((state) => 2);
                                          }

                                          if (ref
                                              .read(
                                                  exercisePlanProvider.notifier)
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
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                  'No')),
                                                          OutlinedButton(
                                                              onPressed: () {
                                                                editPlanAndNavigate();
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                  'Yes'))
                                                        ],
                                                      ));
                                                });
                                          } else {
                                            editPlanAndNavigate();
                                          }
                                        },
                                        icon: const Icon(Icons.edit));
                                  }),
                                  IconButton(
                                      onPressed: () {
                                        completedExercisePlanRepository
                                            .removeCompletedExercisePlanFromDevice(
                                                plan);
                                        setUpdatedState(() {
                                          plans.remove(plan);
                                          allPlans.remove(plan);
                                        });
                                      },
                                      icon: const Icon(Icons.delete))
                                ],
                              ))
                          .toList(),
                    );
                  }))
                ],
              );
            });
          }

          return const CircularProgressIndicator();
        });
  }
}

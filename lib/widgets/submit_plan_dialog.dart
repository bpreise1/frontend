import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/bottom_navigation_bar_provider.dart';
import 'package:frontend/providers/completed_exercise_plan_provider.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';

class SubmitPlanDialog extends StatelessWidget {
  const SubmitPlanDialog({super.key});

  @override
  Widget build(BuildContext context) {
    bool saveIsChecked = false;
    bool publishIsChecked = false;

    return AlertDialog(
        title: const Text('Save and Publish'),
        content: StatefulBuilder(
          builder: ((context, setState) {
            return Column(
              children: [
                CheckboxListTile(
                    title: const Text('Save'),
                    value: saveIsChecked,
                    onChanged: ((bool? value) {
                      setState(() {
                        saveIsChecked = value!;
                      });
                    })),
                CheckboxListTile(
                    title: const Text('Publish'),
                    value: publishIsChecked,
                    onChanged: ((bool? value) {
                      setState(() {
                        publishIsChecked = value!;
                      });
                    })),
                Consumer(builder: ((context, ref, child) {
                  InProgressExercisePlan inProgressExerciseplan =
                      ref.watch(createExercisePlanProvider).exercisePlan;

                  final CompletedExercisePlan completedExercisePlan =
                      CompletedExercisePlan(
                          planName: inProgressExerciseplan.planName,
                          dayToExercisesMap:
                              inProgressExerciseplan.dayToExercisesMap,
                          lastUsed: DateTime.now());

                  return OutlinedButton(
                      onPressed: saveIsChecked || publishIsChecked
                          ? () async {
                              assert(saveIsChecked || publishIsChecked,
                                  'Either save or publish must be selected');

                              if (saveIsChecked) {
                                await ref
                                    .read(
                                        completedExercisePlansProvider.notifier)
                                    .saveCompletedExercisePlanToDevice(
                                        completedExercisePlan);
                              }

                              if (publishIsChecked) {}

                              Navigator.pop(context);
                              ref
                                  .read(createExercisePlanProvider.notifier)
                                  .resetPlan();
                              ref
                                  .read(bottomNavigationBarProvider.notifier)
                                  .setNavigationBarIndex(3);
                            }
                          : null,
                      child: const Text('Submit'));
                }))
              ],
            );
          }),
        ));
  }
}

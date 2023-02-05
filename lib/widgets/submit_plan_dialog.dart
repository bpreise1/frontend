import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/bottom_navigation_bar_provider.dart';
import 'package:frontend/providers/completed_exercise_plan_provider.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
import 'package:frontend/widgets/edit_text.dart';

class SubmitPlanDialog extends ConsumerWidget {
  const SubmitPlanDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool saveIsChecked = false;
    bool publishIsChecked = false;

    return AlertDialog(title: Consumer(
      builder: (context, ref, child) {
        String planName = ref.watch(createExercisePlanProvider).planName;

        return Column(
          children: [
            EditText(
              text: planName,
              onSubmitted: (text) {
                ref
                    .read(createExercisePlanProvider.notifier)
                    .changePlanName(text);
              },
            ),
            const Divider(),
          ],
        );
      },
    ), content: StatefulBuilder(
      builder: ((context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              activeColor: Theme.of(context).colorScheme.secondary,
              checkColor: Theme.of(context).colorScheme.onSecondary,
              title: const Text('Save'),
              value: saveIsChecked,
              onChanged: ((bool? value) {
                setState(() {
                  saveIsChecked = value!;
                });
              }),
            ),
            CheckboxListTile(
                activeColor: Theme.of(context).colorScheme.secondary,
                checkColor: Theme.of(context).colorScheme.onSecondary,
                title: const Text('Publish'),
                value: publishIsChecked,
                onChanged: null
                //((bool? value) {
                //   setState(() {
                //     publishIsChecked = value!;
                //   });
                // }),
                ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
            ),
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
                                .read(completedExercisePlansProvider.notifier)
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

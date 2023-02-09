import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/bottom_navigation_bar_provider.dart';
import 'package:frontend/providers/completed_exercise_plan_provider.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/widgets/edit_text.dart';
import 'package:uuid/uuid.dart';

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
        return AnimatedSize(
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 250),
          child: Column(
            mainAxisSize:
                publishIsChecked ? MainAxisSize.max : MainAxisSize.min,
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
                onChanged: ((bool? value) {
                  setState(() {
                    publishIsChecked = value!;
                  });
                }),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
              ),
              if (publishIsChecked)
                Expanded(child: Consumer(
                  builder: (context, ref, child) {
                    return TextFormField(
                      initialValue:
                          ref.watch(createExercisePlanProvider).description,
                      onChanged: (text) {
                        ref
                            .read(createExercisePlanProvider.notifier)
                            .setDescription(text);
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: 1000,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter description'),
                    );
                  },
                )),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
              ),
              Consumer(builder: ((context, ref, child) {
                InProgressExercisePlan inProgressExerciseplan =
                    ref.watch(createExercisePlanProvider).exercisePlan;

                return OutlinedButton(
                    onPressed: saveIsChecked || publishIsChecked
                        ? () async {
                            assert(saveIsChecked || publishIsChecked,
                                'Either save or publish must be selected');

                            if (saveIsChecked) {
                              final CompletedExercisePlan
                                  completedExercisePlan = CompletedExercisePlan(
                                      planName: inProgressExerciseplan.planName,
                                      dayToExercisesMap: inProgressExerciseplan
                                          .dayToExercisesMap,
                                      lastUsed: DateTime.now());

                              await ref
                                  .read(completedExercisePlansProvider.notifier)
                                  .saveCompletedExercisePlanToDevice(
                                      completedExercisePlan);
                            }

                            if (publishIsChecked) {
                              final PublishedExercisePlan
                                  publishedExercisePlan = PublishedExercisePlan(
                                id: const Uuid().v4(),
                                planName: inProgressExerciseplan.planName,
                                dayToExercisesMap:
                                    inProgressExerciseplan.dayToExercisesMap,
                                description: ref
                                    .read(createExercisePlanProvider)
                                    .description,
                                creatorUserId:
                                    userRepository.getCurrentUserId(),
                                dateCreated: DateTime.now(),
                              );

                              await userRepository
                                  .publishExercisePlanForCurrentUser(
                                      publishedExercisePlan);
                            }

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
          ),
        );
      }),
    ));
  }
}

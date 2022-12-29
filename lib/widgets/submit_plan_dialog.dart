import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/bottom_navigation_bar_provider.dart';
import 'package:frontend/providers/exercise_plan_provider.dart';
import 'package:frontend/repository/completed_exercise_plan_repository.dart';
import 'package:frontend/screens/saved_plans_page.dart';

class SubmitPlanDialog extends StatelessWidget {
  const SubmitPlanDialog({super.key});

  @override
  Widget build(BuildContext context) {
    bool saveIsChecked = true;
    bool publishIsChecked = true;

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

                  void validatePlan() {
                    inProgressExerciseplan.dayToExercisesMap
                        .forEach((day, exercises) {
                      assert(
                          exercises.isNotEmpty, 'Day "$day" must not be empty');
                    });
                  }

                  final CompletedExercisePlan completedExercisePlan =
                      CompletedExercisePlan(
                          planName: inProgressExerciseplan.planName,
                          dayToExercisesMap:
                              inProgressExerciseplan.dayToExercisesMap,
                          lastUsed: DateTime.now());

                  return OutlinedButton(
                      onPressed: () async {
                        assert(saveIsChecked || publishIsChecked,
                            'Either save or publish must be selected');

                        validatePlan();

                        if (saveIsChecked) {
                          await completedExercisePlanRepository
                              .saveCompletedExercisePlansToDevice(
                                  completedExercisePlan);
                          print('DONE');
                        }

                        if (publishIsChecked) {}

                        Navigator.pop(context);
                        ref
                            .read(createExercisePlanProvider.notifier)
                            .resetPlan();
                        ref
                            .read(bottomNavigationBarProvider.notifier)
                            .update((state) => 3);
                      },
                      child: const Text('Submit'));
                }))
              ],
            );
          }),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/models/user_preferences.dart';
import 'package:frontend/models/workout.dart';
import 'package:frontend/providers/completed_exercise_plan_provider.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
import 'package:frontend/providers/user_preferences_provider.dart';
import 'package:frontend/repository/workout_repository.dart';
import 'package:frontend/utils/convert_weight.dart';
import 'package:frontend/widgets/day_select_dropdown.dart';
import 'package:frontend/widgets/exercise_list_item.dart';
import 'package:frontend/widgets/exercise_list_item_textfield.dart';

class SavedPlanPage extends StatefulWidget {
  const SavedPlanPage({required this.exercisePlan, super.key});

  final CompletedExercisePlan exercisePlan;

  @override
  State<SavedPlanPage> createState() => _SavedPlanPageState();
}

class _SavedPlanPageState extends State<SavedPlanPage> {
  bool _isInProgress = false;

  @override
  void initState() {
    super.initState();
    _isInProgress = widget.exercisePlan.isInProgress;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: ((context, ref, child) {
      final currentDay = ref.watch(savedExercisePlanProvider).currentDay;
      final inProgressPlan = ref.watch(savedExercisePlanProvider).exercisePlan;
      final planName = ref.watch(savedExercisePlanProvider).planName;
      final planExercises = ref.watch(savedExercisePlanProvider).exercises!;

      return Scaffold(
        appBar: AppBar(title: Text(planName)),
        body: Column(children: [
          DaySelectDropdown(provider: savedExercisePlanProvider),
          Expanded(
              child: ListView(children: [
            for (int index = 0; index < planExercises.length; index++)
              ExpansionTile(
                  key: PageStorageKey<String>('${currentDay}_$index'),
                  initiallyExpanded: true,
                  title: ExerciseListItem(
                    exercise: planExercises[index],
                  ),
                  children: [
                    for (int set = 1;
                        set < int.parse(planExercises[index].sets) + 1;
                        set++)
                      ListTile(
                          key: PageStorageKey<String>(
                              '${currentDay}_{$index}_$set'),
                          title: Row(children: [
                            Text('Set $set'),
                            Expanded(
                                child: ExerciseListItemTextfield(
                                    text: planExercises[index].reps[set],
                                    helperText: 'Reps',
                                    hintText: planExercises[index].reps[0],
                                    disabled: !_isInProgress,
                                    onSubmitted: (text) async {
                                      ref
                                          .read(savedExercisePlanProvider
                                              .notifier)
                                          .updateRepsForSet(
                                              currentDay, index, set, text);
                                      await ref
                                          .read(completedExercisePlansProvider
                                              .notifier)
                                          .updateCompletedExercisePlanProgressById(
                                              widget.exercisePlan.id,
                                              inProgressPlan);
                                    })),
                            Consumer(builder: ((context, ref, child) {
                              final userPreferences =
                                  ref.watch(userPreferencesProvider);

                              return userPreferences.when(data: (data) {
                                return Expanded(
                                    child: ExerciseListItemTextfield(
                                        text: data.weightMode ==
                                                WeightMode.pounds
                                            ? planExercises[index].weights[set]
                                            : convertWeightToKilograms(
                                                    double.parse(
                                                        planExercises[index]
                                                            .weights[set]))
                                                .toStringAsFixed(2),
                                        helperText:
                                            'Weight ${data.weightMode == WeightMode.pounds ? '(Pounds)' : '(Kilograms)'}',
                                        disabled: !_isInProgress,
                                        onSubmitted: (text) async {
                                          String submittedWeight =
                                              data.weightMode ==
                                                      WeightMode.pounds
                                                  ? text
                                                  : convertWeightToPounds(
                                                          double.parse(text))
                                                      .toStringAsFixed(2);

                                          ref
                                              .read(savedExercisePlanProvider
                                                  .notifier)
                                              .updateWeightForSet(currentDay,
                                                  index, set, submittedWeight);
                                          await ref
                                              .read(
                                                  completedExercisePlansProvider
                                                      .notifier)
                                              .updateCompletedExercisePlanProgressById(
                                                  widget.exercisePlan.id,
                                                  inProgressPlan);
                                        }));
                              }, error: (error, stackTrace) {
                                return Center(child: Text(error.toString()));
                              }, loading: () {
                                return Expanded(
                                    child: ExerciseListItemTextfield(
                                        text: planExercises[index].weights[set],
                                        helperText: 'Weight',
                                        disabled: !_isInProgress,
                                        onSubmitted: (text) async {
                                          ref
                                              .read(savedExercisePlanProvider
                                                  .notifier)
                                              .updateWeightForSet(
                                                  currentDay, index, set, text);
                                          await ref
                                              .read(
                                                  completedExercisePlansProvider
                                                      .notifier)
                                              .updateCompletedExercisePlanProgressById(
                                                  widget.exercisePlan.id,
                                                  inProgressPlan);
                                        }));
                              });
                            }))
                          ]))
                  ])
          ]))
        ]),
        floatingActionButton: FloatingActionButton(
            child: _isInProgress
                ? const Icon(Icons.done)
                : const Icon(Icons.play_arrow_rounded),
            onPressed: () async {
              if (_isInProgress) {
                setState(() {
                  _isInProgress = false;
                });
                await ref
                    .read(completedExercisePlansProvider.notifier)
                    .endCompletedExercisePlanById(widget.exercisePlan.id);
                await workoutRepository.saveWorkoutForExercisePlanById(
                    Workout(day: currentDay, exercises: planExercises),
                    widget.exercisePlan.id);
              } else {
                setState(() {
                  _isInProgress = true;
                });
                await ref
                    .read(completedExercisePlansProvider.notifier)
                    .beginCompletedExercisePlanById(widget.exercisePlan.id);
              }
            }),
      );
    }));
  }
}

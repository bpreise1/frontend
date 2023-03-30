import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/user_exception.dart';
import 'package:frontend/models/user_preferences.dart';
import 'package:frontend/providers/saved_exercise_plan_provider.dart';
import 'package:frontend/providers/user_preferences_provider.dart';
import 'package:frontend/providers/workout_provider.dart';
import 'package:frontend/utils/convert_weight.dart';
import 'package:frontend/utils/validate_saved_plan.dart';
import 'package:frontend/widgets/exercise_list_item.dart';
import 'package:frontend/widgets/exercise_list_item_textfield.dart';

class WorkoutPage extends ConsumerWidget {
  const WorkoutPage(
      {required this.exercisePlanId,
      required this.workoutId,
      required this.weekIndex,
      super.key});

  final String exercisePlanId;
  final String workoutId;
  final int weekIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.read(
      workoutNotifierProvider(exercisePlanId, workoutId, weekIndex),
    );
    final exercises = workout.exercises;

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.day),
      ),
      body: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            key: PageStorageKey<String>('${workout.id}_$index'),
            initiallyExpanded: true,
            title: ExerciseListItem(
              exercise: exercises[index],
            ),
            children: [
              for (int set = 0; set < int.parse(exercises[index].sets); set++)
                ListTile(
                  key: PageStorageKey<String>('${workout.id}_{$index}_$set'),
                  title: Row(
                    children: [
                      Text('Set ${set + 1}'),
                      Expanded(
                        child: ExerciseListItemTextfield(
                          text: exercises[index].reps[set],
                          helperText: 'Reps',
                          hintText: 'Goal: ${exercises[index].goalReps[set]}',
                          submitOnUnfocus: true,
                          disabled: workout.dateCompleted != null,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'\d'),
                            )
                          ],
                          onSubmitted: (text) async {
                            await ref
                                .read(
                                  workoutNotifierProvider(
                                          exercisePlanId, workoutId, weekIndex)
                                      .notifier,
                                )
                                .updateReps(index, set, text);
                          },
                        ),
                      ),
                      Consumer(
                        builder: ((context, ref, child) {
                          final userPreferences =
                              ref.watch(userPreferencesProvider);

                          return userPreferences.when(
                            data: (data) {
                              return Expanded(
                                child: ExerciseListItemTextfield(
                                  text: data.weightMode == WeightMode.pounds
                                      ? exercises[index].weights[set]
                                      : exercises[index].weights[set] == ''
                                          ? ''
                                          : convertWeightToKilograms(
                                              double.parse(
                                                exercises[index].weights[set],
                                              ),
                                            ).toStringAsFixed(2),
                                  helperText:
                                      'Weight ${data.weightMode == WeightMode.pounds ? '(Pounds)' : '(Kilograms)'}',
                                  disabled: workout.dateCompleted != null,
                                  submitOnUnfocus: true,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'\d'),
                                    )
                                  ],
                                  onSubmitted: (text) async {
                                    if (text != '') {
                                      String submittedWeight =
                                          data.weightMode == WeightMode.pounds
                                              ? text
                                              : convertWeightToPounds(
                                                  double.parse(text),
                                                ).toStringAsFixed(2);

                                      await ref
                                          .read(
                                            workoutNotifierProvider(
                                                    exercisePlanId,
                                                    workoutId,
                                                    weekIndex)
                                                .notifier,
                                          )
                                          .updateWeight(
                                              index, set, submittedWeight);
                                    }
                                  },
                                ),
                              );
                            },
                            error: (error, stackTrace) {
                              return Center(child: Text(error.toString()));
                            },
                            loading: () {
                              return Expanded(
                                child: ExerciseListItemTextfield(
                                  text: exercises[index].weights[set],
                                  helperText: 'Weight',
                                  disabled: workout.dateCompleted != null,
                                  onSubmitted: (text) async {},
                                ),
                              );
                            },
                          );
                        }),
                      )
                    ],
                  ),
                )
            ],
          );
        },
      ),
      floatingActionButton: workout.dateCompleted == null
          ? FloatingActionButton(
              onPressed: () {
                UserException? exception = validateWorkout(
                  ref.read(
                    workoutNotifierProvider(
                        exercisePlanId, workoutId, weekIndex),
                  ),
                );

                if (exception != null) {
                  exception.displayException(context);
                } else {
                  ref
                      .read(
                        savedExercisePlanNotifierProvider(exercisePlanId)
                            .notifier,
                      )
                      .completeWorkout(workoutId, weekIndex);

                  Navigator.pop(context);
                }
              },
              child: const Icon(Icons.done),
            )
          : null,
    );
  }
}

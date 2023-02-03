import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
import 'package:frontend/providers/sets_and_reps_editor_provider.dart';
import 'package:frontend/utils/reps_input_formatter.dart';

import 'exercise_list_item.dart';
import 'exercise_list_item_textfield.dart';

class SetsAndRepsEditor extends StatelessWidget {
  const SetsAndRepsEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      observers: [HeroController()],
      pages: const [
        MaterialPage(
          child: SetsAndRepsNotEditing(),
        ),
      ],
      onPopPage: (route, result) => route.didPop(result),
    );
  }
}

class SetsAndRepsEditing extends ConsumerWidget {
  const SetsAndRepsEditing({required this.exerciseIndex, super.key});

  final int exerciseIndex;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String currentDay = ref.watch(createExercisePlanProvider).currentDay;
    List<Exercise>? exercises = ref.watch(createExercisePlanProvider).exercises;

    return ListView(
      children: [
        Hero(
          tag: 'list_item_$exerciseIndex',
          child: ExerciseListItem(
            exercise: exercises![exerciseIndex],
            children: [
              const Spacer(),
              IconButton(
                  onPressed: (() {
                    Navigator.pop(context);
                  }),
                  icon: const Icon(Icons.done)),
            ],
          ),
        ),
        ListTile(
          title: Row(
            children: [
              const Text('Sets'),
              Expanded(
                child: ExerciseListItemTextfield(
                  text: exercises[exerciseIndex].sets,
                  onSubmitted: ((text) {
                    String sets = text == '0' ? '' : text;

                    ref
                        .read(createExercisePlanProvider.notifier)
                        .updateSets(currentDay, exerciseIndex, sets);
                  }),
                  hintText: 'Enter Sets',
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'\d'),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        if (exercises[exerciseIndex].sets != '')
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Divider(),
              ),
              for (int set = 0;
                  set < int.parse(exercises[exerciseIndex].sets);
                  set++)
                ListTile(
                  title: Row(
                    children: [
                      Text('Set ${set + 1}'),
                      Expanded(
                        child: ExerciseListItemTextfield(
                          text: exercises[exerciseIndex].goalReps[set],
                          onSubmitted: ((text) {
                            String reps = text;
                            if (reps == '0') {
                              reps = '';
                            } else if (reps.isNotEmpty &&
                                reps[reps.length - 1] == '-') {
                              reps = reps.substring(0, reps.length - 1);
                            }

                            ref
                                .read(createExercisePlanProvider.notifier)
                                .updateGoalReps(
                                    currentDay, exerciseIndex, set, reps);
                          }),
                          inputFormatters: [
                            RepsInputFormatter(),
                          ],
                          hintText: set == 0
                              ? 'Enter Reps (e.g. 10, 8-12)'
                              : 'Enter Reps',
                        ),
                      ),
                    ],
                  ),
                )
            ],
          )
      ],
    );
  }
}

class SetsAndRepsNotEditing extends ConsumerWidget {
  const SetsAndRepsNotEditing({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Exercise>? exercises = ref.watch(createExercisePlanProvider).exercises;
    String currentDay = ref.watch(createExercisePlanProvider).currentDay;

    return ListView(
      children: [
        for (int index = 0;
            exercises != null && index < exercises.length;
            index++)
          Hero(
            tag: 'list_item_$index',
            flightShuttleBuilder: (flightContext, animation, flightDirection,
                fromHeroContext, toHeroContext) {
              animation.addStatusListener(
                (status) {
                  if (status == AnimationStatus.completed) {
                    ref
                        .read(setsAndRepsEditorProvider.notifier)
                        .setEditing(true);
                  } else if (status == AnimationStatus.dismissed) {
                    ref
                        .read(setsAndRepsEditorProvider.notifier)
                        .setEditing(false);
                  }
                },
              );
              return toHeroContext.widget;
            },
            child: ExerciseListItem(
              imageSize: ImageSize.small,
              exercise: exercises[index],
              children: [
                Expanded(
                    flex: 1,
                    child: ExerciseListItemTextfield(
                        text: exercises[index].sets,
                        disabled: true,
                        onSubmitted: ((text) {
                          ref
                              .read(createExercisePlanProvider.notifier)
                              .updateSets(currentDay, index, text);
                        }),
                        helperText: 'Sets')),
                Expanded(
                    flex: 2,
                    child: ExerciseListItemTextfield(
                        text: exercises[index].sets == ''
                            ? ''
                            : exercises[index]
                                .goalReps
                                .map((rep) => rep == '' ? '_' : rep)
                                .join(' , '),
                        disabled: true,
                        onSubmitted: (text) {},
                        helperText: 'Reps')),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                ),
                IconButton(
                    onPressed: (() {
                      Navigator.of(context).push(PageRouteBuilder(
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      }, pageBuilder:
                              ((context, animation, secondaryAnimation) {
                        return Material(
                          child: SetsAndRepsEditing(
                            exerciseIndex: index,
                          ),
                        );
                      })));
                    }),
                    icon: const Icon(Icons.edit)),
              ],
            ),
          ),
      ],
    );
  }
}

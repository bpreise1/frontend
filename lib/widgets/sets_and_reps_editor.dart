import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';

import 'exercise_list_item.dart';
import 'exercise_list_item_textfield.dart';

class SetsAndRepsEditor extends StatelessWidget {
  const SetsAndRepsEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      observers: [HeroController()],
      pages: const [
        MaterialPage(child: SetsAndRepsNotEditing()),
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
              const Text('Sets '),
              Expanded(
                child: ExerciseListItemTextfield(
                  text: exercises[exerciseIndex].sets,
                  onSubmitted: ((text) {
                    ref
                        .read(createExercisePlanProvider.notifier)
                        .updateSets(currentDay, exerciseIndex, text);
                  }),
                  hintText: 'Enter Sets',
                ),
              ),
            ],
          ),
        ),
        if (exercises[exerciseIndex].sets != '')
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
                        ref
                            .read(createExercisePlanProvider.notifier)
                            .updateGoalReps(
                                currentDay, exerciseIndex, set, text);
                      }),
                      hintText: 'Enter Reps',
                    ),
                  ),
                ],
              ),
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
            child: ExerciseListItem(
              exercise: exercises[index],
              children: [
                Expanded(
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
                    child: ExerciseListItemTextfield(
                        text: exercises[index]
                            .goalReps
                            .map((rep) => rep == '' ? '_' : rep)
                            .join(' , '),
                        disabled: true,
                        onSubmitted: (text) {},
                        helperText: 'Reps')),
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
                        ));
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

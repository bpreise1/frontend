import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise.dart';
import 'package:frontend/providers/create_plan_stepper_provider.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
import 'package:frontend/widgets/day_select_dropdown.dart';
import 'package:frontend/widgets/draggable_exercise_list.dart';
import 'package:frontend/widgets/edit_text.dart';
import 'package:frontend/widgets/exercise_list_item.dart';
import 'package:frontend/widgets/exercise_list_item_textfield.dart';
import 'package:frontend/widgets/submit_plan_dialog.dart';

class NewCreatePlanPage extends ConsumerWidget {
  const NewCreatePlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int selectedStepperIndex = ref.watch(createPlanStepperProvider);

    String currentDay = ref.watch(createExercisePlanProvider).currentDay;
    String planName = ref.watch(createExercisePlanProvider).planName;
    List<Exercise>? exercises = ref.watch(createExercisePlanProvider).exercises;

    return Scaffold(
        body: Column(children: [
          Expanded(
              child: Stepper(
                  onStepTapped: (value) {
                    ref
                        .read(createPlanStepperProvider.notifier)
                        .setCreatePlanStepperIndex(value);
                  },
                  type: StepperType.horizontal,
                  controlsBuilder: (context, details) {
                    return const SizedBox();
                  },
                  steps: [
                Step(
                    title: const Text('Exercises'),
                    state: selectedStepperIndex == 0
                        ? StepState.editing
                        : StepState.indexed,
                    content: const SizedBox.shrink()),
                Step(
                    title: const Text('Sets and Reps'),
                    state: selectedStepperIndex == 1
                        ? StepState.editing
                        : StepState.indexed,
                    content: const SizedBox.shrink()),
              ])),
          Expanded(
              flex: 8,
              child: Stack(children: [
                Row(children: [
                  if (selectedStepperIndex == 0)
                    const Expanded(child: DraggableExerciseList()),
                  Expanded(
                      flex: 2,
                      child: Column(children: [
                        DaySelectDropdown(
                            provider: createExercisePlanProvider,
                            editingEnabled: selectedStepperIndex == 0),
                        Expanded(
                            child: DragTarget<Exercise>(onAccept: (exercise) {
                          ref
                              .read(createExercisePlanProvider.notifier)
                              .addExercise(exercise);
                        }, builder: ((context, candidateData, rejectedData) {
                          return ReorderableListView(
                              buildDefaultDragHandles:
                                  selectedStepperIndex == 0,
                              onReorder: (oldIndex, newIndex) {
                                ref
                                    .read(createExercisePlanProvider.notifier)
                                    .moveExercise(oldIndex, newIndex);
                              },
                              children: [
                                for (int index = 0;
                                    exercises != null &&
                                        index < exercises.length;
                                    index++)
                                  ExerciseListItem(
                                    key: Key('$index'),
                                    exercise: exercises[index],
                                    children: [
                                      if (selectedStepperIndex == 1)
                                        Expanded(
                                            child: ExerciseListItemTextfield(
                                                text: exercises[index].sets,
                                                onSubmitted: ((text) {
                                                  ref
                                                      .read(
                                                          createExercisePlanProvider
                                                              .notifier)
                                                      .updateSets(currentDay,
                                                          index, text);
                                                }),
                                                helperText: 'Sets')),
                                      if (selectedStepperIndex == 1)
                                        Expanded(
                                            child: ExerciseListItemTextfield(
                                                text: exercises[index].reps[0],
                                                onSubmitted: (text) {
                                                  ref
                                                      .read(
                                                          createExercisePlanProvider
                                                              .notifier)
                                                      .updateGoalReps(
                                                          currentDay,
                                                          index,
                                                          text);
                                                },
                                                helperText: 'Reps')),
                                      if (selectedStepperIndex == 0)
                                        IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              ref
                                                  .read(
                                                      createExercisePlanProvider
                                                          .notifier)
                                                  .removeExerciseAt(index);
                                            })
                                    ],
                                  ),
                              ]);
                        })))
                      ]))
                ]),
                Positioned(
                    bottom: 0,
                    left: 0,
                    child: Row(children: [
                      IconButton(
                          onPressed: selectedStepperIndex == 0
                              ? null
                              : () {
                                  ref
                                      .read(createPlanStepperProvider.notifier)
                                      .setCreatePlanStepperIndex(
                                          selectedStepperIndex - 1);
                                },
                          icon: const Icon(Icons.arrow_back)),
                      IconButton(
                          onPressed: selectedStepperIndex == 1
                              ? null
                              : () {
                                  ref
                                      .read(createPlanStepperProvider.notifier)
                                      .setCreatePlanStepperIndex(
                                          selectedStepperIndex + 1);
                                },
                          icon: const Icon(Icons.arrow_forward)),
                      IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: ((context) {
                                  return AlertDialog(
                                      title: Text(
                                          'Are you sure you want to reset $planName?'),
                                      content: Row(
                                        children: [
                                          OutlinedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('No')),
                                          OutlinedButton(
                                              onPressed: () {
                                                ref
                                                    .read(
                                                        createExercisePlanProvider
                                                            .notifier)
                                                    .resetPlan();
                                                ref
                                                    .read(
                                                        createPlanStepperProvider
                                                            .notifier)
                                                    .setCreatePlanStepperIndex(
                                                        0);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Yes'))
                                        ],
                                      ));
                                }));
                          },
                          icon: const Icon(Icons.refresh))
                    ]))
              ]))
        ]),
        floatingActionButton: selectedStepperIndex == 1
            ? FloatingActionButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const SubmitPlanDialog();
                      });
                },
                child: const Icon(Icons.done),
              )
            : null);
  }
}

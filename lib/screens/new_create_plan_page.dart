import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/models/user_exception.dart';
import 'package:frontend/providers/create_plan_stepper_provider.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
import 'package:frontend/widgets/day_select_dropdown.dart';
import 'package:frontend/widgets/draggable_exercise_list.dart';
import 'package:frontend/widgets/sets_and_reps_editor.dart';
import 'package:frontend/widgets/slidable_card.dart';
import 'package:frontend/widgets/submit_plan_dialog.dart';

class NewCreatePlanPage extends ConsumerWidget {
  const NewCreatePlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int selectedStepperIndex = ref.watch(createPlanStepperProvider);

    String planName = ref.watch(createExercisePlanProvider).planName;
    List<Exercise>? exercises = ref.watch(createExercisePlanProvider).exercises;
    InProgressExercisePlan plan =
        ref.watch(createExercisePlanProvider).exercisePlan;

    bool isEditingSetsAndReps = false;
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
                    return const SizedBox.shrink();
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
            child: Stack(
              children: [
                if (selectedStepperIndex == 0) //Exercises
                  Row(children: [
                    const Expanded(child: DraggableExerciseList()),
                    const VerticalDivider(),
                    Expanded(
                        flex: 2,
                        child: Column(children: [
                          DaySelectDropdown(
                              provider: createExercisePlanProvider,
                              editingEnabled: true),
                          Expanded(
                            child: DragTarget<Exercise>(
                              onAccept: (exercise) {
                                ref
                                    .read(createExercisePlanProvider.notifier)
                                    .addExercise(exercise);
                              },
                              builder: ((context, candidateData, rejectedData) {
                                return ReorderableListView(
                                  buildDefaultDragHandles: false,
                                  onReorder: (oldIndex, newIndex) {
                                    ref
                                        .read(
                                            createExercisePlanProvider.notifier)
                                        .moveExercise(oldIndex, newIndex);
                                  },
                                  children: [
                                    for (int index = 0;
                                        exercises != null &&
                                            index < exercises.length;
                                        index++)
                                      SlidableCard(
                                        key: Key(index.toString()),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                                'assets/${exercises[index].name.toLowerCase().replaceAll(' ', '_')}.png',
                                                width: 50,
                                                height: 50),
                                            Text(exercises[index].name),
                                            const Spacer(),
                                            ReorderableDragStartListener(
                                              index: index,
                                              child: const Icon(Icons.menu),
                                            ),
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(right: 8),
                                            ),
                                          ],
                                        ),
                                        onDismiss: () {
                                          ref
                                              .read(createExercisePlanProvider
                                                  .notifier)
                                              .removeExerciseAt(index);
                                        },
                                      ),
                                  ],
                                );
                              }),
                            ),
                          )
                        ])),
                  ]),
                if (selectedStepperIndex == 1) //Sets and Reps
                  StatefulBuilder(
                    builder: ((context, setState) {
                      return Column(
                        children: [
                          DaySelectDropdown(
                              provider: createExercisePlanProvider,
                              editingEnabled: false,
                              disabled: isEditingSetsAndReps),
                          const Expanded(child: SetsAndRepsEditor()),
                        ],
                      );
                    }),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Row(
                    children: [
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
                    ],
                  ),
                )
              ],
            ),
          )
        ]),
        floatingActionButton: selectedStepperIndex == 1
            ? FloatingActionButton(
                onPressed: () {
                  UserException? exception;

                  outerloop:
                  for (var entry in plan.dayToExercisesMap.entries) {
                    if (entry.value.isEmpty) {
                      exception = UserException(
                          message: 'Day "${entry.key}" must not be empty');
                      break outerloop;
                    }

                    for (Exercise exercise in entry.value) {
                      if (exercise.sets == '') {
                        exception = UserException(
                            message:
                                'Sets of "${exercise.name}" must not be empty');
                        break outerloop;
                      }

                      for (String rep in exercise.goalReps) {
                        if (rep == '') {
                          exception = UserException(
                              message:
                                  'Reps of "${exercise.name}" must not be empty');
                          break outerloop;
                        }
                      }
                    }
                  }

                  if (exception != null) {
                    exception.displayException(context);
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const SubmitPlanDialog();
                        });
                  }
                },
                child: const Icon(Icons.done),
              )
            : null);
  }
}

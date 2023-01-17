import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
import 'package:frontend/widgets/day_select_dropdown.dart';
import 'package:frontend/widgets/draggable_exercise_list.dart';
import 'package:frontend/widgets/edit_text.dart';
import 'package:frontend/widgets/exercise_list_item.dart';
import 'package:frontend/widgets/exercise_list_item_textfield.dart';
import 'package:frontend/widgets/submit_plan_dialog.dart';

class CreatePlanPage extends StatefulWidget {
  const CreatePlanPage({super.key});

  @override
  State<CreatePlanPage> createState() => _CreatePlanPageState();
}

class _CreatePlanPageState extends State<CreatePlanPage> {
  bool _showExerciseList = true;

  //TODO: Make multiple consumer widgets so everything doesn't rerender anytime something changes
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: ((context, ref, child) {
      String currentDay = ref.watch(createExercisePlanProvider).currentDay;
      String planName = ref.watch(createExercisePlanProvider).planName;
      List<Exercise>? exercises =
          ref.watch(createExercisePlanProvider).exercises;
      return Scaffold(
          body: Row(
            children: [
              if (_showExerciseList)
                const Expanded(child: DraggableExerciseList()),
              Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      EditText(
                          text: planName,
                          onSubmitted: (text) {
                            ref
                                .read(createExercisePlanProvider.notifier)
                                .changePlanName(text);
                          }),
                      DaySelectDropdown(
                          provider: createExercisePlanProvider,
                          editingEnabled: true),
                      Expanded(
                          child: DragTarget<Exercise>(onAccept: (exercise) {
                        ref
                            .read(createExercisePlanProvider.notifier)
                            .addExercise(exercise);
                      }, builder: ((context, candidateData, rejectedData) {
                        return ReorderableListView(
                            onReorder: (oldIndex, newIndex) {
                              ref
                                  .read(createExercisePlanProvider.notifier)
                                  .moveExercise(oldIndex, newIndex);
                            },
                            children: [
                              for (int index = 0;
                                  exercises != null && index < exercises.length;
                                  index++)
                                ExerciseListItem(
                                  key: Key('$index'),
                                  exercise: exercises[index],
                                  children: [
                                    if (!_showExerciseList)
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
                                    if (!_showExerciseList)
                                      Expanded(
                                          child: ExerciseListItemTextfield(
                                              text: exercises[index].reps[0],
                                              onSubmitted: (text) {
                                                ref
                                                    .read(
                                                        createExercisePlanProvider
                                                            .notifier)
                                                    .updateGoalReps(currentDay,
                                                        index, text);
                                              },
                                              helperText: 'Reps')),
                                    IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          ref
                                              .read(createExercisePlanProvider
                                                  .notifier)
                                              .removeExerciseAt(index);
                                        })
                                  ],
                                ),
                            ]);
                      }))),
                    ],
                  ))
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniStartFloat,
          floatingActionButton: Row(
            children: [
              TextButton(
                  onPressed: () {
                    _showExerciseList
                        ? setState(() {
                            _showExerciseList = false;
                          })
                        : setState(() {
                            _showExerciseList = true;
                          });
                  },
                  child: _showExerciseList
                      ? const Text('Hide Exercise List')
                      : const Text('Show Exercise List')),
              IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const SubmitPlanDialog();
                        });
                  },
                  icon: const Icon(Icons.add)),
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
                                            .read(createExercisePlanProvider
                                                .notifier)
                                            .resetPlan();
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Yes'))
                                ],
                              ));
                        }));
                  },
                  icon: const Icon(Icons.restore))
            ],
          ));
    }));
  }
}

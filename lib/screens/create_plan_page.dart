import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/exercise_plan_provider.dart';
import 'package:frontend/widgets/draggable_exercise_list.dart';
import 'package:frontend/widgets/edit_text.dart';
import 'package:frontend/widgets/exercise_card.dart';

class CreatePlanPage extends StatelessWidget {
  const CreatePlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: DraggableExerciseList()),
        Consumer(builder: ((context, ref, child) {
          String day = ref.watch(exercisePlanProvider).day;
          List<String> allDays = ref.watch(exercisePlanProvider).days;
          print(day);
          List<Exercise>? exercises = ref.watch(exercisePlanProvider).exercises;

          return Expanded(
              child: Column(
            children: [
              EditText(
                  initialText: ref.watch(exercisePlanProvider).planName,
                  onSubmitted: (text) {
                    ref
                        .read(exercisePlanProvider.notifier)
                        .changePlanName(text);
                  }),
              Row(
                children: [
                  Expanded(
                      child: DropdownButton<String>(
                          isExpanded: true,
                          value: day,
                          items: allDays
                              .map((day) => DropdownMenuItem<String>(
                                    value: day,
                                    child: Center(
                                        child: EditText(
                                      initialText: day,
                                      onSubmitted: (text) {
                                        ref
                                            .read(exercisePlanProvider.notifier)
                                            .updateDayName(text);
                                      },
                                    )),
                                  ))
                              .toList(),
                          onChanged: (String? value) {
                            ref
                                .read(exercisePlanProvider.notifier)
                                .selectDay(value!);
                          })),
                  IconButton(
                      onPressed: () {
                        ref
                            .read(exercisePlanProvider.notifier)
                            .addDay('Day ${allDays.length + 1}');
                        print('Clicked');
                      },
                      icon: const Icon(Icons.add_circle)),
                ],
              ),
              Expanded(
                  child: DragTarget<Exercise>(onAccept: (exercise) {
                ref.read(exercisePlanProvider.notifier).addExercise(exercise);
              }, builder: ((context, candidateData, rejectedData) {
                return ReorderableListView(
                    onReorder: (oldIndex, newIndex) {
                      ref
                          .read(exercisePlanProvider.notifier)
                          .moveExercise(oldIndex, newIndex);
                    },
                    children: [
                      for (int i = 0;
                          exercises != null && i < exercises.length;
                          i++)
                        ExerciseCard(
                          key: Key('$i'),
                          exercise: exercises[i],
                          isInsertedInCreatePlanList: true,
                        ),
                    ]);
              })))
            ],
          ));
        }))
      ],
    );
  }
}

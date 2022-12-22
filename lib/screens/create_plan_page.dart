import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/exercise_plan_provider.dart';
import 'package:frontend/widgets/day_select_dropdown.dart';
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
          String planName = ref.watch(exercisePlanProvider).planName;
          List<Exercise>? exercises = ref.watch(exercisePlanProvider).exercises;

          return Expanded(
              child: Column(
            children: [
              EditText(
                  initialText: planName,
                  onSubmitted: (text) {
                    ref
                        .read(exercisePlanProvider.notifier)
                        .changePlanName(text);
                  }),
              const DaySelectDropdown(editingEnabled: true),
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

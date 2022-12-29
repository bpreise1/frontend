import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/exercise_plan_provider.dart';
import 'package:frontend/widgets/day_select_dropdown.dart';
import 'package:frontend/widgets/exercise_list_item.dart';
import 'package:frontend/widgets/exercise_list_item_textfield.dart';

class SavedPlanPage extends ConsumerWidget {
  const SavedPlanPage({required this.exercisePlan, super.key});

  final CompletedExercisePlan exercisePlan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDay = ref.watch(savedExercisePlanProvider).currentDay;
    final currentExercises = ref.watch(savedExercisePlanProvider).exercises!;

    final planName = exercisePlan.planName;
    final planExercises = exercisePlan.dayToExercisesMap[currentDay]!;

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
                                  text: currentExercises[index].reps,
                                  helperText: 'Reps',
                                  hintText: planExercises[index].reps,
                                  onSubmitted: (text) {
                                    ref
                                        .read(
                                            savedExercisePlanProvider.notifier)
                                        .updateReps(currentDay, index, text);
                                  }))
                        ]))
                ])
        ]))
      ]),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.done),
          onPressed: () {
            print('DONE');
          }),
    );
  }
}

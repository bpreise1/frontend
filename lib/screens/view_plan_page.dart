import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/exercise_plan_provider.dart';
import 'package:frontend/widgets/day_select_dropdown.dart';
import 'package:frontend/widgets/exercise_list_item.dart';
import 'package:frontend/widgets/exercise_list_item_textfield.dart';

class ViewPlanPage extends ConsumerWidget {
  const ViewPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDay = ref.watch(savedExercisePlanProvider).currentDay;
    final planName = ref.read(savedExercisePlanProvider).planName;
    final planExercises = ref.watch(savedExercisePlanProvider).exercises!;

    return Scaffold(
      appBar: AppBar(
        title: Text(planName),
      ),
      body: Column(
        children: [
          DaySelectDropdown(provider: savedExercisePlanProvider),
          Expanded(
            child: ListView(
              children: [
                for (int index = 0; index < planExercises.length; index++)
                  ExpansionTile(
                    key: PageStorageKey<String>('${currentDay}_$index'),
                    initiallyExpanded: true,
                    title: ExerciseListItem(
                      exercise: planExercises[index],
                    ),
                    children: [
                      for (int set = 0;
                          set < int.parse(planExercises[index].sets);
                          set++)
                        ListTile(
                          key: PageStorageKey<String>(
                              '${currentDay}_{$index}_$set'),
                          title: Row(
                            children: [
                              Text('Set ${set + 1}'),
                              Expanded(
                                child: ExerciseListItemTextfield(
                                  text: planExercises[index].reps[set],
                                  helperText: 'Reps',
                                  hintText:
                                      'Goal: ${planExercises[index].goalReps[set]}',
                                  disabled: true,
                                  onSubmitted: (text) async {},
                                ),
                              ),
                            ],
                          ),
                        )
                    ],
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}

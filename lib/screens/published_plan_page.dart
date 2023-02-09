import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
import 'package:frontend/providers/published_plan_page_provider.dart';
import 'package:frontend/widgets/day_select_dropdown.dart';
import 'package:frontend/widgets/exercise_list_item.dart';
import 'package:frontend/widgets/exercise_list_item_textfield.dart';
import 'package:frontend/widgets/like_button.dart';

class PublishedPlanPage extends ConsumerWidget {
  const PublishedPlanPage({required this.exercisePlan, super.key});

  final PublishedExercisePlan exercisePlan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(
        publishedPlanPageProvider); //so other widgets can tell it to update

    final currentExercises =
        ref.watch(publishedExercisePlanProvider).exercises!;

    int likes = exercisePlan.likedBy.length;
    List<Comment> comments = exercisePlan.comments;

    return Scaffold(
      appBar: AppBar(
        title: Text(exercisePlan.planName),
      ),
      body: ListView(
        children: [
          DaySelectDropdown(provider: publishedExercisePlanProvider),
          for (int index = 0; index < currentExercises.length; index++)
            ExpansionTile(
              title: ExerciseListItem(
                exercise: currentExercises[index],
                children: [
                  Expanded(
                      flex: 1,
                      child: ExerciseListItemTextfield(
                          text: currentExercises[index].sets,
                          disabled: true,
                          onSubmitted: (text) {},
                          helperText: 'Sets')),
                  Expanded(
                      flex: 2,
                      child: ExerciseListItemTextfield(
                          text: currentExercises[index]
                              .goalReps
                              .map((rep) => rep == '' ? '_' : rep)
                              .join(' , '),
                          disabled: true,
                          onSubmitted: (text) {},
                          helperText: 'Reps')),
                ],
              ),
              children: [
                for (int set = 0;
                    set < int.parse(currentExercises[index].sets);
                    set++)
                  ListTile(
                    title: Row(
                      children: [
                        Text('Set ${set + 1}'),
                        Expanded(
                          child: ExerciseListItemTextfield(
                            text: currentExercises[index].goalReps[set],
                            disabled: true,
                            onSubmitted: (text) {},
                            helperText: 'Reps',
                          ),
                        ),
                      ],
                    ),
                  )
              ],
            ),
          if (exercisePlan.description != '')
            Column(
              children: [
                Text(exercisePlan.description),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                )
              ],
            ),
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LikeButton(exercisePlan: exercisePlan),
                    Text(
                      likes.toString(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.comment),
                    ),
                    Text(
                      comments.length.toString(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
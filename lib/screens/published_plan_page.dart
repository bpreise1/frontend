import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
import 'package:frontend/providers/published_exercise_plan_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/widgets/add_comment_section.dart';
import 'package:frontend/widgets/day_select_dropdown.dart';
import 'package:frontend/widgets/exercise_list_item.dart';
import 'package:frontend/widgets/exercise_list_item_textfield.dart';
import 'package:frontend/widgets/like_button.dart';
import 'package:frontend/widgets/comment_section.dart';

class PublishedPlanPage extends StatelessWidget {
  const PublishedPlanPage(
      {required this.planCreatorId,
      required this.planId,
      this.autofocusCommentSection = false,
      super.key});

  final String planCreatorId;
  final String planId;
  final bool autofocusCommentSection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, child) {
            return Text(ref
                .watch(
                  publishedExercisePlanNotifierProvider(planCreatorId, planId),
                )
                .planName);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final currentExercises =
                        ref.watch(publishedExercisePlanProvider).exercises!;

                    return Column(
                      children: [
                        DaySelectDropdown(
                            provider: publishedExercisePlanProvider),
                        for (int index = 0;
                            index < currentExercises.length;
                            index++)
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
                                          text: currentExercises[index]
                                              .goalReps[set],
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
                      ],
                    );
                  },
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final plan = ref.watch(
                      publishedExercisePlanNotifierProvider(
                          planCreatorId, planId),
                    );

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LikeButton(
                                    isLiked: plan.likedBy.contains(
                                      userRepository.getCurrentUserId(),
                                    ),
                                    onLikeClicked: () async {
                                      await ref
                                          .read(
                                            publishedExercisePlanNotifierProvider(
                                                    planCreatorId, planId)
                                                .notifier,
                                          )
                                          .likePlan();
                                    },
                                    onUnlikeClicked: () async {
                                      await ref
                                          .read(
                                            publishedExercisePlanNotifierProvider(
                                                    planCreatorId, planId)
                                                .notifier,
                                          )
                                          .unlikePlan();
                                    },
                                  ),
                                  Text(
                                    plan.likedBy.length.toString(),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    disabledColor:
                                        Theme.of(context).iconTheme.color,
                                    onPressed: null,
                                    icon: const Icon(Icons.comment),
                                  ),
                                  Text(
                                    plan.totalComments.toString(),
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
                        if (plan.description != '')
                          Column(
                            children: [
                              Text(plan.description),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                              )
                            ],
                          ),
                        const Divider(),
                        CommentSection(
                          type: ContentType.exercisePlan,
                          contentCreatorId: plan.creatorUserId,
                          contentId: plan.id,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              return AddCommentSection(
                hintText: 'Add a comment...',
                onSubmitted: (comment) {
                  ref
                      .read(
                        publishedExercisePlanNotifierProvider(
                                planCreatorId, planId)
                            .notifier,
                      )
                      .addComment(comment);
                },
                autofocus: autofocusCommentSection,
              );
            },
          ),
        ],
      ),
    );
  }
}

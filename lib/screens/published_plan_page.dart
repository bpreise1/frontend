import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/current_user_provider.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
import 'package:frontend/providers/profile_page_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/widgets/add_comment_section.dart';
import 'package:frontend/widgets/comment_section.dart';
import 'package:frontend/widgets/day_select_dropdown.dart';
import 'package:frontend/widgets/exercise_list_item.dart';
import 'package:frontend/widgets/exercise_list_item_textfield.dart';
import 'package:frontend/widgets/like_button.dart';
import 'package:uuid/uuid.dart';

class PublishedPlanPage extends ConsumerWidget {
  const PublishedPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PublishedExercisePlan exercisePlan = ref
        .watch(publishedExercisePlanProvider)
        .exercisePlan as PublishedExercisePlan;

    final currentExercises =
        ref.watch(publishedExercisePlanProvider).exercises!;

    int likes = exercisePlan.likedBy.length;
    List<Comment> comments = exercisePlan.comments;

    return Scaffold(
      appBar: AppBar(
        title: Text(exercisePlan.planName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
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
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LikeButton(
                            isLiked: exercisePlan.likedBy.contains(
                              userRepository.getCurrentUserId(),
                            ),
                            onLikeClicked: () async {
                              await ref
                                  .read(profilePageProvider.notifier)
                                  .likeExercisePlan(exercisePlan.id);
                            },
                            onUnlikeClicked: () async {
                              await ref
                                  .read(profilePageProvider.notifier)
                                  .unlikeExercisePlan(exercisePlan.id);
                            },
                          ),
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
                            exercisePlan.totalComments.toString(),
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
                if (exercisePlan.description != '')
                  Column(
                    children: [
                      Text(exercisePlan.description),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                      )
                    ],
                  ),
                const Divider(),
                CommentSection(
                  comments: comments,
                  onReply: (reply, replyingTo) {
                    ref
                        .read(profilePageProvider.notifier)
                        .replyToCommentForExercisePlan(
                            exercisePlan.id, replyingTo.id, reply);
                  },
                  onLikeComment: (likedComment) async {
                    await ref
                        .read(profilePageProvider.notifier)
                        .likeCommentForExercisePlan(
                          exercisePlan.id,
                          userRepository.getCurrentUserId(),
                          likedComment.id,
                        );
                  },
                  onUnlikeComment: (unlikedComment) async {
                    await ref
                        .read(profilePageProvider.notifier)
                        .unlikeCommentForExercisePlan(
                          exercisePlan.id,
                          userRepository.getCurrentUserId(),
                          unlikedComment.id,
                        );
                  },
                ),
              ],
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final currentUser = ref.watch(currentUserProvider);

              return currentUser.when(
                data: (data) {
                  return AddCommentSection(
                    hintText: 'Add a comment...',
                    onSubmitted: (text) {
                      Comment comment = Comment(
                        id: const Uuid().v4(),
                        comment: text,
                        creatorUserId: userRepository.getCurrentUserId(),
                        creatorUsername: data.username,
                        dateCreated: DateTime.now(),
                        likedBy: [],
                        replies: [],
                      );

                      ref
                          .read(profilePageProvider.notifier)
                          .addCommentForExercisePlan(exercisePlan.id, comment);
                    },
                  );
                },
                error: (error, stackTrace) {
                  return Text(
                    error.toString(),
                  );
                },
                loading: () {
                  return CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

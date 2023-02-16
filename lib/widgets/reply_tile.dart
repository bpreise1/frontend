import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/providers/profile_page_provider.dart';
import 'package:frontend/providers/published_plan_page_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/widgets/like_button.dart';

class ReplyTile extends ConsumerWidget {
  const ReplyTile(
      {required this.comment, required this.exercisePlanId, super.key});

  final Comment comment;
  final String exercisePlanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int likes = comment.likedBy.length;

    return Column(
      children: [
        const Divider(
          height: .5,
        ),
        Container(
          decoration: const BoxDecoration(
              border: Border.symmetric(horizontal: BorderSide())),
          child: ListTile(
            tileColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.only(left: 32, top: 4, bottom: 4),
            title: Text(comment.comment),
            subtitle: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LikeButton(
                        isLiked: comment.likedBy.contains(
                          userRepository.getCurrentUserId(),
                        ),
                        onLikeClicked: () async {
                          await ref
                              .read(profilePageProvider.notifier)
                              .likeCommentForExercisePlan(
                                  exercisePlanId,
                                  userRepository.getCurrentUserId(),
                                  comment.id);

                          ref.read(publishedPlanPageProvider.notifier).update();
                        },
                        onUnlikeClicked: () async {
                          await ref
                              .read(profilePageProvider.notifier)
                              .unlikeCommentForExercisePlan(
                                  exercisePlanId,
                                  userRepository.getCurrentUserId(),
                                  comment.id);

                          ref.read(publishedPlanPageProvider.notifier).update();
                        },
                      ),
                      Text(
                        likes.toString(),
                      )
                    ],
                  ),
                ),
                const Spacer(
                  flex: 2,
                ),
              ],
            ),
          ),
        ),
        const Divider(
          height: .5,
        ),
      ],
    );
  }
}

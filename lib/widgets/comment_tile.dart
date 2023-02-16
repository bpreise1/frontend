import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/providers/profile_page_provider.dart';
import 'package:frontend/providers/published_plan_page_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/screens/reply_page.dart';
import 'package:frontend/widgets/like_button.dart';

class CommentTile extends ConsumerWidget {
  const CommentTile(
      {required this.comment,
      required this.exercisePlanId,
      this.repliesEnabled = true,
      super.key});

  final Comment comment;
  final String exercisePlanId;
  final bool repliesEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int likes = comment.likedBy.length;
    List<Comment> replies = comment.replies;

    return Column(
      children: [
        const Divider(
          height: .5,
        ),
        ListTile(
          contentPadding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
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
                            .likeCommentForExercisePlan(exercisePlanId,
                                userRepository.getCurrentUserId(), comment.id);

                        ref.read(publishedPlanPageProvider.notifier).update();
                      },
                      onUnlikeClicked: () async {
                        await ref
                            .read(profilePageProvider.notifier)
                            .unlikeCommentForExercisePlan(exercisePlanId,
                                userRepository.getCurrentUserId(), comment.id);

                        ref.read(publishedPlanPageProvider.notifier).update();
                      },
                    ),
                    Text(
                      likes.toString(),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      disabledColor: Theme.of(context).iconTheme.color,
                      onPressed: repliesEnabled
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ReplyPage(
                                      comment: comment,
                                      exercisePlanId: exercisePlanId,
                                    );
                                  },
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.comment),
                    ),
                    Text(
                      replies.length.toString(),
                    )
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        const Divider(
          height: .5,
        ),
      ],
    );
  }
}

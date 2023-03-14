import 'package:flutter/material.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/utils/time_ago.dart';
import 'package:frontend/widgets/like_button.dart';

class ReplyTile extends StatelessWidget {
  const ReplyTile(
      {required this.comment,
      required this.onLikeComment,
      required this.onUnlikeComment,
      super.key});

  final Comment comment;
  final Future<void> Function(Comment likedComment) onLikeComment;
  final Future<void> Function(Comment unlikedComment) onUnlikeComment;

  @override
  Widget build(BuildContext context) {
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
            contentPadding:
                const EdgeInsets.only(left: 32, top: 4, bottom: 4, right: 8),
            title: Row(
              children: [
                Text(comment.comment),
                const Spacer(),
                Text(
                  timeAgo(comment.dateCreated),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LikeButton(
                        key: Key(comment.id),
                        isLiked: comment.likedBy.contains(
                          userRepository.getCurrentUserId(),
                        ),
                        onLikeClicked: () async {
                          await onLikeComment(comment);
                        },
                        onUnlikeClicked: () async {
                          await onUnlikeComment(comment);
                        },
                      ),
                      Text(
                        comment.likedBy.length.toString(),
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

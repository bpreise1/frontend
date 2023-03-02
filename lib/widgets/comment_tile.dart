import 'package:flutter/material.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/screens/reply_page.dart';
import 'package:frontend/widgets/like_button.dart';

class CommentTile extends StatelessWidget {
  const CommentTile(
      {required this.comment,
      required this.onLikeComment,
      required this.onUnlikeComment,
      this.onReply,
      super.key});

  final Comment comment;
  final void Function(Comment comment, Comment replyTo)? onReply;
  final Future<void> Function(Comment likedComment) onLikeComment;
  final Future<void> Function(Comment unlikedComment) onUnlikeComment;

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      disabledColor: Theme.of(context).iconTheme.color,
                      onPressed: onReply != null
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ReplyPage(
                                        comment: comment,
                                        onReply: onReply!,
                                        onLikeComment: onLikeComment,
                                        onUnlikeComment: onUnlikeComment);
                                  },
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.comment),
                    ),
                    Text(
                      comment.replies.length.toString(),
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

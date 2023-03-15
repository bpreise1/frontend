import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/screens/profile_page.dart';
import 'package:frontend/screens/reply_page.dart';
import 'package:frontend/utils/time_ago.dart';
import 'package:frontend/widgets/like_button.dart';
import 'package:frontend/widgets/comment_section.dart';
import 'package:frontend/widgets/slidable_comment_tile.dart';

class CommentTile extends StatelessWidget {
  const CommentTile(
      {required this.comment,
      required this.type,
      required this.contentCreatorId,
      required this.contentId,
      required this.onLikeComment,
      required this.onUnlikeComment,
      this.onDelete,
      this.onReply,
      super.key});

  final Comment comment;
  final ContentType type;
  final String contentCreatorId;
  final String contentId;
  final void Function(Comment comment, Comment replyTo)? onReply;
  final Future<void> Function(Comment likedComment) onLikeComment;
  final Future<void> Function(Comment unlikedComment) onUnlikeComment;
  final Future<void> Function(Comment comment)? onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
          height: .5,
        ),
        SlidableCommentTile(
          key: UniqueKey(),
          comment: comment,
          onDelete: onDelete,
          child: ListTile(
            isThreeLine: true,
            contentPadding:
                const EdgeInsets.only(left: 16, top: 4, bottom: 4, right: 8),
            title: Row(
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    return TextButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.resolveWith(
                            (_) => EdgeInsets.zero),
                      ),
                      onPressed: () async {
                        final commenterProfilePicture = !ref.exists(
                          userNotifierProvider(comment.creatorUserId),
                        )
                            ? await userRepository
                                .getProfilePictureById(comment.creatorUserId)
                            : null;

                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ProfilePage(
                                    id: comment.creatorUserId,
                                    username: comment.creatorUsername,
                                    profilePicture: commenterProfilePicture);
                              },
                            ),
                          );
                        }
                      },
                      child: Text(
                        comment.creatorUsername,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    );
                  },
                ),
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
            subtitle: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 2,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      comment.comment,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LikeButton(
                            key: UniqueKey(),
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
                                              commentId: comment.id,
                                              type: type,
                                              contentCreatorId:
                                                  contentCreatorId,
                                              contentId: contentId,
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

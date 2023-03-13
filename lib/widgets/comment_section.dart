import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/providers/progress_picture_provider.dart';
import 'package:frontend/providers/published_exercise_plan_provider.dart';
import 'package:frontend/widgets/comment_tile.dart';
import 'package:frontend/widgets/reply_tile.dart';

enum ContentType {
  exercisePlan,
  progressPicture,
}

class CommentSection extends ConsumerWidget {
  const CommentSection(
      {required this.type,
      required this.contentCreatorId,
      required this.contentId,
      super.key});

  final ContentType type;
  final String contentCreatorId;
  final String contentId;

  List<Widget> _getCommentTiles(
      {required List<Comment> comments,
      required void Function(Comment comment, Comment replyTo) onReply,
      required Future<void> Function(Comment likedComment) onLikeComment,
      required Future<void> Function(Comment unlikedComment) onUnlikeComment}) {
    List<Widget> tiles = [];

    for (final comment in comments) {
      tiles.add(
        CommentTile(
          comment: comment,
          type: type,
          contentCreatorId: contentCreatorId,
          contentId: contentId,
          onReply: onReply,
          onLikeComment: onLikeComment,
          onUnlikeComment: onUnlikeComment,
        ),
      );
      for (final reply in comment.replies) {
        tiles.add(
          ReplyTile(
              comment: reply,
              onLikeComment: onLikeComment,
              onUnlikeComment: onUnlikeComment),
        );
      }
    }
    return tiles;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Comment> comments = type == ContentType.exercisePlan
        ? ref
            .watch(
              publishedExercisePlanNotifierProvider(
                  contentCreatorId, contentId),
            )
            .comments
        : ref
            .watch(
              progressPictureNotifierProvider(contentCreatorId, contentId),
            )
            .comments;

    void Function(Comment comment, Comment replyTo) onReply = type ==
            ContentType.exercisePlan
        ? (comment, replyTo) {
            ref
                .read(
                  publishedExercisePlanNotifierProvider(
                          contentCreatorId, contentId)
                      .notifier,
                )
                .replyToComment(replyTo.id, comment);
          }
        : (comment, replyTo) {
            ref
                .read(
                  progressPictureNotifierProvider(contentCreatorId, contentId)
                      .notifier,
                )
                .replyToComment(replyTo.id, comment);
          };

    Future<void> Function(Comment likedComment) onLikeComment = type ==
            ContentType.exercisePlan
        ? (likedComment) async {
            await ref
                .read(
                  publishedExercisePlanNotifierProvider(
                          contentCreatorId, contentId)
                      .notifier,
                )
                .likeComment(likedComment.id);
          }
        : (likedComment) async {
            await ref
                .read(
                  progressPictureNotifierProvider(contentCreatorId, contentId)
                      .notifier,
                )
                .likeComment(likedComment.id);
          };

    Future<void> Function(Comment likedComment) onUnlikeComment = type ==
            ContentType.exercisePlan
        ? (likedComment) async {
            await ref
                .read(
                  publishedExercisePlanNotifierProvider(
                          contentCreatorId, contentId)
                      .notifier,
                )
                .unlikeComment(likedComment.id);
          }
        : (likedComment) async {
            await ref
                .read(
                  progressPictureNotifierProvider(contentCreatorId, contentId)
                      .notifier,
                )
                .unlikeComment(likedComment.id);
          };

    final List<Widget> commentTiles = _getCommentTiles(
        comments: comments,
        onReply: onReply,
        onLikeComment: onLikeComment,
        onUnlikeComment: onUnlikeComment);

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8, left: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Comments',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        ...commentTiles,
      ],
    );
  }
}

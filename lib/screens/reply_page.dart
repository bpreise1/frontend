import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/providers/progress_picture_provider.dart';
import 'package:frontend/providers/published_exercise_plan_provider.dart';
import 'package:frontend/widgets/add_comment_section.dart';
import 'package:frontend/widgets/comment_section.dart';
import 'package:frontend/widgets/comment_tile.dart';
import 'package:frontend/widgets/reply_tile.dart';

class ReplyPage extends ConsumerWidget {
  const ReplyPage(
      {required this.commentId,
      required this.type,
      required this.contentCreatorId,
      required this.contentId,
      required this.onReply,
      required this.onLikeComment,
      required this.onUnlikeComment,
      super.key});

  final String commentId;
  final ContentType type;
  final String contentCreatorId;
  final String contentId;
  final void Function(Comment comment, Comment replyTo) onReply;
  final Future<void> Function(Comment likedComment) onLikeComment;
  final Future<void> Function(Comment unlikedComment) onUnlikeComment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comment = type == ContentType.exercisePlan
        ? ref
            .watch(
              publishedExercisePlanNotifierProvider(
                  contentCreatorId, contentId),
            )
            .comments
            .firstWhere((comment) => comment.id == commentId)
        : ref
            .watch(
              progressPictureNotifierProvider(contentCreatorId, contentId),
            )
            .comments
            .firstWhere((comment) => comment.id == commentId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Replies'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                CommentTile(
                    comment: comment,
                    type: type,
                    contentCreatorId: contentCreatorId,
                    contentId: contentId,
                    onLikeComment: onLikeComment,
                    onUnlikeComment: onUnlikeComment),
                for (final reply in comment.replies)
                  ReplyTile(
                      comment: reply,
                      onLikeComment: onLikeComment,
                      onUnlikeComment: onUnlikeComment),
              ],
            ),
          ),
          AddCommentSection(
            hintText: 'Add a reply...',
            onSubmitted: (reply) {
              onReply(reply, comment);
            },
          ),
        ],
      ),
    );
  }
}

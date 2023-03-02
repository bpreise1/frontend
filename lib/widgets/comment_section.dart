import 'package:flutter/material.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/widgets/comment_tile.dart';
import 'package:frontend/widgets/reply_tile.dart';

class CommentSection extends StatelessWidget {
  const CommentSection(
      {required this.comments,
      required this.onLikeComment,
      required this.onUnlikeComment,
      this.onReply,
      super.key});

  final List<Comment> comments;
  final void Function(Comment comment, Comment replyTo)? onReply;
  final Future<void> Function(Comment likedComment) onLikeComment;
  final Future<void> Function(Comment unlikedComment) onUnlikeComment;

  List<Widget> _getCommentTiles() {
    List<Widget> tiles = [];

    for (final comment in comments) {
      tiles.add(
        CommentTile(
          comment: comment,
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (onReply != null)
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
        ..._getCommentTiles(),
      ],
    );
  }
}

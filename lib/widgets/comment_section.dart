import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/providers/progress_picture_provider.dart';
import 'package:frontend/providers/published_exercise_plan_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/widgets/comment_tile.dart';
import 'package:frontend/widgets/reply_tile.dart';
import 'package:frontend/widgets/sort_dropdown.dart';

enum ContentType {
  exercisePlan,
  progressPicture,
}

class CommentSection extends StatefulWidget {
  const CommentSection(
      {required this.type,
      required this.contentCreatorId,
      required this.contentId,
      super.key});

  final ContentType type;
  final String contentCreatorId;
  final String contentId;

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  SortByOptions _sortBy = SortByOptions.mostLiked;

  List<Widget> _getCommentTiles({
    required List<Comment> comments,
    required void Function(Comment comment, Comment replyTo) onReply,
    required Future<void> Function(Comment likedComment) onLikeComment,
    required Future<void> Function(Comment unlikedComment) onUnlikeComment,
    required Future<void> Function(Comment unlikedComment) onDelete,
  }) {
    List<Widget> tiles = [];

    int sortByMostRecent(Comment comment1, Comment comment2) {
      return comment2.dateCreated.compareTo(comment1.dateCreated);
    }

    int sortByMostLiked(Comment comment1, Comment comment2) {
      if (comment1.likedBy.length < comment2.likedBy.length) {
        return 1;
      } else if (comment1.likedBy.length > comment2.likedBy.length) {
        return -1;
      }
      return 0;
    }

    comments.sort(_sortBy == SortByOptions.mostLiked
        ? sortByMostLiked
        : sortByMostRecent);

    for (final comment in comments) {
      tiles.add(
        CommentTile(
          key: UniqueKey(),
          comment: comment,
          type: widget.type,
          contentCreatorId: widget.contentCreatorId,
          contentId: widget.contentId,
          onReply: onReply,
          onLikeComment: onLikeComment,
          onUnlikeComment: onUnlikeComment,
          onDelete: comment.creatorUserId ==
                      userRepository.getCurrentUserId() ||
                  widget.contentCreatorId == userRepository.getCurrentUserId()
              ? onDelete
              : null,
        ),
      );
      for (final reply in comment.replies) {
        tiles.add(
          ReplyTile(
            key: UniqueKey(),
            comment: reply,
            onLikeComment: onLikeComment,
            onUnlikeComment: onUnlikeComment,
            onDelete: reply.creatorUserId ==
                        userRepository.getCurrentUserId() ||
                    widget.contentCreatorId == userRepository.getCurrentUserId()
                ? onDelete
                : null,
          ),
        );
      }
    }
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final List<Comment> comments = widget.type == ContentType.exercisePlan
            ? ref
                .watch(
                  publishedExercisePlanNotifierProvider(
                      widget.contentCreatorId, widget.contentId),
                )
                .comments
            : ref
                .watch(
                  progressPictureNotifierProvider(
                      widget.contentCreatorId, widget.contentId),
                )
                .comments;

        void Function(Comment comment, Comment replyTo) onReply =
            widget.type == ContentType.exercisePlan
                ? (comment, replyTo) {
                    ref
                        .read(
                          publishedExercisePlanNotifierProvider(
                                  widget.contentCreatorId, widget.contentId)
                              .notifier,
                        )
                        .replyToComment(replyTo.id, comment);
                  }
                : (comment, replyTo) {
                    ref
                        .read(
                          progressPictureNotifierProvider(
                                  widget.contentCreatorId, widget.contentId)
                              .notifier,
                        )
                        .replyToComment(replyTo.id, comment);
                  };

        Future<void> Function(Comment likedComment) onLikeComment =
            widget.type == ContentType.exercisePlan
                ? (likedComment) async {
                    await ref
                        .read(
                          publishedExercisePlanNotifierProvider(
                                  widget.contentCreatorId, widget.contentId)
                              .notifier,
                        )
                        .likeComment(likedComment.id);
                  }
                : (likedComment) async {
                    await ref
                        .read(
                          progressPictureNotifierProvider(
                                  widget.contentCreatorId, widget.contentId)
                              .notifier,
                        )
                        .likeComment(likedComment.id);
                  };

        Future<void> Function(Comment likedComment) onUnlikeComment =
            widget.type == ContentType.exercisePlan
                ? (likedComment) async {
                    await ref
                        .read(
                          publishedExercisePlanNotifierProvider(
                                  widget.contentCreatorId, widget.contentId)
                              .notifier,
                        )
                        .unlikeComment(likedComment.id);
                  }
                : (likedComment) async {
                    await ref
                        .read(
                          progressPictureNotifierProvider(
                                  widget.contentCreatorId, widget.contentId)
                              .notifier,
                        )
                        .unlikeComment(likedComment.id);
                  };

        Future<void> Function(Comment comment) onDelete =
            widget.type == ContentType.exercisePlan
                ? (comment) async {
                    await ref
                        .read(
                          publishedExercisePlanNotifierProvider(
                                  widget.contentCreatorId, widget.contentId)
                              .notifier,
                        )
                        .deleteComment(comment);
                  }
                : (comment) async {
                    await ref
                        .read(
                          progressPictureNotifierProvider(
                                  widget.contentCreatorId, widget.contentId)
                              .notifier,
                        )
                        .deleteComment(comment);
                  };

        final List<Widget> commentTiles = _getCommentTiles(
          comments: [...comments],
          onReply: onReply,
          onLikeComment: onLikeComment,
          onUnlikeComment: onUnlikeComment,
          onDelete: onDelete,
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Text(
                      'Comments',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    SortDropdown(
                      value: _sortBy,
                      onMostLikedSelected: () {
                        setState(
                          () {
                            _sortBy = SortByOptions.mostLiked;
                          },
                        );
                      },
                      onMostRecentSelected: () {
                        setState(() {
                          _sortBy = SortByOptions.mostRecent;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            ...commentTiles,
          ],
        );
      },
    );
  }
}

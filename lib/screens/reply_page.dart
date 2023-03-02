import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/providers/current_user_provider.dart';
import 'package:frontend/providers/profile_page_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/widgets/add_comment_section.dart';
import 'package:frontend/widgets/comment_section.dart';
import 'package:uuid/uuid.dart';

class ReplyPage extends StatelessWidget {
  const ReplyPage(
      {required this.comment,
      required this.onReply,
      required this.onLikeComment,
      required this.onUnlikeComment,
      super.key});

  final Comment comment;
  final void Function(Comment comment, Comment replyTo) onReply;
  final Future<void> Function(Comment likedComment) onLikeComment;
  final Future<void> Function(Comment unlikedComment) onUnlikeComment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Replies'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    ref.watch(profilePageProvider); //Need this so page rebuilds

                    return CommentSection(
                      comments: [comment],
                      onLikeComment: onLikeComment,
                      onUnlikeComment: onUnlikeComment,
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
                    hintText: 'Add a reply...',
                    onSubmitted: (text) {
                      Comment reply = Comment(
                        id: const Uuid().v4(),
                        comment: text,
                        creatorUserId: userRepository.getCurrentUserId(),
                        creatorUsername: data.username,
                        dateCreated: DateTime.now(),
                        likedBy: [],
                        replies: [],
                      );

                      onReply(reply, comment);
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

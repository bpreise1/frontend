import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/providers/profile_page_provider.dart';
import 'package:frontend/widgets/add_comment_section.dart';
import 'package:frontend/widgets/comment_tile.dart';
import 'package:frontend/widgets/reply_tile.dart';

class ReplyPage extends ConsumerWidget {
  const ReplyPage(
      {required this.comment, required this.exercisePlanId, super.key});

  final Comment comment;
  final String exercisePlanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Comment> replies = comment.replies;

    return Consumer(
      builder: (context, ref, child) {
        ref.watch(profilePageProvider);

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
                      exercisePlanId: exercisePlanId,
                      repliesEnabled: false,
                    ),
                    for (int i = 0; i < replies.length; i++)
                      ReplyTile(
                          comment: replies[i], exercisePlanId: exercisePlanId),
                  ],
                ),
              ),
              AddCommentSection(
                exercisePlanId: exercisePlanId,
                replyTo: comment,
              ),
            ],
          ),
        );
      },
    );
  }
}

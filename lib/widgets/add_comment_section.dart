import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/current_user_provider.dart';
import 'package:frontend/providers/profile_page_provider.dart';
import 'package:frontend/providers/published_plan_page_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:uuid/uuid.dart';

class AddCommentSection extends StatefulWidget {
  const AddCommentSection({required this.exercisePlan, super.key});

  final PublishedExercisePlan exercisePlan;

  @override
  State<AddCommentSection> createState() => _AddCommentSectionState();
}

class _AddCommentSectionState extends State<AddCommentSection> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        border: Border(
          top: BorderSide(width: 2, color: Theme.of(context).dividerColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          const Divider(),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Add a comment...',
              ),
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final currentUser = ref.watch(currentUserProvider);
              return TextButton(
                onPressed: () async {
                  currentUser.when(
                    data: (data) async {
                      ref
                          .read(profilePageProvider.notifier)
                          .addCommentForExercisePlan(
                            widget.exercisePlan.id,
                            Comment(
                                id: const Uuid().v4(),
                                comment: _textController.text,
                                creatorUserId:
                                    userRepository.getCurrentUserId(),
                                creatorUsername: data.username,
                                dateCreated: DateTime.now(),
                                likedBy: [],
                                replies: []),
                          );

                      _textController.text = '';

                      ref.read(publishedPlanPageProvider.notifier).update();
                    },
                    error: (error, stackTrace) {
                      throw Exception(
                          'Something went wrong when adding a comment');
                    },
                    loading: () {},
                  );
                },
                child: Text(
                  'Post',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

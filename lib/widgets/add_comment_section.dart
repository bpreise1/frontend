import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/providers/current_user_provider.dart';
import 'package:uuid/uuid.dart';

class AddCommentSection extends StatefulWidget {
  const AddCommentSection(
      {required this.hintText, required this.onSubmitted, super.key});

  final String hintText;
  final void Function(Comment comment) onSubmitted;

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
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          const Divider(),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration.collapsed(
                hintText: widget.hintText,
              ),
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final currentUser = ref.watch(currentUserProvider);

              return currentUser.when(
                data: (data) {
                  return ValueListenableBuilder(
                    valueListenable: _textController,
                    builder: (context, value, child) {
                      return ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (states) {
                              if (states.contains(MaterialState.disabled)) {
                                return Theme.of(context).disabledColor;
                              }
                              return Theme.of(context).colorScheme.secondary;
                            },
                          ),
                        ),
                        onPressed: value.text.isNotEmpty
                            ? () {
                                widget.onSubmitted(
                                  Comment(
                                      id: const Uuid().v4(),
                                      comment: value.text,
                                      creatorUserId: data.id,
                                      creatorUsername: data.username,
                                      dateCreated: DateTime.now(),
                                      likedBy: [],
                                      replies: []),
                                );
                                _textController.text = '';
                              }
                            : null,
                        child: Text(
                          'Post',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onBackground),
                        ),
                      );
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

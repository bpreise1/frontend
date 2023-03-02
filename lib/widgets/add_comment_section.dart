import 'package:flutter/material.dart';

class AddCommentSection extends StatefulWidget {
  const AddCommentSection(
      {required this.hintText, required this.onSubmitted, super.key});

  final String hintText;
  final void Function(String text) onSubmitted;

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
              decoration: InputDecoration.collapsed(
                hintText: widget.hintText,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              widget.onSubmitted(_textController.text);
              _textController.text = '';
            },
            child: Text(
              'Post',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class EditText extends StatefulWidget {
  const EditText({this.text = '', required this.onSubmitted, super.key});

  final String text;
  final void Function(String text) onSubmitted;

  @override
  State<EditText> createState() => _EditTextState();
}

class _EditTextState extends State<EditText> {
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String text = widget.text;
    return Row(children: [
      Expanded(
          child: _isEditing
              ? TextField(
                  textAlign: TextAlign.center,
                  controller: _textController..text = text,
                  autofocus: true,
                  focusNode: _focusNode,
                  onSubmitted: (text) {
                    setState(() {
                      _isEditing = false;
                      widget.onSubmitted(text);
                    });
                  },
                )
              : Text(
                  text,
                  textAlign: TextAlign.center,
                )),
      IconButton(
          onPressed: () {
            setState(() {
              _isEditing = true;
            });
          },
          icon: const Icon(Icons.edit)),
    ]);
  }
}

import 'package:flutter/material.dart';

class EditText extends StatefulWidget {
  const EditText({this.initialText = '', required this.onSubmitted, super.key});

  final String initialText;
  final void Function(String text) onSubmitted;

  @override
  State<EditText> createState() => _EditTextState();
}

class _EditTextState extends State<EditText> {
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _text = widget.initialText;
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
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: _isEditing
              ? TextField(
                  textAlign: TextAlign.center,
                  controller: _textController,
                  autofocus: true,
                  focusNode: _focusNode,
                  onSubmitted: (text) {
                    setState(() {
                      _text = text;
                      _isEditing = false;
                      widget.onSubmitted(_text);
                    });
                  },
                )
              : Text(
                  _text,
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

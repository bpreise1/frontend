import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExerciseListItemTextfield extends StatefulWidget {
  const ExerciseListItemTextfield(
      {required this.text,
      required this.helperText,
      required this.onSubmitted,
      this.hintText,
      this.disabled = false,
      super.key});

  final String text;
  final String helperText;
  final void Function(String text) onSubmitted;
  final String? hintText;
  final bool disabled;

  @override
  State<ExerciseListItemTextfield> createState() =>
      _ExerciseListItemTextfieldState();
}

class _ExerciseListItemTextfieldState extends State<ExerciseListItemTextfield> {
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _textController.text = widget.text;
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
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
            alignment: Alignment.center,
            child: TextField(
              controller: _textController..text = widget.text,
              focusNode: _focusNode,
              readOnly: widget.disabled,
              onSubmitted: widget.onSubmitted,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                helperText: widget.helperText,
                hintText: widget.hintText ?? '',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
              ],
            )));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExerciseListItemTextfield extends StatefulWidget {
  const ExerciseListItemTextfield(
      {required this.text,
      required this.onSubmitted,
      this.helperText,
      this.hintText,
      this.disabled = false,
      this.submitOnUnfocus = false,
      this.inputFormatters,
      super.key});

  final String text;
  final String? helperText;
  final void Function(String text) onSubmitted;
  final String? hintText;
  final bool disabled;
  final bool submitOnUnfocus;
  final List<TextInputFormatter>? inputFormatters;

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
      if (widget.submitOnUnfocus) {
        widget.onSubmitted(_textController.text);
      } else {
        setState(() {
          _textController.text = widget.text;
        });
      }
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
              key: UniqueKey(),
              controller: _textController..text = widget.text,
              focusNode: _focusNode,
              readOnly: widget.disabled,
              onSubmitted: (text) {
                widget.onSubmitted(_textController.text);
              },
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                helperText: widget.helperText,
                hintText: widget.hintText ?? '',
              ),
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              inputFormatters: widget.inputFormatters,
            )));
  }
}

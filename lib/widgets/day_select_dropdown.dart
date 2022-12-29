import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/exercise_plan_provider.dart';

class DaySelectDropdown extends StatefulWidget {
  const DaySelectDropdown(
      {required this.provider, this.editingEnabled = false, super.key});

  final bool editingEnabled;
  final StateNotifierProvider<ExercisePlanNotifier, ExercisePlanState> provider;

  @override
  State<DaySelectDropdown> createState() => _DaySelectDropdownState();
}

class _DaySelectDropdownState extends State<DaySelectDropdown> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: ((context, ref, child) {
      String currentDay = ref.watch(widget.provider).currentDay;
      List<String> allDays = ref.watch(widget.provider).days;

      return Row(
        children: [
          Expanded(
              child: DropdownButton<String>(
                  isExpanded: true,
                  value: currentDay,
                  items: allDays
                      .map((day) => DropdownMenuItem<String>(
                          value: day,
                          child: Center(
                              child: _isEditing
                                  ? TextField(
                                      textAlign: TextAlign.center,
                                      controller: _textEditingController
                                        ..text = currentDay,
                                      autofocus: true,
                                      focusNode: _focusNode,
                                      onSubmitted: (text) {
                                        ref
                                            .read(widget.provider.notifier)
                                            .updateDayName(text);
                                        setState(() {
                                          _isEditing = false;
                                        });
                                      },
                                    )
                                  : Text(day, textAlign: TextAlign.center))))
                      .toList(),
                  onChanged: _isEditing
                      ? null
                      : ((value) {
                          ref.read(widget.provider.notifier).selectDay(value!);
                        }))),
          if (widget.editingEnabled)
            Row(children: [
              IconButton(
                  onPressed: () {
                    ref.read(widget.provider.notifier).addDay();
                  },
                  icon: const Icon(Icons.add_circle)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  icon: const Icon(Icons.edit)),
              IconButton(
                  onPressed: allDays.length > 1
                      ? () {
                          showDialog(
                              context: context,
                              builder: ((context) {
                                return AlertDialog(
                                    title: Text(
                                        'Are you sure you want to delete "$currentDay"?'),
                                    content: Row(
                                      children: [
                                        OutlinedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('No')),
                                        OutlinedButton(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                      widget.provider.notifier)
                                                  .removeDay(currentDay);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Yes'))
                                      ],
                                    ));
                              }));
                        }
                      : null,
                  icon: const Icon(Icons.delete))
            ]),
        ],
      );
    }));
  }
}

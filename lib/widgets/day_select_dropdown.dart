import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/exercise_plan_provider.dart';

class DaySelectDropdown extends StatefulWidget {
  const DaySelectDropdown({this.editingEnabled = false, super.key});

  final bool editingEnabled;

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
      String currentDay = ref.watch(exercisePlanProvider).currentDay;
      List<String> allDays = ref.watch(exercisePlanProvider).days;

      return Row(
        children: [
          if (widget.editingEnabled)
            IconButton(
                onPressed: () {
                  ref
                      .read(exercisePlanProvider.notifier)
                      .addDay('Day ${allDays.length + 1}');
                },
                icon: const Icon(Icons.add_circle)),
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
                                            .read(exercisePlanProvider.notifier)
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
                          ref
                              .read(exercisePlanProvider.notifier)
                              .selectDay(value!);
                        }))),
          if (widget.editingEnabled)
            IconButton(
                onPressed: () {
                  print(allDays);
                  setState(() {
                    _isEditing = true;
                  });
                },
                icon: const Icon(Icons.edit))
        ],
      );
    }));
  }
}

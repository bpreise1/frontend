import 'package:flutter/material.dart';

class VisibilitySettingsDropdown extends StatefulWidget {
  const VisibilitySettingsDropdown({super.key});

  @override
  State<VisibilitySettingsDropdown> createState() =>
      _VisibilitySettingsDropdownState();
}

class _VisibilitySettingsDropdownState
    extends State<VisibilitySettingsDropdown> {
  String _dropdownValue = 'public';

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              value: _dropdownValue,
              items: const [
                DropdownMenuItem(
                  value: 'public',
                  child: Text(
                    'Public',
                  ),
                ),
                DropdownMenuItem(
                  value: 'private',
                  child: Text('Private'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _dropdownValue = value!;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

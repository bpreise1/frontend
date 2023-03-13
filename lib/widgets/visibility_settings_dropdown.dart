import 'package:flutter/material.dart';

class VisibilitySettingsDropdown extends StatefulWidget {
  const VisibilitySettingsDropdown(
      {required this.isPublic,
      required this.onPublicSelected,
      required this.onPrivateSelected,
      super.key});

  final bool isPublic;
  final void Function() onPublicSelected;
  final void Function() onPrivateSelected;

  @override
  State<VisibilitySettingsDropdown> createState() =>
      _VisibilitySettingsDropdownState();
}

class _VisibilitySettingsDropdownState
    extends State<VisibilitySettingsDropdown> {
  @override
  Widget build(BuildContext context) {
    String dropdownValue = widget.isPublic ? 'public' : 'private';

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
              value: dropdownValue,
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
                if (value == 'public') {
                  widget.onPublicSelected();
                } else {
                  widget.onPrivateSelected();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

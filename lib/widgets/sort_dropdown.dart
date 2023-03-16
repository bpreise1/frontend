import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/widgets/comment_section.dart';

class SortDropdown extends StatelessWidget {
  const SortDropdown(
      {required this.value,
      required this.onMostLikedSelected,
      required this.onMostRecentSelected,
      super.key});

  final SortByOptions value;
  final void Function() onMostLikedSelected;
  final void Function() onMostRecentSelected;

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: value,
      items: const [
        DropdownMenuItem(
          value: SortByOptions.mostLiked,
          child: Text('Most liked'),
        ),
        DropdownMenuItem(
          value: SortByOptions.mostRecent,
          child: Text('Most recent'),
        )
      ],
      onChanged: (value) {
        if (value == SortByOptions.mostLiked) {
          onMostLikedSelected();
        } else if (value == SortByOptions.mostRecent) {
          onMostRecentSelected();
        }
      },
    );
  }
}

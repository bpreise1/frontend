import 'package:flutter/material.dart';

enum SortByOptions {
  mostLiked,
  mostRecent,
}

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
    return Row(
      children: [
        const Text('Sort by:'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
        ),
        DropdownButton(
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
        ),
      ],
    );
  }
}

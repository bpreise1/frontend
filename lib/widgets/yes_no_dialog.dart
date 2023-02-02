import 'package:flutter/material.dart';

class YesNoDialog extends StatelessWidget {
  const YesNoDialog(
      {required this.title,
      required this.onNoPressed,
      required this.onYesPressed,
      super.key});

  final Widget title;
  final void Function() onNoPressed;
  final void Function() onYesPressed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: onNoPressed,
            child: Text(
              'No',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: onYesPressed,
            child: Text(
              'Yes',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/models/exercise.dart';

class ExerciseListItem extends StatelessWidget {
  const ExerciseListItem(
      {required this.exercise,
      this.children = const [],
      this.onTapEnabled = true,
      super.key});

  final Exercise exercise;
  final List<Widget> children;
  final bool onTapEnabled;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: InkWell(
      onTap: onTapEnabled
          ? () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text(exercise.name),
                        content: Column(
                          children: [Text(exercise.description)],
                        ),
                      ));
            }
          : null,
      child: Card(
        child: Row(
          children: [
            Image.asset(
                'assets/${exercise.name.toLowerCase().replaceAll(' ', '_')}.png',
                width: 50,
                height: 50),
            Text(exercise.name),
            ...children
          ],
        ),
      ),
    ));
  }
}

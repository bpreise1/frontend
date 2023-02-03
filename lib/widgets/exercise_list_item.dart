import 'package:flutter/material.dart';
import 'package:frontend/models/exercise.dart';

class ExerciseListItem extends StatelessWidget {
  const ExerciseListItem(
      {required this.exercise,
      this.children = const [],
      this.onTapEnabled = true,
      this.flexible = true,
      super.key});

  final Exercise exercise;
  final List<Widget> children;
  final bool onTapEnabled;
  final bool flexible;

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
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Image.asset('assets/temp.png', width: 64, height: 64),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                ),
                flexible
                    ? Flexible(
                        fit: FlexFit.tight,
                        child: Text(exercise.name),
                      )
                    : Text(exercise.name),
                ...children
              ],
            ),
          ),
        ),
      ),
    );
  }
}

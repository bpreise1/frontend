import 'package:flutter/material.dart';
import 'package:frontend/widgets/exercise_list.dart';

class EncyclopediaPage extends StatelessWidget {
  const EncyclopediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
        ),
        Expanded(
          child: ExerciseList(),
        ),
      ],
    );
  }
}

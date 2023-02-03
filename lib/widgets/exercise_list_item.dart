import 'package:flutter/material.dart';
import 'package:frontend/models/exercise.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ImageSize { small, large }

class ExerciseListItem extends StatelessWidget {
  const ExerciseListItem(
      {required this.exercise,
      this.children = const [],
      this.onTapEnabled = true,
      this.flexible = true,
      this.imageSize = ImageSize.large,
      super.key});

  final Exercise exercise;
  final List<Widget> children;
  final bool onTapEnabled;
  final bool flexible;
  final ImageSize imageSize;

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
          child: SizedBox(
            height: 90,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  imageSize == ImageSize.large
                      ? SvgPicture.asset('assets/temp.svg',
                          width: 48, height: 48)
                      : SvgPicture.asset('assets/temp.svg',
                          width: 24, height: 24),
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
      ),
    );
  }
}

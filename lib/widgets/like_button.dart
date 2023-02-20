import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _isLoadingNotifier = ValueNotifier(false);

class LikeButton extends StatefulWidget {
  const LikeButton(
      {required this.isLiked,
      required this.onLikeClicked,
      required this.onUnlikeClicked,
      super.key});

  final bool isLiked;
  final Future<void> Function() onLikeClicked;
  final Future<void> Function() onUnlikeClicked;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isLoadingNotifier,
      builder: (context, isLoading, child) {
        return Consumer(
          builder: (context, ref, child) {
            return Row(children: [
              IconButton(
                disabledColor: Theme.of(context).colorScheme.onBackground,
                icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, anim) => RotationTransition(
                          turns: child.key == const ValueKey('icon1')
                              ? Tween<double>(begin: 0, end: 0).animate(anim)
                              : Tween<double>(begin: 0, end: 0).animate(anim),
                          child: ScaleTransition(scale: anim, child: child),
                        ),
                    child: !widget.isLiked
                        ? const Icon(Icons.thumb_up, key: ValueKey('icon1'))
                        : Icon(
                            Icons.thumb_up,
                            color: Theme.of(context).colorScheme.secondary,
                            key: const ValueKey('icon2'),
                          )),
                onPressed: isLoading
                    ? null
                    : () async {
                        _isLoadingNotifier.value = true;
                        if (widget.isLiked) {
                          await widget.onUnlikeClicked();
                        } else {
                          await widget.onLikeClicked();
                        }
                        _isLoadingNotifier.value = false;
                      },
              ),
            ]);
          },
        );
      },
    );
  }
}

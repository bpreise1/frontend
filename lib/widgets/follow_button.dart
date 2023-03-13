import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  const FollowButton(
      {required this.isFollowing,
      required this.onFollow,
      required this.onUnfollow,
      super.key});

  final bool isFollowing;
  final void Function() onFollow;
  final void Function() onUnfollow;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.resolveWith<Size>(
          (_) => const Size(120, 42),
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (_) {
            if (!isFollowing) {
              return Theme.of(context).cardColor;
            }
            return Theme.of(context).colorScheme.secondary;
          },
        ),
      ),
      onPressed: () {
        if (!isFollowing) {
          onFollow();
        } else {
          onUnfollow();
        }
      },
      child: Text(
        !isFollowing ? 'Follow' : 'Unfollow',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
    );
  }
}

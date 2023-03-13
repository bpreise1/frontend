import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/custom_user.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/repository/user_repository.dart';

class FollowButton extends ConsumerWidget {
  const FollowButton({required this.user, super.key});

  final CustomUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isFollowing = user.followers.contains(
      userRepository.getCurrentUserId(),
    );
    final bool isRequested = user.followRequests.any(
      (request) => request.id == userRepository.getCurrentUserId(),
    );
    final bool isPublic = user.visibilitySettings.isPublicProfile;

    print(isPublic);
    print(isRequested);

    return ElevatedButton(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.resolveWith<Size>(
          (_) => const Size(120, 42),
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (_) {
            if (!isFollowing) {
              if (isRequested) {
                return Theme.of(context).disabledColor;
              }
              return Theme.of(context).cardColor;
            }
            return Theme.of(context).colorScheme.secondary;
          },
        ),
      ),
      onPressed: () {
        if (!isFollowing) {
          if (!isRequested && !isPublic) {
            ref
                .read(
                  userNotifierProvider(user.id).notifier,
                )
                .requestFollow();
          } else if (!isRequested && isPublic) {
            ref
                .read(
                  userNotifierProvider(user.id).notifier,
                )
                .addFollower();
          } else {
            ref
                .read(
                  userNotifierProvider(user.id).notifier,
                )
                .unrequestFollow();
          }
        } else {
          ref
              .read(
                userNotifierProvider(user.id).notifier,
              )
              .removeFollower();
        }
      },
      child: Text(
        !isFollowing
            ? isRequested
                ? 'Requested'
                : 'Follow'
            : 'Unfollow',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:typed_data';

import 'package:frontend/models/progress_picture.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:frontend/models/custom_user.dart';
import 'package:frontend/repository/user_repository.dart';

part 'user_provider.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  FutureOr<CustomUser> build(String uid) {
    return userRepository.getUserById(uid);
  }

  Future<void> fetchUser(String uid) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => userRepository.getUserById(uid),
    );
  }

  Future<void> setUsername(String username) async {
    state.whenData(
      (user) async {
        state = AsyncValue.data(
          CustomUser(
            id: user.id,
            username: username,
            publishedPlans: user.publishedPlans,
            visibilitySettings: user.visibilitySettings,
            profilePicture: user.profilePicture,
            progressPictures: user.progressPictures,
          ),
        );
      },
    );
  }

  Future<void> setProfilePicture(Uint8List picture) async {
    state.whenData(
      (user) {
        state = AsyncValue.data(
          CustomUser(
            id: user.id,
            username: user.username,
            publishedPlans: user.publishedPlans,
            visibilitySettings: user.visibilitySettings,
            profilePicture: picture,
            progressPictures: user.progressPictures,
          ),
        );
      },
    );
  }

  Future<void> addProgressPicture(ProgressPicture picture) async {
    state.whenData((user) {
      userRepository.addProgressPictureForCurrentUser(picture);

      state = AsyncValue.data(
        CustomUser(
          id: user.id,
          username: user.username,
          publishedPlans: user.publishedPlans,
          visibilitySettings: user.visibilitySettings,
          profilePicture: user.profilePicture,
          progressPictures: [...user.progressPictures, picture],
        ),
      );
    });
  }
}

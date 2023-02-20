import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/custom_user.dart';
import 'package:frontend/models/user_exception.dart';
import 'package:frontend/repository/user_repository.dart';

class CurrentUserNotifier extends AsyncNotifier<CustomUser> {
  @override
  FutureOr<CustomUser> build() {
    return userRepository.getUserById(
      userRepository.getCurrentUserId(),
    );
  }

  Future<void> fetchCurrentUser() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => userRepository.getUserById(userRepository.getCurrentUserId()));
  }

  Future<void> setUsernameById(String uid, String username) async {
    if (username == '') {
      throw const UserException(message: 'Username must not be empty');
    }

    if (!(await userRepository.usernameIsAvailable(username))) {
      throw UserException(message: '"$username" is already taken');
    }

    state.whenData((user) async {
      await userRepository.setUsernameById(uid, username);
      state = AsyncValue.data(CustomUser(
          username: username,
          publishedPlans: state.value!.publishedPlans,
          progressPictures: state.value!.progressPictures,
          visibilitySettings: state.value!.visibilitySettings));
    });
  }
}

final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, CustomUser>(
        CurrentUserNotifier.new);

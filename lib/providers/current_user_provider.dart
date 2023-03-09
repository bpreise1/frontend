import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/user_exception.dart';
import 'package:frontend/models/user_info.dart';
import 'package:frontend/repository/user_repository.dart';

class CurrentUserInfoNotifier extends AsyncNotifier<CustomUserInfo> {
  @override
  FutureOr<CustomUserInfo> build() async {
    return await userRepository
        .getUserInfoById(userRepository.getCurrentUserId());
  }

  Future<void> setUsernameById(String uid, String username) async {
    if (username == '') {
      throw const UserException(message: 'Username must not be empty');
    }

    if (!(await userRepository.usernameIsAvailable(username))) {
      throw UserException(message: '"$username" is already taken');
    }

    state.whenData((value) async {
      await userRepository.setUsernameById(uid, username);

      state = AsyncValue.data(CustomUserInfo(
          id: state.value!.id,
          username: username,
          profilePicture: state.value!.profilePicture));
    });
  }

  void setProfilePictureForCurrentUser(Uint8List image) {
    state.whenData((value) {
      userRepository.setProfilePictureForCurrentUser(image);

      state = AsyncValue.data(CustomUserInfo(
          id: state.value!.id,
          username: state.value!.username,
          profilePicture: image));
    });
  }
}

final currentUserProvider =
    AsyncNotifierProvider<CurrentUserInfoNotifier, CustomUserInfo>(
        CurrentUserInfoNotifier.new);

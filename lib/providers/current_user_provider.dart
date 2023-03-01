import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/custom_user.dart';
import 'package:frontend/models/user_exception.dart';
import 'package:frontend/repository/user_repository.dart';

class CurrentUserInfoState {
  CurrentUserInfoState(
      {required this.id, required this.username, required this.profilePicture});

  final String id;
  final String username;
  final Uint8List? profilePicture;
}

class CurrentUserInfoNotifier extends AsyncNotifier<CurrentUserInfoState> {
  @override
  FutureOr<CurrentUserInfoState> build() async {
    CustomUser currentUser =
        await userRepository.getUserById(userRepository.getCurrentUserId());
    return CurrentUserInfoState(
        id: currentUser.id,
        username: currentUser.username,
        profilePicture: currentUser.profilePicture);
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
      state = AsyncValue.data(CurrentUserInfoState(
          id: state.value!.id,
          username: username,
          profilePicture: state.value!.profilePicture));
    });
  }

  void setProfilePictureForCurrentUser(Uint8List image) {
    state.whenData((value) {
      userRepository.setProfilePictureForCurrentUser(image);
      state = AsyncValue.data(CurrentUserInfoState(
          id: state.value!.id,
          username: state.value!.username,
          profilePicture: image));
    });
  }
}

final currentUserProvider =
    AsyncNotifierProvider<CurrentUserInfoNotifier, CurrentUserInfoState>(
        CurrentUserInfoNotifier.new);

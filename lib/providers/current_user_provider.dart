import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/custom_user.dart';
import 'package:frontend/repository/user_repository.dart';

class CurrentUserNotifier extends AsyncNotifier<CustomUser> {
  @override
  FutureOr<CustomUser> build() {
    return userRepository.getUserById(
      userRepository.getCurrentUserId(),
    );
  }
}

final currentUserProvider =
    AsyncNotifierProvider<CurrentUserNotifier, CustomUser>(
        CurrentUserNotifier.new);

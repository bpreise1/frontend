import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/custom_user.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/repository/user_repository.dart';

class UserNotifier extends AsyncNotifier<CustomUser> {
  @override
  FutureOr<CustomUser> build() {
    return userRepository.getUserById(userRepository.getCurrentUserId());
  }

  Future<void> _updateUser() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => userRepository.getUserById(userRepository.getCurrentUserId()));
  }

  Future<void> publishExercisePlan(
      PublishedExercisePlan publishedExercisePlan) async {
    await userRepository
        .publishExercisePlanForCurrentUser(publishedExercisePlan);

    _updateUser();
  }
}

final currentUserProvider =
    AsyncNotifierProvider<UserNotifier, CustomUser>(UserNotifier.new);

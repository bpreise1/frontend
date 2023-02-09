import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/custom_user.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/repository/user_repository.dart';

class ProfilePageNotifier extends AsyncNotifier<CustomUser?> {
  @override
  FutureOr<CustomUser?> build() {
    return null;
  }

  Future<void> fetchUser(String uid) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => userRepository.getUserById(uid),
    );
  }

  Future<void> likeExercisePlan(String exercisePlanId) async {
    final String currentUser = userRepository.getCurrentUserId();

    if (state.hasValue) {
      final CustomUser user = state.value!;
      final PublishedExercisePlan plan =
          user.publishedPlans.firstWhere((plan) => plan.id == exercisePlanId);
      plan.likedBy.add(currentUser);

      await userRepository.likePublishedExercisePlan(
          exercisePlanId, currentUser);

      state = AsyncValue.data(user);
    }
  }

  Future<void> unlikeExercisePlan(String exercisePlanId) async {
    final String currentUser = userRepository.getCurrentUserId();

    if (state.hasValue) {
      final CustomUser user = state.value!;
      final PublishedExercisePlan plan =
          user.publishedPlans.firstWhere((plan) => plan.id == exercisePlanId);
      plan.likedBy.remove(currentUser);

      await userRepository.unlikePublishedExercisePlan(
          exercisePlanId, currentUser);

      state = AsyncValue.data(user);
    }
  }
}

final profilePageProvider =
    AsyncNotifierProvider<ProfilePageNotifier, CustomUser?>(
        ProfilePageNotifier.new);

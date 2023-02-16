import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comment.dart';
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

  Future<void> addCommentForExercisePlan(
      String exercisePlanId, Comment comment) async {
    if (state.hasValue) {
      final CustomUser user = state.value!;
      final PublishedExercisePlan plan =
          user.publishedPlans.firstWhere((plan) => plan.id == exercisePlanId);
      plan.comments.add(comment);

      await userRepository.addCommentForExercisePlan(exercisePlanId, comment);

      state = AsyncValue.data(user);
    }
  }

  Future<void> likeCommentForExercisePlan(
      String exercisePlanId, String likerId, String commentId) async {
    if (state.hasValue) {
      final CustomUser user = state.value!;
      final PublishedExercisePlan plan =
          user.publishedPlans.firstWhere((plan) => plan.id == exercisePlanId);

      outerloop:
      for (final comment in plan.comments) {
        if (comment.id == commentId) {
          comment.likedBy.add(likerId);
          break outerloop;
        }

        for (final reply in comment.replies) {
          if (reply.id == commentId) {
            reply.likedBy.add(likerId);
            break outerloop;
          }
        }
      }

      await userRepository.likeCommentForExercisePlan(
          exercisePlanId, likerId, commentId);

      state = AsyncValue.data(user);
    }
  }

  Future<void> unlikeCommentForExercisePlan(
      String exercisePlanId, String likerId, String commentId) async {
    if (state.hasValue) {
      final CustomUser user = state.value!;
      final PublishedExercisePlan plan =
          user.publishedPlans.firstWhere((plan) => plan.id == exercisePlanId);

      outerloop:
      for (final comment in plan.comments) {
        if (comment.id == commentId) {
          comment.likedBy.remove(likerId);
          break outerloop;
        }

        for (final reply in comment.replies) {
          if (reply.id == commentId) {
            reply.likedBy.remove(likerId);
            break outerloop;
          }
        }
      }

      await userRepository.unlikeCommentForExercisePlan(
          exercisePlanId, likerId, commentId);

      state = AsyncValue.data(user);
    }
  }

  Future<void> replyToCommentForExercisePlan(
      String exercisePlanId, String commentId, Comment reply) async {
    if (state.hasValue) {
      final CustomUser user = state.value!;
      final PublishedExercisePlan plan =
          user.publishedPlans.firstWhere((plan) => plan.id == exercisePlanId);
      final Comment comment =
          plan.comments.firstWhere((comment) => comment.id == commentId);
      comment.replies.add(reply);

      await userRepository.replyToCommentForExercisePlan(
          exercisePlanId, commentId, reply);

      state = AsyncValue.data(user);
    }
  }
}

final profilePageProvider =
    AsyncNotifierProvider<ProfilePageNotifier, CustomUser?>(
        ProfilePageNotifier.new);

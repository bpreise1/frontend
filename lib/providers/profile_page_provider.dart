import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/custom_user.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
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

    if (state.asData != null) {
      final CustomUser user = state.value!;
      final PublishedExercisePlan plan =
          user.publishedPlans.firstWhere((plan) => plan.id == exercisePlanId);
      plan.likedBy.add(currentUser);

      await userRepository.likePublishedExercisePlan(
          exercisePlanId, currentUser);

      ref.read(publishedExercisePlanProvider.notifier).setPlan(plan);

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

      ref.read(publishedExercisePlanProvider.notifier).setPlan(plan);

      state = AsyncValue.data(user);
    }
  }

  Future<void> addCommentForExercisePlan(
      String exercisePlanId, Comment comment) async {
    if (state.hasValue) {
      final CustomUser user = state.value!;

      for (int i = 0; i < user.publishedPlans.length; i++) {
        final plan = user.publishedPlans[i];
        if (plan.id == exercisePlanId) {
          user.publishedPlans[i] = PublishedExercisePlan(
              id: plan.id,
              planName: plan.planName,
              dayToExercisesMap: plan.dayToExercisesMap,
              description: plan.description,
              creatorUserId: plan.creatorUserId,
              dateCreated: plan.dateCreated,
              likedBy: plan.likedBy,
              comments: [...plan.comments, comment],
              totalComments: plan.totalComments + 1);

          ref
              .read(publishedExercisePlanProvider.notifier)
              .setPlan(user.publishedPlans[i]);

          break;
        }
      }

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

      ref.read(publishedExercisePlanProvider.notifier).setPlan(plan);

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

      ref.read(publishedExercisePlanProvider.notifier).setPlan(plan);

      state = AsyncValue.data(user);
    }
  }

  Future<void> replyToCommentForExercisePlan(
      String exercisePlanId, String commentId, Comment reply) async {
    if (state.hasValue) {
      final CustomUser user = state.value!;

      outerloop:
      for (int i = 0; i < user.publishedPlans.length; i++) {
        final plan = user.publishedPlans[i];
        if (plan.id == exercisePlanId) {
          for (final comment in plan.comments) {
            if (comment.id == commentId) {
              comment.replies.add(reply);

              user.publishedPlans[i] = PublishedExercisePlan(
                  id: plan.id,
                  planName: plan.planName,
                  dayToExercisesMap: plan.dayToExercisesMap,
                  description: plan.description,
                  creatorUserId: plan.creatorUserId,
                  dateCreated: plan.dateCreated,
                  likedBy: plan.likedBy,
                  comments: plan.comments,
                  totalComments: plan.totalComments + 1);

              ref
                  .read(publishedExercisePlanProvider.notifier)
                  .setPlan(user.publishedPlans[i]);

              break outerloop;
            }
          }
        }
      }

      await userRepository.replyToCommentForExercisePlan(
          exercisePlanId, commentId, reply);

      state = AsyncValue.data(user);
    }
  }
}

final profilePageProvider =
    AsyncNotifierProvider<ProfilePageNotifier, CustomUser?>(
        ProfilePageNotifier.new);

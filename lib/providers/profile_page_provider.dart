import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/custom_user.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/models/progress_picture.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
import 'package:frontend/repository/user_repository.dart';

class ProfilePageNotifier extends AsyncNotifier<CustomUser?> {
  @override
  FutureOr<CustomUser?> build() async {
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

  Future<void> addProgressPictureForCurrentUser(
      ProgressPicture progressPicture) async {
    state.whenData((user) {
      userRepository.addProgressPictureForCurrentUser(progressPicture);

      List<ProgressPicture> progressPictures = [
        ...state.value!.progressPictures
      ];
      progressPictures.add(
        progressPicture,
      );

      state = AsyncValue.data(CustomUser(
          id: state.value!.id,
          username: state.value!.username,
          publishedPlans: state.value!.publishedPlans,
          visibilitySettings: state.value!.visibilitySettings,
          profilePicture: state.value!.profilePicture,
          progressPictures: progressPictures));
    });
  }

  Future<void> likeProgessPictureForUser(
      String pictureId, String userId) async {
    state.whenData((user) async {
      final String currentUser = userRepository.getCurrentUserId();

      await userRepository.likeProgressPictureForUser(
          pictureId, userId, currentUser);

      final List<ProgressPicture> newProgressPictures = [];
      for (final progressPicture in user!.progressPictures) {
        if (progressPicture.id == pictureId) {
          newProgressPictures.add(
            ProgressPicture(
              id: progressPicture.id,
              image: progressPicture.image,
              creatorUserId: progressPicture.creatorUserId,
              dateCreated: progressPicture.dateCreated,
              likedBy: [...progressPicture.likedBy, currentUser],
              comments: progressPicture.comments,
              totalComments: progressPicture.totalComments,
            ),
          );
        } else {
          newProgressPictures.add(progressPicture);
        }
      }

      CustomUser newUser = CustomUser(
        id: user.id,
        username: user.username,
        publishedPlans: user.publishedPlans,
        visibilitySettings: user.visibilitySettings,
        profilePicture: user.profilePicture,
        progressPictures: newProgressPictures,
      );

      state = AsyncValue.data(newUser);
    });
  }

  Future<void> unlikeProgessPictureForUser(
      String pictureId, String userId) async {
    state.whenData((user) async {
      final String currentUser = userRepository.getCurrentUserId();

      await userRepository.unlikeProgressPictureForUser(
          pictureId, userId, currentUser);

      final List<ProgressPicture> newProgressPictures = [];
      for (final progressPicture in user!.progressPictures) {
        if (progressPicture.id == pictureId) {
          List<String> newLikedBy = [...progressPicture.likedBy];
          newLikedBy.remove(currentUser);

          newProgressPictures.add(
            ProgressPicture(
              id: progressPicture.id,
              image: progressPicture.image,
              creatorUserId: progressPicture.creatorUserId,
              dateCreated: progressPicture.dateCreated,
              likedBy: newLikedBy,
              comments: progressPicture.comments,
              totalComments: progressPicture.totalComments,
            ),
          );
        } else {
          newProgressPictures.add(progressPicture);
        }
      }

      CustomUser newUser = CustomUser(
        id: user.id,
        username: user.username,
        publishedPlans: user.publishedPlans,
        visibilitySettings: user.visibilitySettings,
        profilePicture: user.profilePicture,
        progressPictures: newProgressPictures,
      );

      state = AsyncValue.data(newUser);
    });
  }

  void setProfilePicture(Uint8List image) {
    state.whenData((user) {
      state = AsyncValue.data(CustomUser(
          id: state.value!.id,
          username: state.value!.username,
          publishedPlans: state.value!.publishedPlans,
          visibilitySettings: state.value!.visibilitySettings,
          profilePicture: image,
          progressPictures: state.value!.progressPictures));
    });
  }
}

final profilePageProvider =
    AsyncNotifierProvider<ProfilePageNotifier, CustomUser?>(
        ProfilePageNotifier.new);

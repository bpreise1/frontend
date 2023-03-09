import 'package:frontend/models/comment.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'published_exercise_plan_provider.g.dart';

@riverpod
class PublishedExercisePlanNotifier extends _$PublishedExercisePlanNotifier {
  @override
  PublishedExercisePlan build(String uid, String planId) {
    final user = ref.watch(
      userNotifierProvider(uid),
    );

    return user.value!.publishedPlans.firstWhere((plan) => plan.id == planId);
  }

  Future<void> likePlan() async {
    await userRepository.likePublishedExercisePlan(
      planId,
      userRepository.getCurrentUserId(),
    );

    state = PublishedExercisePlan(
      id: state.id,
      planName: state.planName,
      dayToExercisesMap: state.dayToExercisesMap,
      description: state.description,
      creatorUserId: state.creatorUserId,
      dateCreated: state.dateCreated,
      likedBy: [
        ...state.likedBy,
        userRepository.getCurrentUserId(),
      ],
      comments: state.comments,
      totalComments: state.totalComments,
    );
  }

  Future<void> unlikePlan() async {
    await userRepository.unlikePublishedExercisePlan(
      planId,
      userRepository.getCurrentUserId(),
    );

    List<String> newLikedBy = [...state.likedBy];
    newLikedBy.remove(
      userRepository.getCurrentUserId(),
    );

    state = PublishedExercisePlan(
      id: state.id,
      planName: state.planName,
      dayToExercisesMap: state.dayToExercisesMap,
      description: state.description,
      creatorUserId: state.creatorUserId,
      dateCreated: state.dateCreated,
      likedBy: newLikedBy,
      comments: state.comments,
      totalComments: state.totalComments,
    );
  }

  Future<void> addComment(Comment comment) async {
    await userRepository.addCommentForExercisePlan(planId, comment);

    state = PublishedExercisePlan(
      id: state.id,
      planName: state.planName,
      dayToExercisesMap: state.dayToExercisesMap,
      description: state.description,
      creatorUserId: state.creatorUserId,
      dateCreated: state.dateCreated,
      likedBy: state.likedBy,
      comments: [
        ...state.comments,
        comment,
      ],
      totalComments: state.totalComments + 1,
    );
  }

  Future<void> replyToComment(String commentId, Comment reply) async {
    await userRepository.replyToCommentForExercisePlan(
        planId, commentId, reply);

    final List<Comment> newComments = [];

    for (final comment in state.comments) {
      if (comment.id == commentId) {
        newComments.add(
          Comment(
            id: comment.id,
            comment: comment.comment,
            creatorUserId: comment.creatorUserId,
            creatorUsername: comment.creatorUsername,
            dateCreated: comment.dateCreated,
            likedBy: comment.likedBy,
            replies: [
              ...comment.replies,
              reply,
            ],
          ),
        );
      } else {
        newComments.add(comment);
      }
    }

    state = PublishedExercisePlan(
      id: state.id,
      planName: state.planName,
      dayToExercisesMap: state.dayToExercisesMap,
      description: state.description,
      creatorUserId: state.creatorUserId,
      dateCreated: state.dateCreated,
      likedBy: state.likedBy,
      comments: newComments,
      totalComments: state.totalComments + 1,
    );
  }

  Future<void> likeComment(String commentId) async {
    await userRepository.likeCommentForExercisePlan(
        planId, userRepository.getCurrentUserId(), commentId);

    final List<Comment> newComments = [];

    bool isFound = false;
    for (final comment in state.comments) {
      if (comment.id == commentId) {
        isFound = true;

        newComments.add(
          Comment(
            id: comment.id,
            comment: comment.comment,
            creatorUserId: comment.creatorUserId,
            creatorUsername: comment.creatorUsername,
            dateCreated: comment.dateCreated,
            likedBy: [
              ...comment.likedBy,
              userRepository.getCurrentUserId(),
            ],
            replies: comment.replies,
          ),
        );
        continue;
      } else if (!isFound) {
        final List<Comment> newReplies = [];

        for (final reply in comment.replies) {
          if (reply.id == commentId) {
            isFound = true;

            newReplies.add(
              Comment(
                id: reply.id,
                comment: reply.comment,
                creatorUserId: reply.creatorUserId,
                creatorUsername: reply.creatorUsername,
                dateCreated: reply.dateCreated,
                likedBy: [
                  ...reply.likedBy,
                  userRepository.getCurrentUserId(),
                ],
                replies: reply.replies,
              ),
            );
          } else {
            newReplies.add(reply);
          }
        }

        newComments.add(
          Comment(
            id: comment.id,
            comment: comment.comment,
            creatorUserId: comment.creatorUserId,
            creatorUsername: comment.creatorUsername,
            dateCreated: comment.dateCreated,
            likedBy: comment.likedBy,
            replies: newReplies,
          ),
        );
      } else {
        newComments.add(comment);
      }
    }

    state = PublishedExercisePlan(
      id: state.id,
      planName: state.planName,
      dayToExercisesMap: state.dayToExercisesMap,
      description: state.description,
      creatorUserId: state.creatorUserId,
      dateCreated: state.dateCreated,
      likedBy: state.likedBy,
      comments: newComments,
      totalComments: state.totalComments,
    );
  }

  Future<void> unlikeComment(String commentId) async {
    await userRepository.unlikeCommentForExercisePlan(
        planId, userRepository.getCurrentUserId(), commentId);

    final List<Comment> newComments = [];

    bool isFound = false;
    for (final comment in state.comments) {
      if (comment.id == commentId) {
        isFound = true;

        final List<String> newLikedBy = [...comment.likedBy];
        newLikedBy.remove(
          userRepository.getCurrentUserId(),
        );

        newComments.add(
          Comment(
            id: comment.id,
            comment: comment.comment,
            creatorUserId: comment.creatorUserId,
            creatorUsername: comment.creatorUsername,
            dateCreated: comment.dateCreated,
            likedBy: newLikedBy,
            replies: comment.replies,
          ),
        );
      } else if (!isFound) {
        final List<Comment> newReplies = [];

        for (final reply in comment.replies) {
          if (reply.id == commentId) {
            isFound = true;

            final List<String> newLikedBy = [...comment.likedBy];
            newLikedBy.remove(
              userRepository.getCurrentUserId(),
            );

            newReplies.add(
              Comment(
                id: reply.id,
                comment: reply.comment,
                creatorUserId: reply.creatorUserId,
                creatorUsername: reply.creatorUsername,
                dateCreated: reply.dateCreated,
                likedBy: newLikedBy,
                replies: reply.replies,
              ),
            );
          } else {
            newReplies.add(reply);
          }
        }

        newComments.add(
          Comment(
            id: comment.id,
            comment: comment.comment,
            creatorUserId: comment.creatorUserId,
            creatorUsername: comment.creatorUsername,
            dateCreated: comment.dateCreated,
            likedBy: comment.likedBy,
            replies: newReplies,
          ),
        );
      } else {
        newComments.add(comment);
      }
    }

    state = PublishedExercisePlan(
      id: state.id,
      planName: state.planName,
      dayToExercisesMap: state.dayToExercisesMap,
      description: state.description,
      creatorUserId: state.creatorUserId,
      dateCreated: state.dateCreated,
      likedBy: state.likedBy,
      comments: newComments,
      totalComments: state.totalComments,
    );
  }
}

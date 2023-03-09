import 'package:frontend/models/comment.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:frontend/models/progress_picture.dart';
import 'package:frontend/repository/user_repository.dart';

part 'progress_picture_provider.g.dart';

@riverpod
class ProgressPictureNotifier extends _$ProgressPictureNotifier {
  @override
  ProgressPicture build(String uid, String pictureId) {
    final user = ref.watch(
      userNotifierProvider(uid),
    );

    return user.value!.progressPictures
        .firstWhere((picture) => picture.id == pictureId);
  }

  Future<void> likePicture() async {
    await userRepository.likeProgressPictureForUser(
      pictureId,
      uid,
      userRepository.getCurrentUserId(),
    );

    state = ProgressPicture(
      id: state.id,
      image: state.image,
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

  Future<void> unlikePicture() async {
    await userRepository.unlikeProgressPictureForUser(
      pictureId,
      uid,
      userRepository.getCurrentUserId(),
    );

    List<String> newLikedBy = [...state.likedBy];
    newLikedBy.remove(
      userRepository.getCurrentUserId(),
    );

    state = ProgressPicture(
      id: state.id,
      image: state.image,
      creatorUserId: state.creatorUserId,
      dateCreated: state.dateCreated,
      likedBy: newLikedBy,
      comments: state.comments,
      totalComments: state.totalComments,
    );
  }

  Future<void> addComment(Comment comment) async {
    await userRepository.addCommentToProgressPictureForUser(
        pictureId, uid, comment);

    state = ProgressPicture(
      id: state.id,
      image: state.image,
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
    await userRepository.replyToProgressPictureCommentForUser(
        pictureId, uid, commentId, reply);

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

    state = ProgressPicture(
      id: state.id,
      image: state.image,
      creatorUserId: state.creatorUserId,
      dateCreated: state.dateCreated,
      likedBy: state.likedBy,
      comments: newComments,
      totalComments: state.totalComments + 1,
    );
  }

  Future<void> likeComment(String commentId) async {
    await userRepository.likeProgressPictureCommentForUser(
        pictureId, uid, userRepository.getCurrentUserId(), commentId);

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

    state = ProgressPicture(
      id: state.id,
      image: state.image,
      creatorUserId: state.creatorUserId,
      dateCreated: state.dateCreated,
      likedBy: state.likedBy,
      comments: newComments,
      totalComments: state.totalComments,
    );
  }

  Future<void> unlikeComment(String commentId) async {
    await userRepository.unlikeProgressPictureCommentForUser(
        pictureId, uid, userRepository.getCurrentUserId(), commentId);

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

    state = ProgressPicture(
      id: state.id,
      image: state.image,
      creatorUserId: state.creatorUserId,
      dateCreated: state.dateCreated,
      likedBy: state.likedBy,
      comments: newComments,
      totalComments: state.totalComments,
    );
  }
}

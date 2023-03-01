import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/custom_user.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/models/progress_picture.dart';
import 'package:uuid/uuid.dart';

abstract class IUserRepository {
  String getCurrentUserId();
  Future<CustomUser> getUserById(String uid);
  Future<void> publishExercisePlanForCurrentUser(
      PublishedExercisePlan completedExercisePlan);
  Future<void> likePublishedExercisePlan(String exercisePlanId, String likerId);
  Future<void> unlikePublishedExercisePlan(
      String exercisePlanId, String likerId);
  Future<void> addCommentForExercisePlan(
      String exercisePlanId, Comment comment);
  Future<void> likeCommentForExercisePlan(
      String exercisePlanId, String likerId, String commentId);
  Future<void> unlikeCommentForExercisePlan(
      String exercisePlanId, String likerId, String commentId);
  Future<void> replyToCommentForExercisePlan(
      String exercisePlanId, String commentId, Comment reply);
}

class UserRepository implements IUserRepository {
  @override
  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Future<CustomUser> getUserById(String uid) async {
    final docRef =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    Map<String, dynamic> jsonData = {};
    for (final field in docRef.data()!.entries) {
      if (field.key == 'exercise_plans') {
        jsonData[field.key] = [];

        List exercisePlanRefs = field.value;
        for (DocumentReference<Map<String, dynamic>> ref in exercisePlanRefs) {
          final doc = await ref.get();
          final docData = doc.data()!;

          jsonData[field.key] = [...jsonData[field.key], docData];
        }
      } else {
        jsonData[field.key] = field.value;
      }
    }

    final profilePictureRef = FirebaseStorage.instance
        .ref()
        .child('profile_pictures/${getCurrentUserId()}.jpg');

    Uint8List? profilePicture;
    try {
      profilePicture = await profilePictureRef.getData();
    } on PlatformException catch (exception) {
      print(exception);
    }

    final progressPicturesFolderRef = FirebaseStorage.instance
        .ref()
        .child('progress_pictures/${getCurrentUserId()}');
    final progressPicturesList = await progressPicturesFolderRef.listAll();

    List<ProgressPicture> progressPictures = [];
    for (final progressPicture in progressPicturesList.items) {
      try {
        final progressPictureData = await progressPicture.getData();

        final metaData = await progressPicture.getMetadata();
        final timeCreated = metaData.timeCreated;

        if (progressPictureData != null) {
          progressPictures.add(
            ProgressPicture(
              image: progressPictureData,
              timeCreated: timeCreated,
            ),
          );
        }
      } on PlatformException catch (exception) {
        print('exception');
      }
    }
    progressPictures.sort(
      (pic1, pic2) {
        if (pic1.timeCreated == null && pic2.timeCreated == null) {
          return 0;
        }

        if (pic1.timeCreated == null) {
          return 1;
        }

        if (pic2.timeCreated == null) {
          return -1;
        }

        return pic1.timeCreated!.compareTo(pic2.timeCreated!);
      },
    );

    return CustomUser.fromJson(jsonData,
        profilePicture: profilePicture, progressPictures: progressPictures);
  }

  @override
  Future<void> publishExercisePlanForCurrentUser(
      PublishedExercisePlan publishedExercisePlan) async {
    final publishedPlanRef = FirebaseFirestore.instance
        .collection('exercise_plans')
        .doc(publishedExercisePlan.id);

    await publishedPlanRef.set(publishedExercisePlan.toJson());

    await FirebaseFirestore.instance
        .collection('users')
        .doc(getCurrentUserId())
        .update({
      'exercise_plans': FieldValue.arrayUnion(
        [
          publishedPlanRef,
        ],
      )
    });
  }

  @override
  Future<void> likePublishedExercisePlan(
      String exercisePlanId, String likerId) async {
    await FirebaseFirestore.instance
        .collection('exercise_plans')
        .doc(exercisePlanId)
        .update({
      'likedBy': FieldValue.arrayUnion(
        [
          likerId,
        ],
      )
    });
  }

  @override
  Future<void> unlikePublishedExercisePlan(
      String exercisePlanId, String likerId) async {
    await FirebaseFirestore.instance
        .collection('exercise_plans')
        .doc(exercisePlanId)
        .update({
      'likedBy': FieldValue.arrayRemove(
        [
          likerId,
        ],
      )
    });
  }

  @override
  Future<void> addCommentForExercisePlan(
      String exercisePlanId, Comment comment) async {
    await FirebaseFirestore.instance
        .collection('exercise_plans')
        .doc(exercisePlanId)
        .update({
      'comments': FieldValue.arrayUnion(
        [
          comment.toJson(),
        ],
      ),
      'totalComments': FieldValue.increment(1),
    });
  }

  @override
  Future<void> likeCommentForExercisePlan(
      String exercisePlanId, String likerId, String commentId) async {
    final planRef = FirebaseFirestore.instance
        .collection('exercise_plans')
        .doc(exercisePlanId);
    final planDoc = await planRef.get();

    Map<String, dynamic> plan = planDoc.data()!;
    List comments = plan['comments'];

    Map<String, dynamic> newComment = {};
    outerloop:
    for (final Map<String, dynamic> comment in comments) {
      if (comment['id'] == commentId) {
        List likedBy = comment['likedBy'];
        likedBy.add(likerId);
        newComment['likedBy'] = likedBy;
        break outerloop;
      }

      for (final Map<String, dynamic> reply in comment['replies']) {
        if (reply['id'] == commentId) {
          List likedBy = reply['likedBy'];
          likedBy.add(likerId);
          newComment['likedBy'] = likedBy;
          break outerloop;
        }
      }
    }

    plan['comment'] = newComment;

    await planRef.update(
      {
        'comments': comments,
      },
    );
  }

  @override
  Future<void> unlikeCommentForExercisePlan(
      String exercisePlanId, String likerId, String commentId) async {
    final planRef = FirebaseFirestore.instance
        .collection('exercise_plans')
        .doc(exercisePlanId);
    final planDoc = await planRef.get();
    Map<String, dynamic> plan = planDoc.data()!;

    List comments = plan['comments'];

    Map<String, dynamic> newComment = {};
    outerloop:
    for (final Map<String, dynamic> comment in comments) {
      if (comment['id'] == commentId) {
        List likedBy = comment['likedBy'];
        likedBy.remove(likerId);
        newComment['likedBy'] = likedBy;
        break outerloop;
      }

      for (final Map<String, dynamic> reply in comment['replies']) {
        if (reply['id'] == commentId) {
          List likedBy = reply['likedBy'];
          likedBy.remove(likerId);
          newComment['likedBy'] = likedBy;
          break outerloop;
        }
      }
    }

    plan['comment'] = newComment;

    await planRef.update(
      {
        'comments': comments,
      },
    );
  }

  @override
  Future<void> replyToCommentForExercisePlan(
      String exercisePlanId, String commentId, Comment reply) async {
    final planRef = FirebaseFirestore.instance
        .collection('exercise_plans')
        .doc(exercisePlanId);
    final planDoc = await planRef.get();
    Map<String, dynamic> plan = planDoc.data()!;

    List comments = plan['comments'];
    Map<String, dynamic> comment =
        comments.firstWhere((comment) => comment['id'] == commentId);
    List replies = comment['replies'];
    replies.add(reply.toJson());
    comment['replies'] = replies;
    plan['comment'] = comment;

    await planRef.update(
      {
        'comments': comments,
        'totalComments': FieldValue.increment(1),
      },
    );
  }

  Future<void> setUsernameById(String uid, String username) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update(
      {
        'username': username,
        'username_lowercase': username.toLowerCase(),
      },
    );
  }

  Future<bool> usernameIsAvailable(String username) async {
    final users = await FirebaseFirestore.instance
        .collection('users')
        .where('username_lowercase', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();

    if (users.docs.isNotEmpty) {
      return false;
    }
    return true;
  }

  Future<void> setProfilePictureForCurrentUser(Uint8List image) async {
    final storageRef = FirebaseStorage.instance.ref();
    final profilePictureRef =
        storageRef.child('profile_pictures/${getCurrentUserId()}.jpg');

    await profilePictureRef.putData(image);
  }

  Future<void> addProgressPictureForCurrentUser(Uint8List image) async {
    final storageRef = FirebaseStorage.instance.ref();
    final progressPicturesRef = storageRef.child(
        'progress_pictures/${getCurrentUserId()}/${const Uuid().v4()}.jpg');

    await progressPicturesRef.putData(image);
  }
}

final UserRepository userRepository = UserRepository();

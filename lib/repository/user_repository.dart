import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/custom_user.dart';
import 'package:frontend/models/exercise_plans.dart';

abstract class IUserRepository {
  String getCurrentUserId();
  Future<CustomUser> getUserById(String uid);
  Future<void> publishExercisePlanForCurrentUser(
      PublishedExercisePlan completedExercisePlan);
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

    return CustomUser.fromJson(jsonData);
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
      )
    });
  }

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
      },
    );
  }
}

final UserRepository userRepository = UserRepository();

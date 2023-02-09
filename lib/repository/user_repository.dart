import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
}

final UserRepository userRepository = UserRepository();

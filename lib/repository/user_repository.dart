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

    return CustomUser.fromJson(docRef.data()!);
  }

  @override
  Future<void> publishExercisePlanForCurrentUser(
      PublishedExercisePlan publishedExercisePlan) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(getCurrentUserId())
        .update({
      'exercise_plans': FieldValue.arrayUnion(
        [
          publishedExercisePlan.toJson(),
        ],
      )
    });
  }
}

final UserRepository userRepository = UserRepository();

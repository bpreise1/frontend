import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:frontend/home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        // If the user is already signed-in, use it as initial data
        initialData: FirebaseAuth.instance.currentUser,
        builder: ((context, snapshot) {
          // User is not signed in
          if (!snapshot.hasData) {
            return SignInScreen(
              actions: [
                AuthStateChangeAction<UserCreated>(
                  (context, state) {
                    final user = state.credential.user!;
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .set({
                      'uid': user.uid,
                      'username': '',
                      'exercise_plans': [],
                      'progress_pictures': [],
                      'visibility_settings': {},
                    });
                  },
                )
              ],
            );
          }

          // Render application if authenticated
          return const Home();
        }));
  }
}

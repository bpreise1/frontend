import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/home.dart';
import 'package:frontend/models/visibility_settings.dart';
import 'package:frontend/providers/current_user_provider.dart';
import 'package:frontend/screens/create_profile_page.dart';

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
            return Consumer(
              builder: (context, ref, child) {
                return SignInScreen(
                  actions: [
                    AuthStateChangeAction<UserCreated>(
                      (context, state) async {
                        final user = state.credential.user!;
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .set({
                          'uid': user.uid,
                          'username': '',
                          'username_lowercase': '',
                          'exercise_plans': [],
                          'progress_pictures': [],
                          'visibility_settings':
                              const VisibilitySettings().toJson(),
                          'followers': [],
                          'follow_requests': [],
                        });
                      },
                    ),
                    AuthStateChangeAction<SignedIn>(
                      (context, state) async {
                        ref.invalidate(currentUserProvider);
                      },
                    )
                  ],
                );
              },
            );
          }

          // Render application if authenticated
          return Consumer(
            builder: (context, ref, child) {
              final currentUser = ref.watch(currentUserProvider);

              return currentUser.when(
                data: (data) {
                  if (data.username == '') {
                    return const CreateProfilePage();
                  } else {
                    return const Home();
                  }
                },
                error: (error, stackTrace) {
                  return const Text('Error logging in');
                },
                loading: () {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  );
                },
              );
            },
          );
        }));
  }
}

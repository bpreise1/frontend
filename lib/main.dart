import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app.dart';
import 'package:frontend/authentication/firebase_options.dart';
import 'package:frontend/models/user_preferences.dart';
import 'package:frontend/repository/user_preferences_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseUIAuth.configureProviders(
    [
      EmailAuthProvider(),
      GoogleProvider(
          clientId:
              '1067187549080-sp094097p0l7rsslbsabaj6ld0uqv1be.apps.googleusercontent.com'),
    ],
  );

  try {
    await userPreferencesRepository.getUserPreferences();
  } catch (_) {
    await userPreferencesRepository.setUserPreferences(
        const UserPreferences(weightMode: WeightMode.pounds));
  }

  runApp(const ProviderScope(child: App()));
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/user_preferences.dart';
import 'package:frontend/repository/user_preferences_repository.dart';

class UserPreferencesNotifier extends AsyncNotifier<UserPreferences> {
  @override
  FutureOr<UserPreferences> build() {
    return userPreferencesRepository.getUserPreferences();
  }

  Future<void> _updateUserPreferences() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userPreferences =
          await userPreferencesRepository.getUserPreferences();
      return userPreferences;
    });
  }

  Future<void> setUserPreferences(UserPreferences userPreferences) async {
    await userPreferencesRepository.setUserPreferences(userPreferences);
    _updateUserPreferences();
  }

  Future<void> setWeightMode(WeightMode newWeightMode) async {
    //Not necessary now to have individual field setters but will be convenient once more fields are added
    await setUserPreferences(UserPreferences(weightMode: newWeightMode));
  }
}

final userPreferencesProvider =
    AsyncNotifierProvider<UserPreferencesNotifier, UserPreferences>(
        UserPreferencesNotifier.new);

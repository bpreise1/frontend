import 'dart:convert';
import 'dart:io';

import 'package:frontend/models/user_preferences.dart';
import 'package:path_provider/path_provider.dart';

abstract class IUserPreferencesRepository {
  Future<void> setUserPreferences(UserPreferences userPreferences);
  Future<UserPreferences> getUserPreferences();
}

class UserPreferencesRepository implements IUserPreferencesRepository {
  @override
  Future<void> setUserPreferences(UserPreferences userPreferences) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();

    final File file = File('${appDocDir.path}/user_preferences');
    await file.writeAsString(jsonEncode(userPreferences.toJson()));
  }

  @override
  Future<UserPreferences> getUserPreferences() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final File file = File('${appDocDir.path}/user_preferences');
    final String contents = await file.readAsString();
    return UserPreferences.fromJson(jsonDecode(contents));
  }
}

final UserPreferencesRepository userPreferencesRepository =
    UserPreferencesRepository();

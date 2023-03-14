import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/models/custom_user_info.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_page_provider.g.dart';

@riverpod
class SearchPageNotifier extends _$SearchPageNotifier {
  @override
  FutureOr<List<CustomUserInfo>> build() {
    return [];
  }

  Future<void> queryUsersByUsername(String username) async {
    if (!RegExp(r'^\s*$').hasMatch(username)) {
      state.whenData(
        (stateUserList) async {
          final databaseUserListSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('username_lowercase',
                  isGreaterThanOrEqualTo: username.toLowerCase(),
                  isLessThanOrEqualTo: '${username.toLowerCase()}\uf8ff')
              .get();

          final databaseUserList = databaseUserListSnapshot.docs
              .map(
                (doc) => doc.data(),
              )
              .toList();

          final List<CustomUserInfo> newUsers = [];
          for (final Map<String, dynamic> databaseUser in databaseUserList) {
            CustomUserInfo newUser;

            try {
              newUser = stateUserList.firstWhere(
                (stateUser) => stateUser.id == databaseUser['uid'],
              );
            } catch (exception) {
              final profilePicture = await userRepository
                  .getProfilePictureById(databaseUser['uid']);
              newUser = CustomUserInfo(
                  id: databaseUser['uid'],
                  username: databaseUser['username'],
                  profilePicture: profilePicture);
            }

            newUsers.add(newUser);
          }

          state = AsyncData(
            newUsers,
          );
        },
      );
    } else {
      state = const AsyncData(
        [],
      );
    }
  }
}

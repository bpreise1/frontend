import 'dart:async';
import 'dart:typed_data';

import 'package:frontend/models/custom_user_info.dart';
import 'package:frontend/models/progress_picture.dart';
import 'package:frontend/models/visibility_settings.dart';
import 'package:frontend/providers/current_user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:frontend/models/custom_user.dart';
import 'package:frontend/repository/user_repository.dart';

part 'user_provider.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  FutureOr<CustomUser> build(String uid) {
    return userRepository.getUserById(uid);
  }

  Future<void> fetchUser() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => userRepository.getUserById(uid),
    );
  }

  Future<void> setUsername(String username) async {
    state.whenData(
      (user) async {
        state = AsyncValue.data(
          CustomUser(
            id: user.id,
            username: username,
            publishedPlans: user.publishedPlans,
            visibilitySettings: user.visibilitySettings,
            profilePicture: user.profilePicture,
            progressPictures: user.progressPictures,
            followers: user.followers,
            followRequests: user.followRequests,
          ),
        );
      },
    );
  }

  Future<void> setProfilePicture(Uint8List picture) async {
    state.whenData(
      (user) {
        state = AsyncValue.data(
          CustomUser(
            id: user.id,
            username: user.username,
            publishedPlans: user.publishedPlans,
            visibilitySettings: user.visibilitySettings,
            profilePicture: picture,
            progressPictures: user.progressPictures,
            followers: user.followers,
            followRequests: user.followRequests,
          ),
        );
      },
    );
  }

  Future<void> addProgressPicture(ProgressPicture picture) async {
    state.whenData((user) {
      userRepository.addProgressPictureForCurrentUser(picture);

      state = AsyncValue.data(
        CustomUser(
          id: user.id,
          username: user.username,
          publishedPlans: user.publishedPlans,
          visibilitySettings: user.visibilitySettings,
          profilePicture: user.profilePicture,
          progressPictures: [...user.progressPictures, picture],
          followers: user.followers,
          followRequests: user.followRequests,
        ),
      );
    });
  }

  Future<void> addFollower() async {
    state.whenData(
      (user) {
        userRepository.addFollowerForUser(
          uid,
          userRepository.getCurrentUserId(),
        );

        state = AsyncValue.data(
          CustomUser(
            id: user.id,
            username: user.username,
            publishedPlans: user.publishedPlans,
            visibilitySettings: user.visibilitySettings,
            profilePicture: user.profilePicture,
            progressPictures: user.progressPictures,
            followers: [
              ...user.followers,
              userRepository.getCurrentUserId(),
            ],
            followRequests: user.followRequests,
          ),
        );
      },
    );
  }

  Future<void> removeFollower() async {
    state.whenData(
      (user) {
        userRepository.removeFollowerForUser(
          uid,
          userRepository.getCurrentUserId(),
        );

        List<String> newFollowers = [...user.followers];
        newFollowers.remove(
          userRepository.getCurrentUserId(),
        );

        state = AsyncValue.data(
          CustomUser(
            id: user.id,
            username: user.username,
            publishedPlans: user.publishedPlans,
            visibilitySettings: user.visibilitySettings,
            profilePicture: user.profilePicture,
            progressPictures: user.progressPictures,
            followers: newFollowers,
            followRequests: user.followRequests,
          ),
        );
      },
    );
  }

  Future<void> requestFollow() async {
    state.whenData((user) {
      CustomUserInfo followerInfo = ref.read(currentUserProvider).value!;

      userRepository.requestFollowForUser(uid, followerInfo);

      state = AsyncValue.data(
        CustomUser(
          id: user.id,
          username: user.username,
          publishedPlans: user.publishedPlans,
          visibilitySettings: user.visibilitySettings,
          profilePicture: user.profilePicture,
          progressPictures: user.progressPictures,
          followers: user.followers,
          followRequests: [
            ...user.followRequests,
            followerInfo,
          ],
        ),
      );
    });
  }

  Future<void> unrequestFollow() async {
    state.whenData((user) {
      CustomUserInfo followerInfo = ref.read(currentUserProvider).value!;

      userRepository.unrequestFollowForUser(uid, followerInfo);

      List<CustomUserInfo> newFollowRequests = [...user.followRequests];
      newFollowRequests.removeWhere((request) => request.id == followerInfo.id);

      state = AsyncValue.data(
        CustomUser(
          id: user.id,
          username: user.username,
          publishedPlans: user.publishedPlans,
          visibilitySettings: user.visibilitySettings,
          profilePicture: user.profilePicture,
          progressPictures: user.progressPictures,
          followers: user.followers,
          followRequests: newFollowRequests,
        ),
      );
    });
  }

  Future<void> setProfilePublic() async {
    state.whenData(
      (user) {
        userRepository.setProfileStatusForUser(uid, isPublic: true);

        state = AsyncValue.data(
          CustomUser(
              id: user.id,
              username: user.username,
              publishedPlans: user.publishedPlans,
              visibilitySettings:
                  const VisibilitySettings(isPublicProfile: true),
              profilePicture: user.profilePicture,
              progressPictures: user.progressPictures,
              followers: user.followers,
              followRequests: user.followRequests),
        );
      },
    );
  }

  Future<void> setProfilePrivate() async {
    state.whenData(
      (user) {
        userRepository.setProfileStatusForUser(uid, isPublic: false);

        state = AsyncValue.data(
          CustomUser(
              id: user.id,
              username: user.username,
              publishedPlans: user.publishedPlans,
              visibilitySettings:
                  const VisibilitySettings(isPublicProfile: false),
              profilePicture: user.profilePicture,
              progressPictures: user.progressPictures,
              followers: user.followers,
              followRequests: user.followRequests),
        );
      },
    );
  }

  Future<void> acceptFollowRequest(CustomUserInfo followerInfo) async {
    state.whenData(
      (user) {
        userRepository.acceptFollowRequestForUser(uid, followerInfo);

        final List<CustomUserInfo> newFollowRequests = [];
        newFollowRequests
            .removeWhere((request) => request.id == followerInfo.id);

        state = AsyncValue.data(
          CustomUser(
              id: user.id,
              username: user.username,
              publishedPlans: user.publishedPlans,
              visibilitySettings: user.visibilitySettings,
              profilePicture: user.profilePicture,
              progressPictures: user.progressPictures,
              followers: [...user.followers, followerInfo.id],
              followRequests: newFollowRequests),
        );
      },
    );
  }

  Future<void> rejectFollowRequest(CustomUserInfo followerInfo) async {
    state.whenData(
      (user) {
        userRepository.rejectFollowRequestForUser(uid, followerInfo);

        final List<CustomUserInfo> newFollowRequests = [];
        newFollowRequests
            .removeWhere((request) => request.id == followerInfo.id);

        state = AsyncValue.data(
          CustomUser(
              id: user.id,
              username: user.username,
              publishedPlans: user.publishedPlans,
              visibilitySettings: user.visibilitySettings,
              profilePicture: user.profilePicture,
              progressPictures: user.progressPictures,
              followers: user.followers,
              followRequests: newFollowRequests),
        );
      },
    );
  }
}

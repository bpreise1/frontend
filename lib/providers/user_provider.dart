import 'dart:async';
import 'dart:typed_data';

import 'package:frontend/models/custom_user_info.dart';
import 'package:frontend/models/exercise_plans.dart';
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

  Future<void> deleteExercisePlan(String exercisePlanId) async {
    state.whenData(
      (user) {
        userRepository.deleteExercisePlanForCurrentUser(exercisePlanId);

        final List<PublishedExercisePlan> newExercisePlans = [
          ...user.publishedPlans
        ];
        newExercisePlans.removeWhere((plan) => plan.id == exercisePlanId);

        state = AsyncValue.data(
          CustomUser(
            id: user.id,
            username: user.username,
            publishedPlans: newExercisePlans,
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

  Future<void> addProgressPicture(ProgressPicture picture) async {
    state.whenData(
      (user) {
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
      },
    );
  }

  Future<void> deleteProgressPicture(ProgressPicture picture) async {
    state.whenData((user) {
      userRepository.deleteProgressPictureForCurrentUser(picture);

      final List<ProgressPicture> newProgressPictures = [
        ...user.progressPictures
      ];
      newProgressPictures.removeWhere((pic) => pic.id == picture.id);

      state = AsyncValue.data(
        CustomUser(
          id: user.id,
          username: user.username,
          publishedPlans: user.publishedPlans,
          visibilitySettings: user.visibilitySettings,
          profilePicture: user.profilePicture,
          progressPictures: newProgressPictures,
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
              visibilitySettings: VisibilitySettings(
                isPublicProfile: true,
                showExercisePlans: user.visibilitySettings.showExercisePlans,
                showProgressPictures:
                    user.visibilitySettings.showProgressPictures,
              ),
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
              visibilitySettings: VisibilitySettings(
                isPublicProfile: false,
                showExercisePlans: user.visibilitySettings.showExercisePlans,
                showProgressPictures:
                    user.visibilitySettings.showProgressPictures,
              ),
              profilePicture: user.profilePicture,
              progressPictures: user.progressPictures,
              followers: user.followers,
              followRequests: user.followRequests),
        );
      },
    );
  }

  Future<void> showExercisePlans() async {
    state.whenData(
      (user) {
        userRepository.setExercisePlanVisibilityForUser(uid, true);

        state = AsyncValue.data(
          CustomUser(
              id: user.id,
              username: user.username,
              publishedPlans: user.publishedPlans,
              visibilitySettings: VisibilitySettings(
                isPublicProfile: user.visibilitySettings.isPublicProfile,
                showExercisePlans: true,
                showProgressPictures:
                    user.visibilitySettings.showProgressPictures,
              ),
              profilePicture: user.profilePicture,
              progressPictures: user.progressPictures,
              followers: user.followers,
              followRequests: user.followRequests),
        );
      },
    );
  }

  Future<void> hideExercisePlans() async {
    state.whenData(
      (user) {
        userRepository.setExercisePlanVisibilityForUser(uid, false);

        state = AsyncValue.data(
          CustomUser(
              id: user.id,
              username: user.username,
              publishedPlans: user.publishedPlans,
              visibilitySettings: VisibilitySettings(
                isPublicProfile: user.visibilitySettings.isPublicProfile,
                showExercisePlans: false,
                showProgressPictures:
                    user.visibilitySettings.showProgressPictures,
              ),
              profilePicture: user.profilePicture,
              progressPictures: user.progressPictures,
              followers: user.followers,
              followRequests: user.followRequests),
        );
      },
    );
  }

  Future<void> showProgressPictures() async {
    state.whenData(
      (user) {
        userRepository.setProgressPictureVisibilityForUser(uid, true);

        state = AsyncValue.data(
          CustomUser(
              id: user.id,
              username: user.username,
              publishedPlans: user.publishedPlans,
              visibilitySettings: VisibilitySettings(
                isPublicProfile: user.visibilitySettings.isPublicProfile,
                showExercisePlans: user.visibilitySettings.showExercisePlans,
                showProgressPictures: true,
              ),
              profilePicture: user.profilePicture,
              progressPictures: user.progressPictures,
              followers: user.followers,
              followRequests: user.followRequests),
        );
      },
    );
  }

  Future<void> hideProgressPictures() async {
    state.whenData(
      (user) {
        userRepository.setProgressPictureVisibilityForUser(uid, false);

        state = AsyncValue.data(
          CustomUser(
              id: user.id,
              username: user.username,
              publishedPlans: user.publishedPlans,
              visibilitySettings: VisibilitySettings(
                isPublicProfile: user.visibilitySettings.isPublicProfile,
                showExercisePlans: user.visibilitySettings.showExercisePlans,
                showProgressPictures: false,
              ),
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

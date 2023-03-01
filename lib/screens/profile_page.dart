import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/custom_user.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
import 'package:frontend/providers/profile_page_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/screens/published_plan_page.dart';
import 'package:frontend/widgets/add_image_button.dart';
import 'package:frontend/widgets/add_picture_modal.dart';
import 'package:frontend/widgets/like_button.dart';
import 'package:frontend/widgets/profile_avatar.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage(
      {required this.id,
      required this.username,
      required this.profilePicture,
      super.key});

  //these two variables are only to be used for the loading state, when data is ready, that will be shown instead
  final String id;
  final String username;
  final Uint8List? profilePicture;

  List<Widget> _getPublishedPlanListTiles(
      List<PublishedExercisePlan> publishedPlans,
      BuildContext context,
      WidgetRef ref) {
    List<Widget> publishedPlanListTiles = [];

    for (int index = 0; index < publishedPlans.length; index++) {
      PublishedExercisePlan plan = publishedPlans[index];
      int likes = plan.likedBy.length;

      Widget publishedPlanTile = ListTile(
        onTap: () async {
          ref.read(publishedExercisePlanProvider.notifier).setPlan(plan);

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const PublishedPlanPage();
              },
            ),
          );
        },
        title: Center(
          child: Text(plan.planName),
        ),
        subtitle: Row(
          children: [
            Expanded(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                LikeButton(
                  isLiked: plan.likedBy.contains(
                    userRepository.getCurrentUserId(),
                  ),
                  onLikeClicked: () async {
                    await ref
                        .read(profilePageProvider.notifier)
                        .likeExercisePlan(plan.id);
                  },
                  onUnlikeClicked: () async {
                    await ref
                        .read(profilePageProvider.notifier)
                        .unlikeExercisePlan(plan.id);
                  },
                ),
                Text(
                  likes.toString(),
                ),
              ]),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      ref
                          .read(publishedExercisePlanProvider.notifier)
                          .setPlan(plan);

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return const PublishedPlanPage();
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.comment),
                  ),
                  Text(
                    plan.totalComments.toString(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      publishedPlanListTiles.add(publishedPlanTile);
    }

    return publishedPlanListTiles;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isCurrentUserProfile = id == userRepository.getCurrentUserId();

    final user = ref.watch(profilePageProvider);

    return user.when(
      data: (data) {
        if (data != null) {
          final CustomUser user = data;

          return Scaffold(
            appBar: AppBar(
              title: Text(user.username),
            ),
            body: ListView(
              children: [
                ProfileAvatar(
                  radius: 80,
                  profilePicture: user.profilePicture,
                  editingEnabled: isCurrentUserProfile,
                  isProfilePage: true,
                ),
                Card(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                      ),
                      const Text(
                        'Published Plans',
                        style: TextStyle(fontSize: 20),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      ..._getPublishedPlanListTiles(
                          user.publishedPlans, context, ref),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                      ),
                      const Text(
                        'Progress Pictures',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        height: 100,
                        child: user.progressPictures.isEmpty
                            ? const Center(
                                child: Text(
                                  'No progress pictures added yet',
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: user.progressPictures.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Image(
                                        image: MemoryImage(
                                          user.progressPictures[index],
                                        ),
                                      ),
                                      const Text('Date here'),
                                    ],
                                  );
                                },
                              ),
                      ),
                      AddImageButton(
                        size: 1.25,
                        onImagePicked: (image) {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const Center(
          child: Text('User not found'),
        );
      },
      error: (error, stackTrace) {
        print(stackTrace);
        return Text(error.toString());
      },
      loading: () {
        return Scaffold(
          appBar: AppBar(
            title: Text(username),
          ),
          body: Center(
            child: Column(
              children: [
                ProfileAvatar(
                  radius: 80,
                  profilePicture: profilePicture,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                ),
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

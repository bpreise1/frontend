import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/custom_user.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
import 'package:frontend/providers/profile_page_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/screens/progress_picture_page.dart';
import 'package:frontend/screens/published_plan_page.dart';
import 'package:frontend/widgets/add_image_button.dart';
import 'package:frontend/widgets/like_button.dart';
import 'package:frontend/widgets/profile_avatar.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(
      {required this.id,
      required this.username,
      required this.profilePicture,
      super.key});

  //these two variables are only to be used for the loading state, when data is ready, that will be shown instead
  final String id;
  final String username;
  final Uint8List? profilePicture;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ScrollController _progressPicturesController = ScrollController();

  void _scrollRight() {
    _progressPicturesController.animateTo(
      _progressPicturesController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _scrollLeft() {
    _progressPicturesController.animateTo(
      _progressPicturesController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  List<Widget> _getPublishedPlanListTiles(
      List<PublishedExercisePlan> publishedPlans,
      BuildContext context,
      WidgetRef ref) {
    List<Widget> publishedPlanListTiles = [];

    for (int index = 0; index < publishedPlans.length; index++) {
      PublishedExercisePlan plan = publishedPlans[index];
      int likes = plan.likedBy.length;

      Widget publishedPlanTile = Column(
        children: [
          const Divider(
            height: .5,
          ),
          ListTile(
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
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
          ),
          const Divider(
            height: .5,
          ),
        ],
      );

      publishedPlanListTiles.add(publishedPlanTile);
    }

    return publishedPlanListTiles;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final bool isCurrentUserProfile =
            widget.id == userRepository.getCurrentUserId();

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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                    ),
                    Hero(
                      tag: widget.id,
                      child: ProfileAvatar(
                        radius: 80,
                        profilePicture: user.profilePicture,
                        editingEnabled: isCurrentUserProfile,
                        isProfilePage: true,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
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
                            height: 300,
                            child: user.progressPictures.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        'No progress pictures added yet',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    controller: _progressPicturesController,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: user.progressPictures.length,
                                    separatorBuilder: (context, index) {
                                      return const Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 4),
                                      );
                                    },
                                    itemBuilder: (context, index) {
                                      MemoryImage image = MemoryImage(
                                          user.progressPictures[index].image);

                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (context) {
                                                  return ProgressPicturePage(
                                                    username: user.username,
                                                    image: image,
                                                    timeCreated: user
                                                        .progressPictures[index]
                                                        .timeCreated,
                                                  );
                                                },
                                              ));
                                            },
                                            child: Hero(
                                              tag: image,
                                              child: Image(
                                                height: 250,
                                                image: image,
                                              ),
                                            ),
                                          ),
                                          if (user.progressPictures[index]
                                                  .timeCreated !=
                                              null)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Text(
                                                DateFormat('yMMMd').format(user
                                                    .progressPictures[index]
                                                    .timeCreated!),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: user.progressPictures.isNotEmpty
                                    ? () {
                                        _scrollLeft();
                                      }
                                    : null,
                                icon: const Icon(Icons.arrow_back),
                              ),
                              if (isCurrentUserProfile)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: AddImageButton(
                                    size: 1.25,
                                    onImagePicked: (image) async {
                                      ref
                                          .read(profilePageProvider.notifier)
                                          .addProgressPictureForCurrentUser(
                                              image);

                                      if (_progressPicturesController
                                          .hasClients) {
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            _scrollRight);
                                      }
                                    },
                                  ),
                                ),
                              IconButton(
                                onPressed: user.progressPictures.isNotEmpty
                                    ? () {
                                        _scrollRight();
                                      }
                                    : null,
                                icon: const Icon(Icons.arrow_forward),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
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
                title: Text(widget.username),
              ),
              body: Center(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                    ),
                    Hero(
                      tag: widget.id,
                      child: ProfileAvatar(
                        radius: 80,
                        profilePicture: widget.profilePicture,
                      ),
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
      },
    );
  }
}

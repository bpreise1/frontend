import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/custom_user.dart';
import 'package:frontend/models/progress_picture.dart';
import 'package:frontend/providers/progress_picture_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/screens/follow_requests_page.dart';
import 'package:frontend/screens/progress_picture_page.dart';
import 'package:frontend/widgets/add_image_button.dart';
import 'package:frontend/widgets/follow_button.dart';
import 'package:frontend/widgets/profile_avatar.dart';
import 'package:frontend/widgets/published_plan_tile.dart';
import 'package:frontend/widgets/visibility_settings_dropdown.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

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
  Uint8List? _currentProfilePicture;

  @override
  void initState() {
    super.initState();
    _currentProfilePicture = widget.profilePicture;
  }

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

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUserProfile =
        widget.id == userRepository.getCurrentUserId();

    return Consumer(
      builder: (context, ref, child) {
        final asyncUser = ref.watch(
          userNotifierProvider(widget.id),
        );

        return asyncUser.when(
          data: (data) {
            final CustomUser user = data;

            _currentProfilePicture = user.profilePicture;

            return Scaffold(
              appBar: AppBar(
                title: Text(user.username),
                actions: [
                  if (isCurrentUserProfile)
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (_) {
                            if (user.followRequests.isEmpty) {
                              return Theme.of(context).colorScheme.onBackground;
                            }
                            return Theme.of(context).colorScheme.secondary;
                          },
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return FollowRequestsPage(
                                uid: widget.id,
                              );
                            },
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            user.followRequests.length.toString(),
                          ),
                          const Icon(Icons.person_add_alt_1),
                        ],
                      ),
                    ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  ref
                      .read(
                        userNotifierProvider(widget.id).notifier,
                      )
                      .fetchUser();
                },
                color: Theme.of(context).colorScheme.secondary,
                child: ListView(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Hero(
                            tag: widget.id,
                            child: ProfileAvatar(
                              radius: 80,
                              profilePicture: _currentProfilePicture,
                              editingEnabled: isCurrentUserProfile,
                              isProfilePage: true,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                          ),
                          FollowButton(
                            user: user,
                          ),
                          VisibilitySettingsDropdown(
                              isPublic: user.visibilitySettings.isPublicProfile,
                              onPublicSelected: () {
                                ref
                                    .read(
                                      userNotifierProvider(widget.id).notifier,
                                    )
                                    .setProfilePublic();
                              },
                              onPrivateSelected: () {
                                ref
                                    .read(
                                      userNotifierProvider(widget.id).notifier,
                                    )
                                    .setProfilePrivate();
                              }),
                        ],
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
                          const Divider(
                            height: .5,
                          ),
                          for (final publishedPlan in user.publishedPlans)
                            PublishedPlanTile(
                                planCreatorId: publishedPlan.creatorUserId,
                                planId: publishedPlan.id),
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
                                      final progressPicture = ref.watch(
                                        progressPictureNotifierProvider(
                                            user.progressPictures[index]
                                                .creatorUserId,
                                            user.progressPictures[index].id),
                                      );

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
                                                    pictureCreatorId:
                                                        progressPicture
                                                            .creatorUserId,
                                                    pictureId:
                                                        progressPicture.id,
                                                  );
                                                },
                                              ));
                                            },
                                            child: Hero(
                                              tag: progressPicture,
                                              child: Image(
                                                height: 250,
                                                image: MemoryImage(
                                                    progressPicture.image),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              DateFormat('yMMMd').format(user
                                                  .progressPictures[index]
                                                  .dateCreated),
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
                                          .read(
                                            userNotifierProvider(widget.id)
                                                .notifier,
                                          )
                                          .addProgressPicture(
                                            ProgressPicture(
                                              id: const Uuid().v4(),
                                              image: image,
                                              creatorUserId: userRepository
                                                  .getCurrentUserId(),
                                              dateCreated: DateTime.now(),
                                            ),
                                          );

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
              ),
            );
          },
          error: (error, stackTrace) {
            print(stackTrace);
            return Text(error.toString());
          },
          loading: () {
            final user = ref
                .read(
                  userNotifierProvider(widget.id),
                )
                .value;

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
                        profilePicture: _currentProfilePicture,
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

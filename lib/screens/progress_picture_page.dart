import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/progress_picture_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/widgets/add_comment_section.dart';
import 'package:frontend/widgets/like_button.dart';
import 'package:frontend/widgets/comment_section.dart';
import 'package:intl/intl.dart';

class ProgressPicturePage extends ConsumerWidget {
  const ProgressPicturePage(
      {required this.username,
      required this.pictureCreatorId,
      required this.pictureId,
      super.key});

  final String username;
  final String pictureCreatorId;
  final String pictureId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressPicture = ref.watch(
      progressPictureNotifierProvider(pictureCreatorId, pictureId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(username),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Hero(
                  tag: progressPicture,
                  child: Image(
                    image: MemoryImage(progressPicture.image),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LikeButton(
                            isLiked: progressPicture.likedBy.contains(
                              userRepository.getCurrentUserId(),
                            ),
                            onLikeClicked: () async {
                              await ref
                                  .read(
                                    progressPictureNotifierProvider(
                                            pictureCreatorId, pictureId)
                                        .notifier,
                                  )
                                  .likePicture();
                            },
                            onUnlikeClicked: () async {
                              await ref
                                  .read(
                                    progressPictureNotifierProvider(
                                            pictureCreatorId, pictureId)
                                        .notifier,
                                  )
                                  .unlikePicture();
                            },
                          ),
                          Text(
                            progressPicture.likedBy.length.toString(),
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
                            icon: const Icon(Icons.comment),
                          ),
                          Text(
                            progressPicture.totalComments.toString(),
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
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Center(
                    child: Text(
                      DateFormat('yMMMMd').format(progressPicture.dateCreated),
                    ),
                  ),
                ),
                const Divider(),
                CommentSection(
                  type: ContentType.progressPicture,
                  contentCreatorId: progressPicture.creatorUserId,
                  contentId: progressPicture.id,
                ),
              ],
            ),
          ),
          AddCommentSection(
            hintText: 'Add a comment...',
            onSubmitted: (comment) {
              ref
                  .read(
                    progressPictureNotifierProvider(pictureCreatorId, pictureId)
                        .notifier,
                  )
                  .addComment(comment);
            },
          ),
        ],
      ),
    );
  }
}

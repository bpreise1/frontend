import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/progress_picture.dart';
import 'package:frontend/providers/profile_page_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/widgets/add_comment_section.dart';
import 'package:frontend/widgets/comment_section.dart';
import 'package:frontend/widgets/like_button.dart';
import 'package:intl/intl.dart';

class ProgressPicturePage extends StatelessWidget {
  const ProgressPicturePage(
      {required this.username, required this.progressPicture, super.key});

  final String username;
  final ProgressPicture progressPicture;

  @override
  Widget build(BuildContext context) {
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
                Consumer(
                  builder: (context, ref, child) {
                    final user = ref.watch(profilePageProvider);

                    return user.when(
                      data: (data) {
                        final picture = data!.progressPictures.firstWhere(
                            (image) => image.id == progressPicture.id);
                        final List<String> likedBy = picture.likedBy;
                        final List<Comment> comments = picture.comments;

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      LikeButton(
                                        isLiked: likedBy.contains(
                                          userRepository.getCurrentUserId(),
                                        ),
                                        onLikeClicked: () async {
                                          await ref
                                              .read(
                                                  profilePageProvider.notifier)
                                              .likeProgessPictureForUser(
                                                  progressPicture.id,
                                                  progressPicture
                                                      .creatorUserId);
                                        },
                                        onUnlikeClicked: () async {
                                          await ref
                                              .read(
                                                  profilePageProvider.notifier)
                                              .unlikeProgessPictureForUser(
                                                  progressPicture.id,
                                                  progressPicture
                                                      .creatorUserId);
                                        },
                                      ),
                                      Text(
                                        likedBy.length.toString(),
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
                                        comments.length.toString(),
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
                                  DateFormat('yMMMMd')
                                      .format(progressPicture.dateCreated),
                                ),
                              ),
                            ),
                            CommentSection(
                              comments: comments,
                              onReply: (comment, replyTo) {},
                              onLikeComment: (likedComment) async {},
                              onUnlikeComment: (unlikedComment) async {},
                            ),
                          ],
                        );
                      },
                      error: (error, stackTrace) {
                        return Text(
                          error.toString(),
                        );
                      },
                      loading: () {
                        return CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.secondary,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          AddCommentSection(
            hintText: 'Add a comment...',
            onSubmitted: (text) {},
          ),
        ],
      ),
    );
  }
}

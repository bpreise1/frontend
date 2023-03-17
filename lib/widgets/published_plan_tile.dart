import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';

import 'package:frontend/providers/published_exercise_plan_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/screens/published_plan_page.dart';
import 'package:frontend/widgets/like_button.dart';
import 'package:frontend/widgets/yes_no_dialog.dart';

class PublishedPlanTile extends StatelessWidget {
  const PublishedPlanTile(
      {required this.planCreatorId,
      required this.planId,
      required this.planName,
      this.onDelete,
      super.key});

  final String planCreatorId;
  final String planId;
  final String planName;
  final void Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    const resizeDuration = Duration(milliseconds: 150);

    return Consumer(
      builder: (context, ref, child) {
        final plan = ref.watch(
          publishedExercisePlanNotifierProvider(planCreatorId, planId),
        );

        return Column(
          children: [
            const Divider(
              height: .5,
            ),
            Slidable(
              key: UniqueKey(),
              enabled: onDelete != null,
              endActionPane: ActionPane(
                  motion: const StretchMotion(),
                  extentRatio: .4,
                  dismissible: DismissiblePane(
                    closeOnCancel: true,
                    confirmDismiss: () async {
                      bool dismiss = false;

                      await showDialog(
                        context: context,
                        builder: (context) {
                          return YesNoDialog(
                            title: ListTile(
                              title: Text(
                                  'Are you sure you want to delete "$planName"?'),
                              subtitle: const Text('This cannot be undone'),
                            ),
                            onNoPressed: () {
                              Navigator.pop(context);
                            },
                            onYesPressed: () {
                              dismiss = true;
                              Navigator.pop(context);
                            },
                          );
                        },
                      );

                      return dismiss;
                    },
                    resizeDuration: resizeDuration,
                    onDismissed: () {
                      onDelete!();
                    },
                  ),
                  children: [
                    SlidableAction(
                      autoClose: false,
                      backgroundColor: const Color(0xFFB00020),
                      label: 'Delete',
                      icon: Icons.delete,
                      onPressed: ((context) async {
                        final SlidableController slidableController =
                            Slidable.of(context)!;

                        showDialog(
                          context: context,
                          builder: (context) {
                            return YesNoDialog(
                              title: ListTile(
                                title: Text(
                                    'Are you sure you want to delete "$planName"?'),
                                subtitle: const Text('This cannot be undone'),
                              ),
                              onNoPressed: () async {
                                Navigator.pop(context);

                                await slidableController.close(
                                    duration: resizeDuration);
                              },
                              onYesPressed: () async {
                                Navigator.pop(context);

                                await slidableController.dismiss(
                                  ResizeRequest(
                                    resizeDuration,
                                    (() {
                                      onDelete!();
                                    }),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }),
                    ),
                  ]),
              child: ListTile(
                onTap: () async {
                  ref
                      .read(publishedExercisePlanProvider.notifier)
                      .setPlan(plan);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return PublishedPlanPage(
                          planCreatorId: planCreatorId,
                          planId: planId,
                        );
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
                                    .read(
                                      publishedExercisePlanNotifierProvider(
                                              planCreatorId, planId)
                                          .notifier,
                                    )
                                    .likePlan();
                              },
                              onUnlikeClicked: () async {
                                await ref
                                    .read(
                                      publishedExercisePlanNotifierProvider(
                                              planCreatorId, planId)
                                          .notifier,
                                    )
                                    .unlikePlan();
                              },
                            ),
                            Text(
                              plan.likedBy.length.toString(),
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
                                    return PublishedPlanPage(
                                      planCreatorId: planCreatorId,
                                      planId: planId,
                                      autofocusCommentSection: true,
                                    );
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
            ),
            const Divider(
              height: .5,
            ),
          ],
        );
      },
    );
  }
}

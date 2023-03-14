import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
import 'package:frontend/providers/published_exercise_plan_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/screens/published_plan_page.dart';
import 'package:frontend/widgets/like_button.dart';

class PublishedPlanTile extends ConsumerWidget {
  const PublishedPlanTile(
      {required this.planCreatorId, required this.planId, super.key});

  final String planCreatorId;
  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(
      publishedExercisePlanNotifierProvider(planCreatorId, planId),
    );
    return Column(
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
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
        const Divider(
          height: .5,
        ),
      ],
    );
  }
}

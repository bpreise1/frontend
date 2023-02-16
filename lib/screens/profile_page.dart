import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/custom_user.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/in_progress_exercise_plan_provider.dart';
import 'package:frontend/providers/profile_page_provider.dart';
import 'package:frontend/providers/published_plan_page_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/screens/published_plan_page.dart';
import 'package:frontend/widgets/like_button.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(profilePageProvider);
    return user.when(
      data: (data) {
        if (data != null) {
          final CustomUser user = data;

          return Scaffold(
            appBar: AppBar(
              title: Text(user.username),
            ),
            body: ListView.separated(
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemCount: user.publishedPlans.length,
              itemBuilder: (context, index) {
                PublishedExercisePlan plan = user.publishedPlans[index];
                int likes = plan.likedBy.length;
                int numComments = plan.comments.length;

                return ListTile(
                  onTap: () async {
                    ref.read(publishedExercisePlanProvider.notifier).setPlan(
                        CompletedExercisePlan(
                            planName: plan.planName,
                            dayToExercisesMap: plan.dayToExercisesMap,
                            lastUsed: DateTime.now()));

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return PublishedPlanPage(exercisePlan: plan);
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

                                  ref
                                      .read(publishedPlanPageProvider.notifier)
                                      .update();
                                },
                                onUnlikeClicked: () async {
                                  await ref
                                      .read(profilePageProvider.notifier)
                                      .unlikeExercisePlan(plan.id);

                                  ref
                                      .read(publishedPlanPageProvider.notifier)
                                      .update();
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
                                    .read(
                                        publishedExercisePlanProvider.notifier)
                                    .setPlan(CompletedExercisePlan(
                                        planName: plan.planName,
                                        dayToExercisesMap:
                                            plan.dayToExercisesMap,
                                        lastUsed: DateTime.now()));

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return PublishedPlanPage(
                                          exercisePlan: plan);
                                    },
                                  ),
                                );
                              },
                              icon: const Icon(Icons.comment),
                            ),
                            Text(
                              numComments.toString(),
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
              },
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
          appBar: AppBar(),
          body: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/providers/published_exercise_plan_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/widgets/published_plan_tile.dart';
import 'package:frontend/widgets/sort_dropdown.dart';

class AllPublishedPlansPage extends StatelessWidget {
  const AllPublishedPlansPage({required this.uid, super.key});

  final String uid;

  int _sortByMostRecent(
      PublishedExercisePlan plan1, PublishedExercisePlan plan2) {
    return plan2.dateCreated.compareTo(plan1.dateCreated);
  }

  int _sortByMostLiked(
      PublishedExercisePlan plan1, PublishedExercisePlan plan2) {
    if (plan1.likedBy.length < plan2.likedBy.length) {
      return 1;
    } else if (plan1.likedBy.length > plan2.likedBy.length) {
      return -1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    SortByOptions sortBy = SortByOptions.mostLiked;

    return Consumer(
      builder: (context, ref, child) {
        final user = ref.watch(
          userNotifierProvider(uid),
        );

        return user.when(
          data: (data) {
            final List<PublishedExercisePlan> publishedPlans = [];
            for (final plan in data.publishedPlans) {
              publishedPlans.add(
                ref.watch(
                  publishedExercisePlanNotifierProvider(
                      plan.creatorUserId, plan.id),
                ),
              );
            }

            return StatefulBuilder(
              builder: (context, setState) {
                publishedPlans.sort(
                  sortBy == SortByOptions.mostLiked
                      ? _sortByMostLiked
                      : _sortByMostRecent,
                );

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Published Plans'),
                  ),
                  body: ListView.builder(
                    itemCount: publishedPlans.length + 1,
                    itemBuilder: (context, index) {
                      return index == 0
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  Text('Plans (${publishedPlans.length})'),
                                  const Spacer(),
                                  SortDropdown(
                                    value: sortBy,
                                    onMostLikedSelected: () {
                                      setState(
                                        () {
                                          sortBy = SortByOptions.mostLiked;
                                        },
                                      );
                                    },
                                    onMostRecentSelected: () {
                                      setState(
                                        () {
                                          sortBy = SortByOptions.mostRecent;
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            )
                          : Card(
                              margin: EdgeInsets.zero,
                              child: PublishedPlanTile(
                                planCreatorId:
                                    publishedPlans[index - 1].creatorUserId,
                                planId: publishedPlans[index - 1].id,
                                planName: publishedPlans[index - 1].planName,
                                onDelete: uid ==
                                        userRepository.getCurrentUserId()
                                    ? () {
                                        ref
                                            .read(
                                              userNotifierProvider(uid)
                                                  .notifier,
                                            )
                                            .deleteExercisePlan(
                                                publishedPlans[index - 1].id);
                                      }
                                    : null,
                              ),
                            );
                    },
                  ),
                );
              },
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
    );
  }
}

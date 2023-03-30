import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/exercise_plans.dart';
import 'package:frontend/models/week.dart';
import 'package:frontend/providers/saved_exercise_list_provider.dart';
import 'package:uuid/uuid.dart';

class DownloadPlanButton extends ConsumerWidget {
  const DownloadPlanButton({required this.plan, super.key});

  final PublishedExercisePlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () async {
        await ref
            .read(
              savedExerciseListProvider.notifier,
            )
            .saveCompletedExercisePlanToDevice(
              SavedExercisePlan(
                id: const Uuid().v4(),
                planName: plan.planName,
                dayToExercisesMap: plan.dayToExercisesMap,
                lastUsed: DateTime.now(),
                weeks: const [
                  Week(
                    workouts: [],
                  ),
                ],
              ),
            );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                duration: const Duration(seconds: 1),
                content: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Successfully saved "${plan.planName}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF146E0E),
                dismissDirection: DismissDirection.none,
                elevation: 100),
          );
        }
      },
      icon: const Icon(Icons.download),
    );
  }
}

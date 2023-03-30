import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/user_exception.dart';
import 'package:frontend/providers/saved_exercise_plan_provider.dart';
import 'package:frontend/screens/week_page.dart';
import 'package:frontend/utils/validate_saved_plan.dart';
import 'package:frontend/widgets/yes_no_dialog.dart';

class NewSavedPlanPage extends ConsumerWidget {
  const NewSavedPlanPage({required this.exercisePlanId, super.key});

  final String exercisePlanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(
      savedExercisePlanNotifierProvider(exercisePlanId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.planName),
      ),
      body: ListView.builder(
        itemCount: plan.weeks.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return WeekPage(
                        exercisePlanId: exercisePlanId, weekNumber: index + 1);
                  },
                ),
              );
            },
            child: Card(
              color: index == plan.weeks.length - 1
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text('Week ${index + 1}'),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? canAddWeek;

          if (plan.weeks.isEmpty) {
            canAddWeek = true;
          } else if (plan.weeks.last.workouts.isEmpty) {
            UserException(
                    message: 'Week ${plan.weeks.length} must not be empty.')
                .displayException(context);
          } else if (plan.weeks.last.workouts.last.dateCompleted != null) {
            canAddWeek = true;
          } else {
            final lastWorkout = plan.weeks.last.workouts.last;

            canAddWeek = await showDialog<bool>(
              context: context,
              builder: (context) {
                return YesNoDialog(
                  title: ListTile(
                    title: Text(
                        'You must complete "${lastWorkout.day}" for Week ${plan.weeks.length} before beginning a new week.'),
                    subtitle: Text(
                        'Would you like to complete "${lastWorkout.day}"?'),
                  ),
                  onNoPressed: () {
                    Navigator.pop(context, false);
                  },
                  onYesPressed: () async {
                    UserException? exception = validateWorkout(lastWorkout);

                    if (exception != null) {
                      exception.displayException(context);
                      Navigator.pop(context, false);
                    } else {
                      await ref
                          .read(
                              SavedExercisePlanNotifierProvider(exercisePlanId)
                                  .notifier)
                          .completeWorkout(
                              lastWorkout.id, plan.weeks.length - 1);

                      if (context.mounted) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                );
              },
            );
          }

          if (canAddWeek == true) {
            ref
                .read(
                    savedExercisePlanNotifierProvider(exercisePlanId).notifier)
                .addWeek();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

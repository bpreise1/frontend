import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/user_exception.dart';
import 'package:frontend/models/workout.dart';
import 'package:frontend/providers/saved_exercise_plan_provider.dart';
import 'package:frontend/screens/workout_page.dart';
import 'package:frontend/utils/validate_saved_plan.dart';
import 'package:frontend/widgets/yes_no_dialog.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class WeekPage extends ConsumerWidget {
  const WeekPage(
      {required this.exercisePlanId, required this.weekNumber, super.key});

  final String exercisePlanId;
  final int weekNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(
      savedExercisePlanNotifierProvider(exercisePlanId),
    );
    final week = plan.weeks[weekNumber - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Week ${weekNumber.toString()}',
        ),
      ),
      body: ListView.builder(
        itemCount: week.workouts.length,
        itemBuilder: (context, index) {
          final workout = week.workouts[index];

          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return WorkoutPage(
                      exercisePlanId: exercisePlanId,
                      workoutId: workout.id,
                      weekIndex: weekNumber - 1,
                    );
                  },
                ),
              );
            },
            child: Card(
              color: workout.dateCompleted == null
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text(workout.day),
                    const Spacer(),
                    if (workout.dateCompleted != null)
                      Text(
                        DateFormat('M/d/yyyy').format(
                          workout.dateCompleted!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: weekNumber == plan.weeks.length
          ? FloatingActionButton(
              onPressed: () async {
                bool? canAddWorkout;
                if (week.workouts.isEmpty ||
                    week.workouts.last.dateCompleted != null) {
                  canAddWorkout = true;
                } else {
                  canAddWorkout = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return YesNoDialog(
                        title: ListTile(
                          title: Text(
                              'You must complete "${week.workouts.last.day}" before beginning a new workout.'),
                          subtitle: Text(
                              'Would you like to complete "${week.workouts.last.day}"?'),
                        ),
                        onNoPressed: () {
                          return Navigator.pop(context, false);
                        },
                        onYesPressed: () async {
                          UserException? exception =
                              validateWorkout(week.workouts.last);

                          if (exception != null) {
                            exception.displayException(context);
                            Navigator.pop(context, false);
                          } else {
                            await ref
                                .read(SavedExercisePlanNotifierProvider(
                                        exercisePlanId)
                                    .notifier)
                                .completeWorkout(
                                    week.workouts.last.id, weekNumber - 1);
                            if (context.mounted) {
                              Navigator.pop(context, true);
                            }
                          }
                        },
                      );
                    },
                  );
                }

                String? day;
                if (canAddWorkout == true && context.mounted) {
                  day = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: const Text('Select Day'),
                        children: [
                          for (final day in plan.dayToExercisesMap.keys)
                            SimpleDialogOption(
                              onPressed: () {
                                Navigator.pop(context, day);
                              },
                              child: Text(day),
                            )
                        ],
                      );
                    },
                  );
                }

                if (day != null) {
                  await ref
                      .read(
                        savedExercisePlanNotifierProvider(exercisePlanId)
                            .notifier,
                      )
                      .addWorkout(
                          Workout(
                            id: const Uuid().v4(),
                            day: day,
                            exercises: plan.dayToExercisesMap[day]!,
                            dateCompleted: null,
                          ),
                          weekNumber - 1);
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

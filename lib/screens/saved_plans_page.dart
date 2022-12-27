import 'package:flutter/material.dart';
import 'package:frontend/repository/completed_exercise_plan_repository.dart';

class SavedPlansPage extends StatelessWidget {
  const SavedPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: completedExercisePlanRepository
            .getCompletedExercisePlansFromDevice(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView(
              children: snapshot.data!
                  .map((exercisePlan) => Text(exercisePlan.planName))
                  .toList(),
            );
          } else {
            return const CircularProgressIndicator();
          }
        }));
  }
}

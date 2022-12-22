import 'package:flutter/material.dart';
import 'package:frontend/providers/exercise_plan_provider.dart';

const List<Exercise> allExercises = [
  Exercise(
      name: 'Bench Press',
      description: 'Bench Press description',
      image: AssetImage('assets/bench_press.jpeg')),
  Exercise(
      name: 'Bench Press 2',
      description: 'Bench Press description 2',
      image: AssetImage('assets/bench_press.jpeg')),
  Exercise(
      name: 'Deadlift',
      description: 'Hard fucking lift',
      image: AssetImage('assets/deadlift.png'))
];

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/date_time_exercise.dart';
import 'package:frontend/models/user_preferences.dart';
import 'package:frontend/providers/user_preferences_provider.dart';
import 'package:frontend/utils/convert_weight.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExerciseLineGraph extends ConsumerWidget {
  const ExerciseLineGraph({required this.exercises, super.key});

  final List<DateTimeExercise> exercises;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPreferences = ref.watch(userPreferencesProvider);

    return userPreferences.when(
        data: ((preferences) => SfCartesianChart(
            title: ChartTitle(text: exercises[0].name),
            primaryXAxis: DateTimeAxis(
                visibleMinimum: exercises[0].dateTime,
                intervalType: DateTimeIntervalType.days,
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                title: AxisTitle(text: 'Date')),
            primaryYAxis: NumericAxis(
                title: AxisTitle(
                    text:
                        'Volume ${preferences.weightMode == WeightMode.pounds ? '(Pounds)' : '(Kilograms)'}')),
            series: <ChartSeries>[
              FastLineSeries<DateTimeExercise, DateTime>(
                  name: 'Volume',
                  enableTooltip: true,
                  markerSettings: const MarkerSettings(isVisible: true),
                  dataSource: exercises,
                  xValueMapper: (DateTimeExercise data, _) => data.dateTime,
                  yValueMapper: (DateTimeExercise data, _) =>
                      preferences.weightMode == WeightMode.pounds
                          ? data.getVolume()
                          : double.parse(
                              convertWeightToKilograms(data.getVolume())
                                  .toStringAsFixed(2))),
            ],
            tooltipBehavior: TooltipBehavior(enable: true),
            onTooltipRender: (tooltipArgs) {
              int? index = tooltipArgs.pointIndex?.toInt();
              String? tooltipText = tooltipArgs.text;

              if (index != null && tooltipText != null) {
                String newText = '$tooltipText\n';
                DateTimeExercise exercise = exercises[index];
                for (int set = 1; set < int.parse(exercise.sets) + 1; set++) {
                  newText +=
                      "\nSet $set: ${exercise.reps[set]} x ${preferences.weightMode == WeightMode.pounds ? exercise.weights[set] : convertWeightToKilograms(double.parse(exercise.weights[set])).toStringAsFixed(2)}";
                }
                tooltipArgs.text = newText;
              }
            })),
        error: ((error, stackTrace) => Center(child: Text(error.toString()))),
        loading: () => const CircularProgressIndicator());
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/models/date_time_exercise.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExerciseLineGraph extends StatelessWidget {
  const ExerciseLineGraph({required this.exercises, super.key});

  final List<DateTimeExercise> exercises;

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
        title: ChartTitle(text: exercises[0].name),
        primaryXAxis: DateTimeAxis(
            visibleMinimum: exercises[0].dateTime,
            intervalType: DateTimeIntervalType.days,
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            title: AxisTitle(text: 'Date')),
        series: <ChartSeries>[
          FastLineSeries<DateTimeExercise, DateTime>(
              name: 'Volume',
              enableTooltip: true,
              markerSettings: const MarkerSettings(isVisible: true),
              dataSource: exercises,
              xValueMapper: (DateTimeExercise data, _) => data.dateTime,
              yValueMapper: (DateTimeExercise data, _) => data.getVolume()),
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
                  "\nSet $set: ${exercise.reps[set]}x${exercise.weights[set]}";
            }
            tooltipArgs.text = newText;
          }
        });
  }
}

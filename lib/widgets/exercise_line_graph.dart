import 'package:flutter/material.dart';
import 'package:frontend/models/exercise.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExerciseData {
  const ExerciseData({required this.year, required this.volume});

  final double year;
  final double volume;
}

class ExerciseLineGraph extends StatelessWidget {
  const ExerciseLineGraph({required this.exercises, super.key});

  final List<Exercise> exercises;

  List<ExerciseData> _getExerciseData() {
    double year = 0;
    return exercises
        .map((exercise) => ExerciseData(
            year: ++year,
            volume: double.parse(exercise.sets) *
                double.parse(exercise.weights[1])))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    print(exercises[1].name);
    return SfCartesianChart(
        series: <ChartSeries>[
          FastLineSeries<ExerciseData, double>(
              enableTooltip: true,
              markerSettings: const MarkerSettings(isVisible: true),
              dataSource: _getExerciseData(),
              xValueMapper: (ExerciseData data, _) => data.year,
              yValueMapper: (ExerciseData data, _) => data.volume),
        ],
        primaryXAxis: NumericAxis(edgeLabelPlacement: EdgeLabelPlacement.shift),
        tooltipBehavior: TooltipBehavior(enable: true));
  }
}

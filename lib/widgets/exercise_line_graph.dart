import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/date_time_exercise.dart';
import 'package:frontend/models/user_preferences.dart';
import 'package:frontend/providers/user_preferences_provider.dart';
import 'package:frontend/utils/convert_weight.dart';
import 'package:intl/intl.dart';
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
                labelIntersectAction: AxisLabelIntersectAction.hide,
                tickPosition: TickPosition.inside,
                visibleMinimum: exercises[0].dateTime,
                axisLabelFormatter: (axisLabelRenderArgs) {
                  DateTime date = DateTime.fromMillisecondsSinceEpoch(
                      axisLabelRenderArgs.value.toInt());

                  String formattedDate = "";
                  switch (axisLabelRenderArgs.currentDateTimeIntervalType) {
                    case DateTimeIntervalType.auto:
                      formattedDate = DateFormat('MMMd').format(date);
                      break;
                    case DateTimeIntervalType.years:
                      formattedDate = DateFormat('y').format(date);
                      break;
                    case DateTimeIntervalType.months:
                      formattedDate = DateFormat('MMM').format(date);
                      break;
                    case DateTimeIntervalType.days:
                      formattedDate = DateFormat('MMMd').format(date);
                      break;
                    case DateTimeIntervalType.hours:
                      formattedDate =
                          '${DateFormat('MMMd').format(date)}\n${DateFormat('j').format(date)}';
                      break;
                    case DateTimeIntervalType.minutes:
                      formattedDate =
                          '${DateFormat('MMMd').format(date)}\n${DateFormat('jm').format(date)}';
                      break;
                    case DateTimeIntervalType.seconds:
                      formattedDate =
                          '${DateFormat('MMMd').format(date)}\n${DateFormat('jms').format(date)}';
                      break;
                    case DateTimeIntervalType.milliseconds:
                      formattedDate =
                          '${DateFormat('MMMd').format(date)}\n${DateFormat('jms').format(date)}';
                      break;
                    default:
                      formattedDate = '';
                  }

                  return ChartAxisLabel(formattedDate, const TextStyle());
                },
                minorTicksPerInterval: 1,
                intervalType: DateTimeIntervalType.auto,
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                title: AxisTitle(text: 'Date')),
            primaryYAxis: NumericAxis(
                tickPosition: TickPosition.inside,
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

              if (index != null) {
                DateTimeExercise exercise = exercises[index];
                String newText = 'Volume: ${exercise.getVolume()}\n';
                for (int set = 0; set < int.parse(exercise.sets); set++) {
                  if (exercise.reps[set] == '' || exercise.weights[set] == '') {
                    newText += "\nSet ${set + 1}: _";
                  } else {
                    newText +=
                        "\nSet $set: ${exercise.reps[set]} x ${preferences.weightMode == WeightMode.pounds ? exercise.weights[set] : convertWeightToKilograms(double.parse(exercise.weights[set])).toStringAsFixed(2)}";
                  }
                }
                tooltipArgs.header =
                    DateFormat('MMMd').format(exercise.dateTime);
                tooltipArgs.text = newText;
              }
            })),
        error: ((error, stackTrace) => Center(child: Text(error.toString()))),
        loading: () => const CircularProgressIndicator());
  }
}

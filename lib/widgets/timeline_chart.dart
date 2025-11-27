import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:spotify_insights/models/analytics_snapshot.dart';
import 'package:spotify_insights/theme/app_theme.dart';
import 'package:spotify_insights/widgets/chart_config.dart';

class TimelineChart extends StatelessWidget {
  final List<MonthlyAdditions> additions;

  const TimelineChart({super.key, required this.additions});

  @override
  Widget build(BuildContext context) {
    if (additions.isEmpty) return emptyChart();

    final displayAdditions = additions.length > 24
        ? additions.sublist(additions.length - 24)
        : additions;

    final maxY = displayAdditions
        .map((a) => a.trackCount)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Container(
      height: 220,
      decoration: AppComponents.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tracks Added Per Month', style: AppTypography.labelMedium),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.1,
                barGroups: barGroups(displayAdditions),
                gridData: ChartConfig.grid(),
                borderData: ChartConfig.border(),
                titlesData: ChartConfig.titlesData(
                  bottomTitles: (value, meta) => bottomTitle(value, displayAdditions),
                  leftTitles: (value, meta) => leftTitle(value, maxY),
                  bottomReservedSize: 40,
                ),
                barTouchData: ChartConfig.barTouchData(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyChart() {
    return Container(
      height: 200,
      decoration: AppComponents.card,
      child: Center(
        child: Text('No timeline data', style: AppTypography.bodySmall),
      ),
    );
  }

  List<BarChartGroupData> barGroups(List<MonthlyAdditions> data) {
    return data.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.trackCount.toDouble(),
            gradient: LinearGradient(
              colors: ChartConfig.gradientColors(),
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: data.length > 12 ? 8 : 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget bottomTitle(double value, List<MonthlyAdditions> data) {
    final index = value.toInt();
    if (index < 0 || index >= data.length) return const SizedBox.shrink();

    final interval = (data.length / 6).ceil();
    if (index % interval != 0 && index != data.length - 1) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Transform.rotate(
        angle: -0.5,
        child: Text(
          data[index].monthLabel,
          style: AppTypography.caption.copyWith(fontSize: 10),
        ),
      ),
    );
  }

  Widget leftTitle(double value, double maxY) {
    if (value == 0 || value == maxY.roundToDouble()) {
      return Text(
        value.toInt().toString(),
        style: AppTypography.caption.copyWith(fontSize: 10),
      );
    }
    return const SizedBox.shrink();
  }
}


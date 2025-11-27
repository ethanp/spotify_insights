import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:spotify_insights/theme/app_theme.dart';

class ChartConfig {
  static FlGridData grid() => FlGridData(
    show: true,
    drawVerticalLine: true,
    horizontalInterval: 1,
    verticalInterval: 1,
    getDrawingHorizontalLine: (value) => FlLine(
      color: AppColors.borderDepth1.withValues(alpha: 0.3),
      strokeWidth: 0.5,
    ),
    getDrawingVerticalLine: (value) => FlLine(
      color: AppColors.borderDepth1.withValues(alpha: 0.3),
      strokeWidth: 0.5,
    ),
  );

  static FlBorderData border() => FlBorderData(
    show: true,
    border: Border.all(
      color: AppColors.borderDepth1.withValues(alpha: 0.4),
      width: 0.5,
    ),
  );

  static FlTitlesData titlesData({
    required Widget Function(double, TitleMeta) bottomTitles,
    Widget Function(double, TitleMeta)? leftTitles,
    double? bottomReservedSize,
    double? leftReservedSize,
  }) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: bottomReservedSize ?? 30,
          getTitlesWidget: bottomTitles,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: leftTitles != null,
          reservedSize: leftReservedSize ?? 40,
          getTitlesWidget: leftTitles ?? (_, __) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  static LineTouchData lineTouchData() => LineTouchData(
    touchTooltipData: LineTouchTooltipData(
      getTooltipColor: (_) => AppColors.backgroundDepth3,
      getTooltipItems: (touchedSpots) => touchedSpots
          .map((spot) => LineTooltipItem(
                '${spot.y.toInt()}',
                AppTypography.labelMedium,
              ))
          .toList(),
    ),
  );

  static BarTouchData barTouchData() => BarTouchData(
    touchTooltipData: BarTouchTooltipData(
      getTooltipColor: (_) => AppColors.backgroundDepth3,
      getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
        '${rod.toY.toInt()}',
        AppTypography.labelMedium,
      ),
    ),
  );

  static List<Color> gradientColors() => [
    AppColors.primary,
    AppColors.primaryLight,
  ];
}


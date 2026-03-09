import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pomodorofocus/data/models/statistics_models.dart';
import 'package:sizer/sizer.dart';

class LineChartWidget extends StatefulWidget {
  final List<TimeBucketStat> data;

  const LineChartWidget({super.key, required this.data});

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxMinutes = widget.data.fold<int>(
      0,
      (max, stat) => stat.focusMinutes > max ? stat.focusMinutes : max,
    );
    final maxY = (maxMinutes + 50).toDouble();

    return Container(
      width: double.infinity,
      height: 22.h,
      padding: EdgeInsets.fromLTRB(2.w, 2.w, 2.w, 1.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Semantics(
        label: 'Line chart showing focus time trend in minutes',
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: theme.colorScheme.primary.withValues(
                  alpha: 0.9,
                ),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final index = spot.x.toInt();
                    final label = index < widget.data.length
                        ? widget.data[index].label
                        : '';
                    return LineTooltipItem(
                      '$label\n${spot.y.toInt()} min',
                      TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= widget.data.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.data[index].label,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) {
                    if (value % 50 != 0) return const SizedBox.shrink();
                    return Text(
                      '${value.toInt()}m',
                      style: TextStyle(
                        fontSize: 8.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: theme.dividerColor, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(
                  widget.data.length,
                  (index) => FlSpot(
                    index.toDouble(),
                    widget.data[index].focusMinutes.toDouble(),
                  ),
                ),
                isCurved: true,
                color: theme.colorScheme.tertiary,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                        radius: 3,
                        color: theme.colorScheme.tertiary,
                        strokeWidth: 1.5,
                        strokeColor: theme.cardColor,
                      ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

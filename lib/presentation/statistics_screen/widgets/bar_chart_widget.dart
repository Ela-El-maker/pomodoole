import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pomodorofocus/data/models/statistics_models.dart';
import 'package:sizer/sizer.dart';

class BarChartWidget extends StatefulWidget {
  final List<TimeBucketStat> data;

  const BarChartWidget({super.key, required this.data});

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxSessions = widget.data.fold<int>(
      0,
      (max, stat) => stat.sessions > max ? stat.sessions : max,
    );
    final maxY = (maxSessions + 2).toDouble();

    return Container(
      width: double.infinity,
      height: 22.h,
      padding: EdgeInsets.all(2.w),
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
        label: 'Bar chart showing daily session counts',
        child: BarChart(
          BarChartData(
            maxY: maxY,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: theme.colorScheme.primary.withValues(
                  alpha: 0.9,
                ),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${widget.data[groupIndex].label}\n${rod.toY.toInt()} sessions',
                    TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
              touchCallback: (event, response) {
                setState(() {
                  _touchedIndex = response?.spot?.touchedBarGroupIndex;
                });
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
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
                  reservedSize: 24,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    if (value % 2 != 0) return const SizedBox.shrink();
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 9.sp,
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
            barGroups: List.generate(widget.data.length, (index) {
              final isTouched = _touchedIndex == index;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: widget.data[index].sessions.toDouble(),
                    color: isTouched
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.primary,
                    width: 3.w,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

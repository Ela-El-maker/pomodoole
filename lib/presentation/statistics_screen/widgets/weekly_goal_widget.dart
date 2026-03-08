import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sizer/sizer.dart';

class WeeklyGoalWidget extends StatelessWidget {
  final int completedSessions;
  final int goalSessions;

  const WeeklyGoalWidget({
    super.key,
    required this.completedSessions,
    required this.goalSessions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (completedSessions / goalSessions).clamp(0.0, 1.0);
    final remaining = goalSessions - completedSessions;

    return Container(
      padding: EdgeInsets.all(4.w),
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
      child: Row(
        children: [
          SizedBox(
            width: 18.w,
            height: 18.w,
            child: Semantics(
              label:
                  'Weekly goal progress: $completedSessions of $goalSessions sessions completed',
              child: PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  sectionsSpace: 0,
                  centerSpaceRadius: 6.w,
                  sections: [
                    PieChartSectionData(
                      value: progress * 100,
                      color: theme.colorScheme.primary,
                      radius: 3.w,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: (1 - progress) * 100,
                      color: theme.dividerColor,
                      radius: 3.w,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Goal',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '$completedSessions / $goalSessions sessions',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  remaining > 0
                      ? '$remaining more to reach your goal!'
                      : 'Goal achieved! 🎉',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

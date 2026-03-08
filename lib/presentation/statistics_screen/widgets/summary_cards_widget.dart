import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SummaryCardsWidget extends StatelessWidget {
  final int todaySessions;
  final int currentStreak;
  final int totalFocusMinutes;

  const SummaryCardsWidget({
    super.key,
    required this.todaySessions,
    required this.currentStreak,
    required this.totalFocusMinutes,
  });

  String _formatFocusTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: "Today",
            value: '$todaySessions',
            subtitle: 'sessions',
            iconName: 'timer',
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _SummaryCard(
            title: "Streak",
            value: '$currentStreak',
            subtitle: 'days',
            iconName: 'local_fire_department',
            color: const Color(0xFFFF6B35),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _SummaryCard(
            title: "Focus",
            value: _formatFocusTime(totalFocusMinutes),
            subtitle: 'total',
            iconName: 'access_time',
            color: const Color(0xFF27AE60),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String iconName;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.iconName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomIconWidget(iconName: iconName, color: color, size: 20),
          SizedBox(height: 0.8.h),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 16.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

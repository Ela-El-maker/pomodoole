import 'package:flutter/material.dart';
import 'package:pomodorofocus/data/models/statistics_models.dart';
import 'package:sizer/sizer.dart';

class ReflectionsSectionWidget extends StatelessWidget {
  const ReflectionsSectionWidget({super.key, required this.summary});

  final ReflectionSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reflections',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reflections This Week: ${summary.weeklyReflectionCount}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Mood Distribution',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.8.h),
              if (summary.moodBreakdown.isEmpty)
                Text(
                  'No reflections yet this week.',
                  style: theme.textTheme.bodySmall,
                )
              else
                Wrap(
                  spacing: 2.w,
                  runSpacing: 0.8.h,
                  children: summary.moodBreakdown
                      .map(
                        (item) => Chip(
                          label: Text(
                            '${item.mood}: ${item.count} (${(item.percentage * 100).round()}%)',
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TimerDurationSectionWidget extends StatelessWidget {
  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final VoidCallback onWorkDurationTap;
  final VoidCallback onShortBreakTap;
  final VoidCallback onLongBreakTap;

  const TimerDurationSectionWidget({
    super.key,
    required this.workDuration,
    required this.shortBreakDuration,
    required this.longBreakDuration,
    required this.onWorkDurationTap,
    required this.onShortBreakTap,
    required this.onLongBreakTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        children: [
          _buildDurationRow(
            context: context,
            theme: theme,
            iconName: 'work_outline',
            label: 'Work Session',
            value: workDuration,
            onTap: onWorkDurationTap,
            showDivider: true,
          ),
          _buildDurationRow(
            context: context,
            theme: theme,
            iconName: 'free_breakfast',
            label: 'Short Break',
            value: shortBreakDuration,
            onTap: onShortBreakTap,
            showDivider: true,
          ),
          _buildDurationRow(
            context: context,
            theme: theme,
            iconName: 'weekend',
            label: 'Long Break',
            value: longBreakDuration,
            onTap: onLongBreakTap,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDurationRow({
    required BuildContext context,
    required ThemeData theme,
    required String iconName,
    required String label,
    required int value,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: iconName,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$value min',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 2.w),
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        showDivider
            ? Divider(
                height: 1,
                indent: 4.w,
                endIndent: 4.w,
                color: theme.dividerColor,
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}

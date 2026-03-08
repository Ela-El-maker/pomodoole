import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class VibrationSettingsSectionWidget extends StatelessWidget {
  final bool vibrationEnabled;
  final bool completionVibration;
  final ValueChanged<bool> onVibrationToggle;
  final ValueChanged<bool> onCompletionVibrationToggle;

  const VibrationSettingsSectionWidget({
    super.key,
    required this.vibrationEnabled,
    required this.completionVibration,
    required this.onVibrationToggle,
    required this.onCompletionVibrationToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'vibration',
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Haptic Feedback',
                        style: theme.textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Vibrate on session transitions',
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Switch(value: vibrationEnabled, onChanged: onVibrationToggle),
              ],
            ),
          ),
          Divider(
            height: 1,
            indent: 4.w,
            endIndent: 4.w,
            color: theme.dividerColor,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle_outline',
                  color: vibrationEnabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.4,
                        ),
                  size: 22,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Completion Alert',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: vibrationEnabled
                              ? null
                              : theme.colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.4,
                                ),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Vibrate when session completes',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: vibrationEnabled
                              ? null
                              : theme.colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.4,
                                ),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: completionVibration && vibrationEnabled,
                  onChanged: vibrationEnabled
                      ? onCompletionVibrationToggle
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

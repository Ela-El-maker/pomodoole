import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AudioPreferencesSectionWidget extends StatelessWidget {
  final bool soundEnabled;
  final double volume;
  final String selectedSound;
  final ValueChanged<bool> onSoundToggle;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<double> onVolumeChangeEnd;
  final VoidCallback onSoundPickerTap;

  const AudioPreferencesSectionWidget({
    super.key,
    required this.soundEnabled,
    required this.volume,
    required this.selectedSound,
    required this.onSoundToggle,
    required this.onVolumeChanged,
    required this.onVolumeChangeEnd,
    required this.onSoundPickerTap,
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
                  iconName: 'notifications_active',
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Notification Sounds',
                    style: theme.textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Switch(value: soundEnabled, onChanged: onSoundToggle),
              ],
            ),
          ),
          Divider(
            height: 1,
            indent: 4.w,
            endIndent: 4.w,
            color: theme.dividerColor,
          ),
          InkWell(
            onTap: soundEnabled ? onSoundPickerTap : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'music_note',
                    color: soundEnabled
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.4,
                          ),
                    size: 22,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Sound',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: soundEnabled
                            ? null
                            : theme.colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.4,
                              ),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    selectedSound,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: soundEnabled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.4,
                            ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  CustomIconWidget(
                    iconName: 'chevron_right',
                    color: soundEnabled
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.4,
                          ),
                    size: 20,
                  ),
                ],
              ),
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
                  iconName: 'volume_up',
                  color: soundEnabled
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
                        'Volume',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: soundEnabled
                              ? null
                              : theme.colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.4,
                                ),
                        ),
                      ),
                      Slider(
                        value: volume,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        onChanged: soundEnabled ? onVolumeChanged : null,
                        onChangeEnd: soundEnabled ? onVolumeChangeEnd : null,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(volume * 100).round()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: soundEnabled
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.4,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

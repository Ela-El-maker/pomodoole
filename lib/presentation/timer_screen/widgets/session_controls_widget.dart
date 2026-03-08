import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SessionControlsWidget extends StatelessWidget {
  final bool isRunning;
  final bool isPaused;
  final Color sessionColor;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final FocusNode? startFocusNode;
  final FocusNode? stopFocusNode;

  const SessionControlsWidget({
    super.key,
    required this.isRunning,
    required this.isPaused,
    required this.sessionColor,
    required this.onStart,
    required this.onPause,
    required this.onStop,
    this.startFocusNode,
    this.stopFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Focus(
            focusNode: startFocusNode,
            child: Builder(
              builder: (ctx) {
                final hasFocus = Focus.of(ctx).hasFocus;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: hasFocus
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFA8C3A0),
                            width: 2,
                          ),
                        )
                      : null,
                  child: SizedBox(
                    height: 7.h,
                    child: ElevatedButton(
                      onPressed: isRunning ? onPause : onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sessionColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: isRunning
                                ? 'pause'
                                : (isPaused ? 'play_arrow' : 'play_arrow'),
                            color: Colors.white,
                            size: 26,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            isRunning
                                ? 'Pause'
                                : (isPaused ? 'Resume' : 'Start'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Focus(
          focusNode: stopFocusNode,
          child: Builder(
            builder: (ctx) {
              final hasFocus = Focus.of(ctx).hasFocus;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: hasFocus
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFA8C3A0),
                          width: 2,
                        ),
                      )
                    : null,
                child: SizedBox(
                  height: 7.h,
                  width: 7.h,
                  child: Semantics(
                    label: 'End session',
                    hint: 'Press Escape to end session',
                    button: true,
                    child: OutlinedButton(
                      onPressed: (isRunning || isPaused) ? onStop : null,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: (isRunning || isPaused)
                              ? theme.colorScheme.error
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: CustomIconWidget(
                        iconName: 'stop',
                        color: (isRunning || isPaused)
                            ? theme.colorScheme.error
                            : theme.colorScheme.outline.withValues(alpha: 0.4),
                        size: 26,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

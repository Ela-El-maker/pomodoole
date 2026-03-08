import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SessionInfoWidget extends StatelessWidget {
  final int sessionInCycle;
  final String sessionLabel;
  final Color sessionColor;

  const SessionInfoWidget({
    super.key,
    required this.sessionInCycle,
    required this.sessionLabel,
    required this.sessionColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          'Session $sessionInCycle of 4',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final isActive = index < sessionInCycle;
            final isCurrent = index == sessionInCycle - 1;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              width: isCurrent ? 24 : 12,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? sessionColor
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

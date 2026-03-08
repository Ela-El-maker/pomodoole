import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TaskEmptyStateWidget extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onAddTask;

  const TaskEmptyStateWidget({
    super.key,
    required this.isSearching,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: isSearching ? 'search_off' : 'checklist',
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  size: 48,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              isSearching ? 'No tasks found' : 'No tasks yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              isSearching
                  ? 'Try a different search term'
                  : 'Create your first task and start\nfocusing with Pomodoro sessions!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isSearching) ...[
              SizedBox(height: 3.h),
              ElevatedButton.icon(
                onPressed: onAddTask,
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text('Add Your First Task'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

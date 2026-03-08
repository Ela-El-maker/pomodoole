import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TaskInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String currentTask;

  const TaskInputWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.currentTask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: 1,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'What are you working on?',
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: CustomIconWidget(
              iconName: 'edit_note',
              color: theme.colorScheme.onSurfaceVariant,
              size: 22,
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 10.w),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 1.5.h,
          ),
        ),
      ),
    );
  }
}

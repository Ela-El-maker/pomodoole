import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AddTaskBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic>? existingTask;
  final Function(Map<String, dynamic>) onSave;

  const AddTaskBottomSheetWidget({
    super.key,
    this.existingTask,
    required this.onSave,
  });

  @override
  State<AddTaskBottomSheetWidget> createState() =>
      _AddTaskBottomSheetWidgetState();
}

class _AddTaskBottomSheetWidgetState extends State<AddTaskBottomSheetWidget> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late int _estimatedPomodoros;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingTask?["title"] as String? ?? '',
    );
    _descController = TextEditingController(
      text: widget.existingTask?["description"] as String? ?? '',
    );
    _estimatedPomodoros =
        widget.existingTask?["estimatedPomodoros"] as int? ?? 1;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave({
        "title": _titleController.text.trim(),
        "description": _descController.text.trim(),
        "estimatedPomodoros": _estimatedPomodoros,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.existingTask != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                isEdit ? 'Edit Task' : 'New Task',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task Title *'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Title is required'
                    : null,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 1,
              ),
              SizedBox(height: 1.5.h),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
              ),
              SizedBox(height: 2.h),
              Text('Estimated Pomodoros', style: theme.textTheme.titleSmall),
              SizedBox(height: 1.h),
              Row(
                children: [
                  IconButton(
                    onPressed: _estimatedPomodoros > 1
                        ? () => setState(() => _estimatedPomodoros--)
                        : null,
                    icon: CustomIconWidget(
                      iconName: 'remove_circle_outline',
                      color: _estimatedPomodoros > 1
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.4,
                            ),
                      size: 28,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          _estimatedPomodoros.clamp(0, 8),
                          (i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: CustomIconWidget(
                              iconName: 'timer',
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _estimatedPomodoros < 12
                        ? () => setState(() => _estimatedPomodoros++)
                        : null,
                    icon: CustomIconWidget(
                      iconName: 'add_circle_outline',
                      color: _estimatedPomodoros < 12
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.4,
                            ),
                      size: 28,
                    ),
                  ),
                  Text(
                    '$_estimatedPomodoros',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(isEdit ? 'Save Changes' : 'Add Task'),
                ),
              ),
              SizedBox(height: 1.h),
            ],
          ),
        ),
      ),
    );
  }
}

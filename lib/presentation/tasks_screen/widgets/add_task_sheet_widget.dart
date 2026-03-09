import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodorofocus/data/models/task_entity.dart';
import 'package:sizer/sizer.dart';

class AddTaskSheetWidget extends StatefulWidget {
  final TaskEntity? existingTask;
  final ValueChanged<TaskDraft> onSave;

  const AddTaskSheetWidget({
    super.key,
    this.existingTask,
    required this.onSave,
  });

  @override
  State<AddTaskSheetWidget> createState() => _AddTaskSheetWidgetState();
}

class _AddTaskSheetWidgetState extends State<AddTaskSheetWidget> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late int _estimatedSessions;
  DateTime? _dueAt;
  bool _reminderEnabled = false;
  DateTime? _reminderAt;
  final _formKey = GlobalKey<FormState>();

  static const Color _accentRed = Color(0xFFE76F6F);
  static const Color _bgColor = Color(0xFFF7F7F5);
  static const Color _cardBg = Color(0xFFF0EFEA);
  static const Color _primaryText = Color(0xFF2F2F2F);
  static const Color _secondaryText = Color(0xFF6F6F6F);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingTask?.title ?? '',
    );
    _notesController = TextEditingController(
      text: widget.existingTask?.notes ?? '',
    );
    _estimatedSessions = widget.existingTask?.estimatedPomodoros ?? 2;
    _dueAt = widget.existingTask?.dueAt;
    _reminderEnabled = widget.existingTask?.reminderEnabled ?? false;
    _reminderAt = widget.existingTask?.reminderAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final normalizedReminderAt = _reminderEnabled
          ? (_reminderAt ??
                _dueAt ??
                DateTime.now().add(const Duration(minutes: 1)))
          : null;
      widget.onSave(
        TaskDraft(
          title: _titleController.text.trim(),
          notes: _notesController.text.trim(),
          dueAt: _dueAt,
          reminderEnabled: _reminderEnabled,
          reminderAt: normalizedReminderAt,
          estimatedPomodoros: _estimatedSessions,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickDueDateTime() async {
    final now = DateTime.now();
    final initial = _dueAt ?? now.add(const Duration(hours: 1));
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null || !mounted) return;

    final picked = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _dueAt = picked;
      if (_reminderEnabled && _reminderAt == null) {
        _reminderAt = picked.subtract(const Duration(minutes: 10));
      }
    });
  }

  Future<void> _pickReminderDateTime() async {
    final now = DateTime.now();
    final initial =
        _reminderAt ?? _dueAt ?? now.add(const Duration(minutes: 30));
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      _reminderAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return 'Not set';
    final date =
        '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    final time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingTask != null;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _secondaryText.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isEdit ? 'Edit Task' : 'New Task 🌿',
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _primaryText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Task name
                  TextFormField(
                    controller: _titleController,
                    autofocus: !isEdit,
                    textCapitalization: TextCapitalization.sentences,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: _primaryText,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: 'What do you want to work on?',
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: _secondaryText.withValues(alpha: 0.6),
                      ),
                      filled: true,
                      fillColor: _cardBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0),
                        borderSide: BorderSide(
                          color: _accentRed.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter a task name'
                        : null,
                    maxLines: 1,
                  ),
                  SizedBox(height: 1.5.h),
                  // Notes
                  TextFormField(
                    controller: _notesController,
                    textCapitalization: TextCapitalization.sentences,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: _primaryText,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Notes (optional)',
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: _secondaryText.withValues(alpha: 0.6),
                      ),
                      filled: true,
                      fillColor: _cardBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0),
                        borderSide: BorderSide(
                          color: _accentRed.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 2.h),
                  // Estimated sessions
                  Text(
                    'Estimated sessions',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _secondaryText,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _estimatedSessions > 1
                              ? () => setState(() => _estimatedSessions--)
                              : null,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _estimatedSessions > 1
                                  ? _accentRed.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 18,
                              color: _estimatedSessions > 1
                                  ? _accentRed
                                  : _secondaryText.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _estimatedSessions.clamp(0, 8),
                              (i) => const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                child: Text(
                                  '🍅',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _estimatedSessions < 12
                              ? () => setState(() => _estimatedSessions++)
                              : null,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _estimatedSessions < 12
                                  ? _accentRed.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              size: 18,
                              color: _estimatedSessions < 12
                                  ? _accentRed
                                  : _secondaryText.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.6.h),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Due date',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _secondaryText,
                            ),
                          ),
                          subtitle: Text(
                            _formatDateTime(_dueAt),
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: _primaryText,
                            ),
                          ),
                          trailing: TextButton(
                            onPressed: _pickDueDateTime,
                            child: const Text('Set'),
                          ),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _reminderEnabled,
                          title: Text(
                            'One-shot reminder',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _secondaryText,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _reminderEnabled = value;
                              if (!_reminderEnabled) {
                                _reminderAt = null;
                              } else {
                                _reminderAt ??=
                                    (_dueAt ??
                                    DateTime.now().add(
                                      const Duration(minutes: 30),
                                    ));
                              }
                            });
                          },
                        ),
                        if (_reminderEnabled)
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Reminder time',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _secondaryText,
                              ),
                            ),
                            subtitle: Text(
                              _formatDateTime(_reminderAt),
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: _primaryText,
                              ),
                            ),
                            trailing: TextButton(
                              onPressed: _pickReminderDateTime,
                              child: const Text('Set'),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.5.h),
                  // Save button
                  GestureDetector(
                    onTap: _save,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _accentRed,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: _accentRed.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        isEdit ? 'Save Changes' : 'Add Task',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

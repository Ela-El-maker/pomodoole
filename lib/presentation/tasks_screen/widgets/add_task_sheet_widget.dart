import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AddTaskSheetWidget extends StatefulWidget {
  final Map<String, dynamic>? existingTask;
  final Function(Map<String, dynamic>) onSave;

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
      text: widget.existingTask?['title'] as String? ?? '',
    );
    _notesController = TextEditingController(
      text: widget.existingTask?['notes'] as String? ?? '',
    );
    _estimatedSessions =
        widget.existingTask?['estimatedPomodoros'] as int? ?? 2;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave({
        'title': _titleController.text.trim(),
        'notes': _notesController.text.trim(),
        'estimatedPomodoros': _estimatedSessions,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingTask != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
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
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.0),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
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
                            child: Text('🍅', style: TextStyle(fontSize: 18)),
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
    );
  }
}

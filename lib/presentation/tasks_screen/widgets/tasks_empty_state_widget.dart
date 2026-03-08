import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class TasksEmptyStateWidget extends StatelessWidget {
  final VoidCallback onAddTask;

  const TasksEmptyStateWidget({super.key, required this.onAddTask});

  static const Color _accentRed = Color(0xFFE76F6F);
  static const Color _primaryText = Color(0xFF2F2F2F);
  static const Color _secondaryText = Color(0xFF6F6F6F);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🌿', style: TextStyle(fontSize: 56)),
            SizedBox(height: 2.h),
            Text(
              'Your task list is empty',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Add your first task and begin\nyour focused work session.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: _secondaryText,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            GestureDetector(
              onTap: onAddTask,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
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
                  'Add your first task',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

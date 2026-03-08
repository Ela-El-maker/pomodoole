import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class CompletionActionButtonsWidget extends StatelessWidget {
  final VoidCallback onStartBreak;
  final VoidCallback onSkipBreak;

  const CompletionActionButtonsWidget({
    super.key,
    required this.onStartBreak,
    required this.onSkipBreak,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Start Break button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onStartBreak();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA8C3A0),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 1.8.h),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: Text(
              'Start Break',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        // Skip Break button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onSkipBreak();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark
                  ? const Color(0xFFAAAAAA)
                  : const Color(0xFF6F6F6F),
              padding: EdgeInsets.symmetric(vertical: 1.8.h),
              side: BorderSide(
                color: isDark
                    ? const Color(0xFF444444)
                    : const Color(0xFFDDDDDD),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: Text(
              'Skip Break',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

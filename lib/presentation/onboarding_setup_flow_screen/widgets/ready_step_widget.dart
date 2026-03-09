import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class ReadyStepWidget extends StatelessWidget {
  final int focusDuration;
  final int breakDuration;
  final String atmosphere;
  final int weeklyGoal;

  const ReadyStepWidget({
    super.key,
    required this.focusDuration,
    required this.breakDuration,
    required this.atmosphere,
    required this.weeklyGoal,
  });

  String _getAtmosphereEmoji(String atmosphere) {
    switch (atmosphere) {
      case 'Rain':
        return '🌧️';
      case 'Forest':
        return '🌲';
      case 'Cafe':
        return '☕';
      default:
        return '🤫';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 5 of 5',
          style: GoogleFonts.dmSans(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFA8C3A0),
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Ready to begin 🌿',
          style: GoogleFonts.dmSans(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2F2F2F),
            height: 1.3,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Your peaceful focus space is set up. Here\'s what you chose:',
          style: GoogleFonts.dmSans(
            fontSize: 11.sp,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF6F6F6F),
            height: 1.5,
          ),
        ),
        SizedBox(height: 4.h),
        // Summary card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EFEA),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                '⏱️',
                'Focus Duration',
                '$focusDuration minutes',
                const Color(0xFFE76F6F),
              ),
              Divider(color: const Color(0xFFE0DED8), height: 3.h),
              _buildSummaryRow(
                '☕',
                'Break Length',
                '$breakDuration minutes',
                const Color(0xFFA8C3A0),
              ),
              Divider(color: const Color(0xFFE0DED8), height: 3.h),
              _buildSummaryRow(
                _getAtmosphereEmoji(atmosphere),
                'Atmosphere',
                atmosphere,
                const Color(0xFFA8C3A0),
              ),
              Divider(color: const Color(0xFFE0DED8), height: 3.h),
              _buildSummaryRow(
                '🎯',
                'Weekly Goal',
                '$weeklyGoal sessions',
                const Color(0xFFE76F6F),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: const Color(0xFFA8C3A0).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: const Color(0xFFA8C3A0).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Text('🌿', style: TextStyle(fontSize: 20)),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Focus → rest → repeat. Your calm rhythm starts now.',
                  style: GoogleFonts.dmSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF2F2F2F),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String emoji,
    String label,
    String value,
    Color valueColor,
  ) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6F6F6F),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2F2F2F),
          ),
        ),
      ],
    );
  }
}

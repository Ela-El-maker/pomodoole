import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class WelcomeTextWidget extends StatelessWidget {
  const WelcomeTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Welcome to Petal Focus 🌿',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2F2F2F),
            height: 1.4,
          ),
        ),
        SizedBox(height: 1.5.h),
        Text(
          'A quiet place to work.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 13.sp,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF6F6F6F),
            height: 1.6,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPill('🌿 Peaceful'),
            SizedBox(width: 2.w),
            _buildPill('✨ Minimal'),
            SizedBox(width: 2.w),
            _buildPill('🧘 Focused'),
          ],
        ),
      ],
    );
  }

  Widget _buildPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EFEA),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color(0xFFA8C3A0).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF6F6F6F),
        ),
      ),
    );
  }
}

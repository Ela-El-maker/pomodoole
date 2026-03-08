import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AtmosphereStepWidget extends StatelessWidget {
  final String selectedAtmosphere;
  final ValueChanged<String> onAtmosphereSelected;

  const AtmosphereStepWidget({
    super.key,
    required this.selectedAtmosphere,
    required this.onAtmosphereSelected,
  });

  static const List<Map<String, String>> _atmospheres = [
    {'name': 'Silent', 'emoji': '🤫', 'desc': 'Pure quiet focus'},
    {'name': 'Rain', 'emoji': '🌧️', 'desc': 'Gentle rainfall sounds'},
    {'name': 'Forest', 'emoji': '🌲', 'desc': 'Birdsong & rustling leaves'},
    {'name': 'Cafe', 'emoji': '☕', 'desc': 'Soft ambient chatter'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 3 of 4',
          style: GoogleFonts.dmSans(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFA8C3A0),
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Choose your\natmosphere',
          style: GoogleFonts.dmSans(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2F2F2F),
            height: 1.3,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Set the mood for your focus sessions.',
          style: GoogleFonts.dmSans(
            fontSize: 11.sp,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF6F6F6F),
          ),
        ),
        SizedBox(height: 4.h),
        ...List.generate(_atmospheres.length, (i) {
          final item = _atmospheres[i];
          return Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: _buildAtmosphereCard(
              item['name']!,
              item['emoji']!,
              item['desc']!,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAtmosphereCard(String name, String emoji, String description) {
    final isSelected = selectedAtmosphere == name;
    return GestureDetector(
      onTap: () => onAtmosphereSelected(name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFA8C3A0).withValues(alpha: 0.12)
              : const Color(0xFFF0EFEA),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? const Color(0xFFA8C3A0) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 11.w,
              height: 5.5.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFA8C3A0).withValues(alpha: 0.2)
                    : const Color(0xFFE8E6E0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2F2F2F),
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.dmSans(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF6F6F6F),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 6.w,
                height: 3.h,
                decoration: const BoxDecoration(
                  color: Color(0xFFA8C3A0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class SavedMixCardWidget extends StatelessWidget {
  final String mixName;
  final Map<String, double> soundLevels;
  final bool isActive;
  final VoidCallback onApply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SavedMixCardWidget({
    super.key,
    required this.mixName,
    required this.soundLevels,
    required this.isActive,
    required this.onApply,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final activeSounds = soundLevels.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFE76F6F).withValues(alpha: 0.08)
            : const Color(0xFFF0EFEA),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isActive
              ? const Color(0xFFE76F6F).withValues(alpha: 0.4)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFE76F6F).withValues(alpha: 0.15)
                    : const Color(0xFFE8E7E2),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                Icons.library_music_rounded,
                color: isActive
                    ? const Color(0xFFE76F6F)
                    : const Color(0xFF6F6F6F),
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mixName,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2F2F2F),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (activeSounds.isNotEmpty)
                    Text(
                      activeSounds.join(' · '),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFF6F6F6F),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE76F6F).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Active',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE76F6F),
                  ),
                ),
              )
            else
              TextButton(
                onPressed: onApply,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Apply',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE76F6F),
                  ),
                ),
              ),
            SizedBox(width: 1.w),
            GestureDetector(
              onTap: onEdit,
              child: const Icon(
                Icons.edit_rounded,
                size: 18,
                color: Color(0xFF6F6F6F),
              ),
            ),
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

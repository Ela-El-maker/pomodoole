import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SessionDotsWidget extends StatelessWidget {
  final int currentSession;
  final int totalSessions;
  final Color activeColor;
  final Color inactiveColor;

  const SessionDotsWidget({
    super.key,
    required this.currentSession,
    required this.totalSessions,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Session $currentSession of $totalSessions',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6F6F6F),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(totalSessions, (index) {
            final isCompleted = index < currentSession - 1;
            final isCurrent = index == currentSession - 1;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isCurrent ? 10 : 8,
              height: isCurrent ? 10 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isCompleted || isCurrent) ? activeColor : inactiveColor,
                border: isCurrent
                    ? Border.all(color: activeColor, width: 2)
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }
}

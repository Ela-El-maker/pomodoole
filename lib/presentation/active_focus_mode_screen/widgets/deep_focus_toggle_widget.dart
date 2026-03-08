import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeepFocusToggleWidget extends StatefulWidget {
  const DeepFocusToggleWidget({super.key});

  @override
  State<DeepFocusToggleWidget> createState() => _DeepFocusToggleWidgetState();
}

class _DeepFocusToggleWidgetState extends State<DeepFocusToggleWidget> {
  bool _isEnabled = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isEnabled
            ? const Color(0xFFE76F6F).withValues(alpha: 0.08)
            : const Color(0xFFF0EFEA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isEnabled
              ? const Color(0xFFE76F6F).withValues(alpha: 0.3)
              : const Color(0xFFE8E7E2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _isEnabled
                  ? const Color(0xFFE76F6F).withValues(alpha: 0.15)
                  : const Color(0xFFDDDCD8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isEnabled
                  ? Icons.do_not_disturb_on_outlined
                  : Icons.do_not_disturb_off_outlined,
              size: 16,
              color: _isEnabled
                  ? const Color(0xFFE76F6F)
                  : const Color(0xFF6F6F6F),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deep Focus Mode',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2F2F2F),
                  ),
                ),
                Text(
                  _isEnabled
                      ? 'Notifications muted'
                      : 'Tap to mute notifications',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    color: const Color(0xFF6F6F6F),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: _isEnabled,
              onChanged: (val) => setState(() => _isEnabled = val),
              activeThumbColor: const Color(0xFFE76F6F),
              activeTrackColor: const Color(0xFFE76F6F).withValues(alpha: 0.3),
              inactiveThumbColor: const Color(0xFFBBBBBB),
              inactiveTrackColor: const Color(0xFFDDDCD8),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class CompletionMessageWidget extends StatefulWidget {
  final int completedSessions;
  final int totalSessions;

  const CompletionMessageWidget({
    super.key,
    required this.completedSessions,
    required this.totalSessions,
  });

  @override
  State<CompletionMessageWidget> createState() =>
      _CompletionMessageWidgetState();
}

class _CompletionMessageWidgetState extends State<CompletionMessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _completionMessage {
    if (widget.completedSessions >= widget.totalSessions) {
      return 'Amazing! 🌿 You completed all sessions!';
    } else if (widget.completedSessions == 2) {
      return 'Halfway there! 🌿 Keep going.';
    }
    return 'Nice work 🌿 You completed a focus session.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? const Color(0xFFF0F0F0)
        : const Color(0xFF2F2F2F);
    final textSecondary = isDark
        ? const Color(0xFFAAAAAA)
        : const Color(0xFF6F6F6F);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Leaf icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFA8C3A0).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🌿', style: TextStyle(fontSize: 32)),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              _completionMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: textPrimary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 1.5.h),
            Text(
              'Session ${widget.completedSessions} of ${widget.totalSessions} complete',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

class BreakTimerWidget extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isLongBreak;

  const BreakTimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isLongBreak,
  });

  String get _formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (totalSeconds == 0) return 0;
    return 1.0 - (remainingSeconds / totalSeconds);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? const Color(0xFFF0F0F0)
        : const Color(0xFF2F2F2F);
    final double size = math.min(65.w, 260.0);
    const sageGreen = Color(0xFFA8C3A0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _BreakProgressPainter(
                progress: _progress,
                progressColor: sageGreen,
                backgroundColor: sageGreen.withValues(alpha: 0.15),
                strokeWidth: 10,
                counterClockwise: true,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formattedTime,
                style: GoogleFonts.inter(
                  fontSize: math.min(11.w, 44.0),
                  fontWeight: FontWeight.w300,
                  color: textPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: sageGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isLongBreak ? 'Long Break' : 'Break Time',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF7A9E72),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreakProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;
  final bool counterClockwise;

  _BreakProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
    this.counterClockwise = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      counterClockwise ? -sweepAngle : sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_BreakProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

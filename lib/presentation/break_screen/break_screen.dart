import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../routes/app_routes.dart';
import './widgets/break_background_widget.dart';
import './widgets/break_suggestions_widget.dart';
import './widgets/break_timer_widget.dart';

class BreakScreen extends StatefulWidget {
  const BreakScreen({super.key});

  @override
  State<BreakScreen> createState() => _BreakScreenState();
}

class _BreakScreenState extends State<BreakScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  bool _isLongBreak = false;
  int _completedSessions = 1;
  int _totalSessions = 4;
  late int _totalSeconds;
  late int _remainingSeconds;
  bool _isRunning = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _isLongBreak = args['isLongBreak'] as bool? ?? false;
      _completedSessions = args['completedSessions'] as int? ?? 1;
      _totalSessions = args['totalSessions'] as int? ?? 4;
    }
    _totalSeconds = _isLongBreak ? 15 * 60 : 5 * 60;
    _remainingSeconds = _totalSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
          _isRunning = false;
          _onBreakComplete();
        }
      });
    });
  }

  void _onBreakComplete() {
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.focusScreen);
  }

  void _skipBreak() {
    _timer?.cancel();
    HapticFeedback.lightImpact();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.focusScreen);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
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
      child: BreakBackgroundWidget(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: Column(
                children: [
                  // Top header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isLongBreak ? 'Great progress 🌿' : 'Well done 🌿',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isLongBreak
                                ? 'Time for a longer rest.'
                                : 'Time for a break.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                      // Session indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA8C3A0).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Session $_completedSessions of $_totalSessions',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF7A9E72),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Timer centered
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BreakTimerWidget(
                          remainingSeconds: _remainingSeconds,
                          totalSeconds: _totalSeconds,
                          isLongBreak: _isLongBreak,
                        ),
                        SizedBox(height: 4.h),
                        BreakSuggestionsWidget(isLongBreak: _isLongBreak),
                      ],
                    ),
                  ),

                  // Skip break button
                  TextButton(
                    onPressed: _skipBreak,
                    style: TextButton.styleFrom(
                      foregroundColor: textSecondary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 1.5.h,
                      ),
                    ),
                    child: Text(
                      'Skip break',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: textSecondary,
                        decoration: TextDecoration.underline,
                        decorationColor: textSecondary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../routes/app_routes.dart';
import './widgets/completion_action_buttons_widget.dart';
import './widgets/completion_message_widget.dart';
import './widgets/session_dots_widget.dart';

class SessionCompletionScreen extends StatefulWidget {
  const SessionCompletionScreen({
    super.key,
    this.completedSessions,
    this.totalSessions,
  });

  final int? completedSessions;
  final int? totalSessions;

  @override
  State<SessionCompletionScreen> createState() =>
      _SessionCompletionScreenState();
}

class _SessionCompletionScreenState extends State<SessionCompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  late Animation<double> _bgFadeAnimation;
  Timer? _autoAdvanceTimer;
  int _autoAdvanceSeconds = 10;

  // Session data (can be passed via arguments)
  int _completedSessions = 2;
  int _totalSessions = 4;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bgFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeOut));
    _bgController.forward();

    // Haptic feedback on screen appear
    HapticFeedback.mediumImpact();

    // Auto-advance timer
    _startAutoAdvanceTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _completedSessions = widget.completedSessions ?? _completedSessions;
    _totalSessions = widget.totalSessions ?? _totalSessions;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _completedSessions = args['completedSessions'] as int? ?? 2;
      _totalSessions = args['totalSessions'] as int? ?? 4;
    }
  }

  void _startAutoAdvanceTimer() {
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _autoAdvanceSeconds--;
      });
      if (_autoAdvanceSeconds <= 0) {
        timer.cancel();
        _navigateToBreak();
      }
    });
  }

  void _navigateToBreak() {
    _autoAdvanceTimer?.cancel();
    if (!mounted) return;
    context.go(
      AppRoutes.breakScreen,
      extra: {
        'isLongBreak': _completedSessions >= _totalSessions,
        'completedSessions': _completedSessions,
        'totalSessions': _totalSessions,
      },
    );
  }

  void _skipBreak() {
    _autoAdvanceTimer?.cancel();
    if (!mounted) return;
    context.go(AppRoutes.timer);
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F7F5);

    return FadeTransition(
      opacity: _bgFadeAnimation,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            child: Column(
              children: [
                // Auto-advance countdown
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF0EFEA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Auto-continue in ${_autoAdvanceSeconds}s',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFFAAAAAA)
                            : const Color(0xFF6F6F6F),
                      ),
                    ),
                  ),
                ),

                // Main content centered
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CompletionMessageWidget(
                        completedSessions: _completedSessions,
                        totalSessions: _totalSessions,
                      ),
                      SizedBox(height: 4.h),
                      SessionDotsWidget(
                        completedSessions: _completedSessions,
                        totalSessions: _totalSessions,
                      ),
                    ],
                  ),
                ),

                // Action buttons at bottom
                CompletionActionButtonsWidget(
                  onStartBreak: _navigateToBreak,
                  onSkipBreak: _skipBreak,
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

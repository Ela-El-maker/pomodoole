import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../routes/app_routes.dart';
import './widgets/focus_timer_widget.dart';
import './widgets/session_dots_widget.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen>
    with TickerProviderStateMixin {
  static const int _focusDuration = 25 * 60;
  int _remainingSeconds = _focusDuration;
  bool _isRunning = false;
  int _currentSession = 1;
  final int _totalSessions = 4;
  Timer? _timer;
  final String _activeTask = 'Study Biology';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 🌿';
    if (hour < 17) return 'Good afternoon 🌿';
    return 'Good evening 🌿';
  }

  void _startTimer() {
    HapticFeedback.lightImpact();
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _onSessionComplete();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
    // Navigate to active focus mode
    Navigator.of(context, rootNavigator: true)
        .pushNamed(
          AppRoutes.activeFocusMode,
          arguments: {
            'task': _activeTask,
            'remainingSeconds': _remainingSeconds,
            'totalSeconds': _focusDuration,
            'session': _currentSession,
          },
        )
        .then((_) {
          _timer?.cancel();
          setState(() => _isRunning = false);
        });
  }

  void _onSessionComplete() {
    setState(() {
      _isRunning = false;
      _remainingSeconds = _focusDuration;
      if (_currentSession < _totalSessions) {
        _currentSession++;
      } else {
        _currentSession = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 3.h),
                  // Greeting
                  _buildGreetingSection(),
                  SizedBox(height: 4.h),
                  // Circular Timer
                  FocusTimerWidget(
                    remainingSeconds: _remainingSeconds,
                    totalSeconds: _focusDuration,
                    isRunning: _isRunning,
                    label: 'FOCUS',
                  ),
                  SizedBox(height: 4.h),
                  // Start Button
                  _buildStartButton(),
                  SizedBox(height: 3.h),
                  // Session Indicator
                  SessionDotsWidget(
                    currentSession: _currentSession,
                    totalSessions: _totalSessions,
                    activeColor: const Color(0xFFA8C3A0),
                    inactiveColor: const Color(0xFFDDDCD8),
                  ),
                  SizedBox(height: 4.h),
                  // Active Task Card
                  _buildActiveTaskCard(),
                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _getGreeting(),
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF2F2F2F),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Let\'s focus.',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF6F6F6F),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isRunning ? null : _startTimer,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE76F6F),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(
            0xFFE76F6F,
          ).withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          _isRunning ? 'Focusing...' : 'Start Focus',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTaskCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EFEA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E7E2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE76F6F).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              color: Color(0xFFE76F6F),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Task',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6F6F6F),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _activeTask,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2F2F2F),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(AppRoutes.taskManagement);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFA8C3A0).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Change',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6A9E62),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

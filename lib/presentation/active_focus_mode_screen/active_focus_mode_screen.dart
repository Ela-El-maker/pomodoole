import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import './widgets/ambient_sound_widget.dart';
import './widgets/deep_focus_toggle_widget.dart';
import '../../presentation/focus_screen/widgets/circular_timer_painter.dart';

class ActiveFocusModeScreen extends StatefulWidget {
  const ActiveFocusModeScreen({super.key});

  @override
  State<ActiveFocusModeScreen> createState() => _ActiveFocusModeScreenState();
}

class _ActiveFocusModeScreenState extends State<ActiveFocusModeScreen>
    with TickerProviderStateMixin {
  late int _remainingSeconds;
  late int _totalSeconds;
  late String _taskName;
  late int _session;
  bool _isPaused = false;
  Timer? _timer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = 25 * 60;
    _totalSeconds = 25 * 60;
    _taskName = 'Study Biology';
    _session = 1;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      setState(() {
        _remainingSeconds = args['remainingSeconds'] as int? ?? 25 * 60;
        _totalSeconds = args['totalSeconds'] as int? ?? 25 * 60;
        _taskName = args['task'] as String? ?? 'Focus Task';
        _session = args['session'] as int? ?? 1;
      });
    }
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _onComplete();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _onComplete() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }

  void _togglePause() {
    HapticFeedback.lightImpact();
    setState(() => _isPaused = !_isPaused);
    if (_isPaused) {
      _pulseController.stop();
    } else {
      _pulseController.repeat(reverse: true);
    }
  }

  void _endSession() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    Navigator.of(context).pop();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds > 0
        ? 1.0 - (_remainingSeconds / _totalSeconds)
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              children: [
                SizedBox(height: 2.h),
                // Top bar
                _buildTopBar(),
                SizedBox(height: 4.h),
                // Timer
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTimer(progress),
                      SizedBox(height: 4.h),
                      // Controls
                      _buildControls(),
                    ],
                  ),
                ),
                // Bottom section
                _buildBottomSection(),
                SizedBox(height: 3.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: _endSession,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EFEA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8E7E2), width: 1),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14,
              color: Color(0xFF6F6F6F),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                'Focus Session',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6F6F6F),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _taskName,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6F6F6F),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFA8C3A0).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '$_session',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6A9E62),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimer(double progress) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPaused ? 1.0 : _pulseAnimation.value,
          child: SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (!_isPaused)
                  Container(
                    width: 248,
                    height: 248,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFE76F6F,
                          ).withValues(alpha: 0.10),
                          blurRadius: 28,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                  ),
                CustomPaint(
                  size: const Size(240, 240),
                  painter: CircularTimerPainter(
                    progress: progress,
                    ringColor: _isPaused
                        ? const Color(0xFFBBBBBB)
                        : const Color(0xFFE76F6F),
                    trackColor: const Color(0xFFE8E7E2),
                    strokeWidth: 6,
                  ),
                ),
                Container(
                  width: 210,
                  height: 210,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF7F7F5),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isPaused)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'PAUSED',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6F6F6F),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: GoogleFonts.dmSans(
                        fontSize: 48,
                        fontWeight: FontWeight.w200,
                        color: _isPaused
                            ? const Color(0xFF6F6F6F)
                            : const Color(0xFF2F2F2F),
                        letterSpacing: -1,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'FOCUS',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6F6F6F),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // End session button
        GestureDetector(
          onTap: _endSession,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EFEA),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: const Color(0xFFE8E7E2), width: 1),
            ),
            child: Text(
              'End session',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6F6F6F),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Pause/Resume button
        GestureDetector(
          onTap: _togglePause,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: _isPaused
                  ? const Color(0xFFE76F6F)
                  : const Color(0xFFF0EFEA),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: _isPaused
                    ? const Color(0xFFE76F6F)
                    : const Color(0xFFE8E7E2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  size: 16,
                  color: _isPaused ? Colors.white : const Color(0xFF2F2F2F),
                ),
                const SizedBox(width: 6),
                Text(
                  _isPaused ? 'Resume' : 'Pause',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _isPaused ? Colors.white : const Color(0xFF2F2F2F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        const AmbientSoundWidget(),
        const SizedBox(height: 10),
        const DeepFocusToggleWidget(),
      ],
    );
  }
}

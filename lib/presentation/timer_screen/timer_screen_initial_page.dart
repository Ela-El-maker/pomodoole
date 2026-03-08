import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/app_state_service.dart';
import '../../services/haptic_service.dart';
import '../../services/timer_service.dart';
import '../../widgets/session_recovery_dialog.dart';
import './widgets/circular_timer_widget.dart';
import './widgets/session_controls_widget.dart';
import './widgets/session_info_widget.dart';
import './widgets/task_input_widget.dart';

class TimerScreenInitialPage extends StatefulWidget {
  const TimerScreenInitialPage({super.key});

  @override
  State<TimerScreenInitialPage> createState() => _TimerScreenInitialPageState();
}

class _TimerScreenInitialPageState extends State<TimerScreenInitialPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TimerService _timerService = TimerService();
  final AppStateService _appState = AppStateService();
  final HapticService _haptic = HapticService();
  late StreamSubscription<TimerState> _stateSubscription;

  TimerState? _currentState;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final TextEditingController _taskController = TextEditingController();

  // Focus nodes for keyboard navigation
  final FocusNode _startPauseFocus = FocusNode();
  final FocusNode _stopFocus = FocusNode();
  final FocusNode _taskInputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _stateSubscription = _timerService.stateStream.listen((state) {
      if (mounted) {
        setState(() => _currentState = state);
        _progressController.value = state.progress;
        if (state.isRunning && !_appState.reduceMotion) {
          if (!_pulseController.isAnimating) {
            _pulseController.repeat(reverse: true);
          }
        } else {
          _pulseController.stop();
          _pulseController.value = 0;
        }
      }
    });

    _taskController.text = _timerService.currentTask;

    // Check for interrupted session after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInterruptedSession();
    });
  }

  void _checkInterruptedSession() {
    showSessionRecoveryIfNeeded(
      context,
      onResume: () {
        // Restore timer from saved state
        final remaining = _appState.interruptedRemainingSeconds;
        _timerService.resumeFromInterruption(remaining);
        _appState.clearInterruptedSession();
      },
      onStartFresh: () {
        _timerService.stop();
        _appState.clearInterruptedSession();
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stateSubscription.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    _taskController.dispose();
    _startPauseFocus.dispose();
    _stopFocus.dispose();
    _taskInputFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerService.reloadSettings();
    }
    // Save session state when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (_isRunning || _isPaused) {
        _appState.markSessionInProgress(
          remainingSeconds: _timerService.remainingSeconds,
          sessionType: _timerService.sessionLabel,
        );
      }
    }
    if (state == AppLifecycleState.resumed) {
      if (!_isRunning && !_isPaused) {
        _appState.clearSessionInProgress();
      }
    }
  }

  Color get _sessionColor {
    final theme = Theme.of(context);
    final sessionType = _currentState?.sessionType ?? _timerService.sessionType;
    switch (sessionType) {
      case SessionType.focus:
        return theme.colorScheme.error;
      case SessionType.shortBreak:
        return AppTheme.successLight;
      case SessionType.longBreak:
        return theme.colorScheme.primary;
    }
  }

  String get _formattedTime =>
      _currentState?.formattedTime ?? _timerService.formattedTime;

  String get _sessionLabel =>
      _currentState?.sessionLabel ?? _timerService.sessionLabel;

  double get _progress => _currentState?.progress ?? _timerService.progress;

  bool get _isRunning => _currentState?.isRunning ?? _timerService.isRunning;

  bool get _isPaused => _currentState?.isPaused ?? _timerService.isPaused;

  int get _completedSessions =>
      _currentState?.completedSessions ?? _timerService.completedSessions;

  int get _sessionInCycle =>
      _currentState?.sessionInCycle ?? _timerService.sessionInCycle;

  void _onTaskChanged(String value) {
    _timerService.setCurrentTask(value);
  }

  void _handleStart() {
    _haptic.sessionStart();
    _timerService.start();
  }

  void _handlePause() {
    _haptic.buttonPress();
    _timerService.pause();
  }

  void _handleStop() {
    _haptic.buttonPress();
    _timerService.stop();
    _appState.clearSessionInProgress();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutesLeft = _timerService.remainingSeconds ~/ 60;
    final secondsLeft = _timerService.remainingSeconds % 60;

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.space) {
            if (_isRunning) {
              _handlePause();
            } else {
              _handleStart();
            }
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            if (_isRunning || _isPaused) _handleStop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: CustomIconWidget(
                  iconName: 'timer',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 2.w),
              Text('Pomodoro', style: theme.textTheme.titleLarge),
            ],
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: Semantics(
                label: '$_completedSessions sessions completed today',
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ExcludeSemantics(
                    child: Text(
                      '$_completedSessions sessions',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
              child: Column(
                children: [
                  Semantics(
                    label:
                        'Session $_sessionInCycle of 4, $_sessionLabel session',
                    child: SessionInfoWidget(
                      sessionInCycle: _sessionInCycle,
                      sessionLabel: _sessionLabel,
                      sessionColor: _sessionColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Expanded(
                    child: Center(
                      child: Semantics(
                        label:
                            'Timer showing $minutesLeft minutes and $secondsLeft seconds, $_sessionLabel session active',
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            final scale =
                                (_isRunning && !_appState.reduceMotion)
                                ? _pulseAnimation.value
                                : 1.0;
                            return Transform.scale(
                              scale: scale,
                              child: CircularTimerWidget(
                                progress: _progress,
                                formattedTime: _formattedTime,
                                sessionLabel: _sessionLabel,
                                sessionColor: _sessionColor,
                                isRunning: _isRunning,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TaskInputWidget(
                    controller: _taskController,
                    onChanged: _onTaskChanged,
                    currentTask: _timerService.currentTask,
                  ),
                  SizedBox(height: 2.h),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(1),
                    child: Semantics(
                      label: _isRunning
                          ? 'Pause timer'
                          : (_isPaused
                                ? 'Resume focus session'
                                : 'Start focus session'),
                      hint: 'Press Space to toggle',
                      button: true,
                      child: SessionControlsWidget(
                        isRunning: _isRunning,
                        isPaused: _isPaused,
                        sessionColor: _sessionColor,
                        onStart: _handleStart,
                        onPause: _handlePause,
                        onStop: _handleStop,
                        startFocusNode: _startPauseFocus,
                        stopFocusNode: _stopFocus,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

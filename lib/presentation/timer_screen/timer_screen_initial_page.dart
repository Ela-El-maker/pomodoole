import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../app/router/route_paths.dart';
import '../../core/app_export.dart';
import '../../services/app_state_service.dart';
import '../../state/session/session_providers.dart';
import '../../state/session/session_state.dart';
import '../../widgets/session_recovery_dialog.dart';
import './widgets/circular_timer_widget.dart';
import './widgets/session_controls_widget.dart';
import './widgets/session_info_widget.dart';
import './widgets/task_input_widget.dart';

class TimerScreenInitialPage extends ConsumerStatefulWidget {
  const TimerScreenInitialPage({super.key});

  @override
  ConsumerState<TimerScreenInitialPage> createState() =>
      _TimerScreenInitialPageState();
}

class _TimerScreenInitialPageState extends ConsumerState<TimerScreenInitialPage>
    with TickerProviderStateMixin {
  final AppStateService _appState = AppStateService();
  final TextEditingController _taskController = TextEditingController();

  final FocusNode _keyboardFocus = FocusNode();
  final FocusNode _startPauseFocus = FocusNode();
  final FocusNode _stopFocus = FocusNode();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRecoveryDialogIfNeeded();
    });
  }

  void _showRecoveryDialogIfNeeded() {
    final state = ref.read(sessionControllerProvider);
    final snapshot = state.interruptedSnapshot;
    if (snapshot == null) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionRecoveryDialog(
        sessionType: switch (snapshot.kind) {
          SessionKind.focus => 'Focus',
          SessionKind.shortBreak => 'Short Break',
          SessionKind.longBreak => 'Long Break',
        },
        remainingSeconds: snapshot.remainingSeconds,
        onResume: () {
          Navigator.of(context).pop();
          ref
              .read(sessionControllerProvider.notifier)
              .restoreInterruptedSession();
        },
        onStartFresh: () {
          Navigator.of(context).pop();
          ref.read(sessionControllerProvider.notifier).stop();
        },
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    _keyboardFocus.dispose();
    _startPauseFocus.dispose();
    _stopFocus.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color _resolveSessionColor(SessionKind kind, ThemeData theme) {
    switch (kind) {
      case SessionKind.focus:
        return theme.colorScheme.error;
      case SessionKind.shortBreak:
        return AppTheme.successLight;
      case SessionKind.longBreak:
        return theme.colorScheme.primary;
    }
  }

  void _syncTaskInput(String task) {
    if (_taskController.text == task) return;
    _taskController.text = task;
    _taskController.selection = TextSelection.collapsed(
      offset: _taskController.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionControllerProvider);
    final sessionController = ref.read(sessionControllerProvider.notifier);

    final theme = Theme.of(context);
    final sessionColor = _resolveSessionColor(sessionState.kind, theme);

    _syncTaskInput(sessionState.currentTask);

    if (sessionState.isRunning && !_appState.reduceMotion) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }

    final minutesLeft = sessionState.remainingSeconds ~/ 60;
    final secondsLeft = sessionState.remainingSeconds % 60;

    return KeyboardListener(
      focusNode: _keyboardFocus,
      onKeyEvent: (event) {
        if (event is! KeyDownEvent) return;

        if (event.logicalKey == LogicalKeyboardKey.space) {
          if (sessionState.isRunning) {
            sessionController.pause();
          } else {
            sessionController.start();
          }
        }

        if (event.logicalKey == LogicalKeyboardKey.escape) {
          if (sessionState.isRunning || sessionState.isPaused) {
            sessionController.stop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Pomodoro', style: theme.textTheme.titleLarge),
          centerTitle: true,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: Semantics(
                label:
                    '${sessionState.completedSessions} sessions completed today',
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
                      '${sessionState.completedSessions}',
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
                        'Session ${sessionState.sessionInCycle} of 4, ${sessionState.sessionLabel} session',
                    child: SessionInfoWidget(
                      sessionInCycle: sessionState.sessionInCycle,
                      sessionLabel: sessionState.sessionLabel,
                      sessionColor: sessionColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Expanded(
                    child: Center(
                      child: Semantics(
                        label:
                            'Timer showing $minutesLeft minutes and $secondsLeft seconds, ${sessionState.sessionLabel} session active',
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            final scale =
                                (sessionState.isRunning &&
                                    !_appState.reduceMotion)
                                ? _pulseAnimation.value
                                : 1.0;
                            return Transform.scale(
                              scale: scale,
                              child: CircularTimerWidget(
                                progress: sessionState.progress,
                                formattedTime:
                                    sessionState.formattedRemainingTime,
                                sessionLabel: sessionState.sessionLabel,
                                sessionColor: sessionColor,
                                isRunning: sessionState.isRunning,
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
                    onChanged: sessionController.setTask,
                    currentTask: sessionState.currentTask,
                  ),
                  SizedBox(height: 2.h),
                  if (sessionState.phase == SessionPhase.sessionComplete)
                    _SessionCompleteActions(
                      onStartBreak: sessionController.startBreakAfterCompletion,
                      onReflect: () {
                        sessionController.markReflectionPending();
                        context.go(RoutePaths.postSessionReflection);
                      },
                    )
                  else
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(1),
                      child: Semantics(
                        label: sessionState.isRunning
                            ? 'Pause timer'
                            : (sessionState.isPaused
                                  ? 'Resume focus session'
                                  : 'Start focus session'),
                        hint: 'Press Space to toggle',
                        button: true,
                        child: SessionControlsWidget(
                          isRunning: sessionState.isRunning,
                          isPaused: sessionState.isPaused,
                          sessionColor: sessionColor,
                          onStart: sessionController.start,
                          onPause: sessionController.pause,
                          onStop: sessionController.stop,
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

class _SessionCompleteActions extends StatelessWidget {
  const _SessionCompleteActions({
    required this.onStartBreak,
    required this.onReflect,
  });

  final VoidCallback onStartBreak;
  final VoidCallback onReflect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onStartBreak,
            child: const Text('Start Break'),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: OutlinedButton(
            onPressed: onReflect,
            child: const Text('Reflect'),
          ),
        ),
      ],
    );
  }
}

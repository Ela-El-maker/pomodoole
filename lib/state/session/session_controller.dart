import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodorofocus/core/monitoring/app_logger.dart';
import 'package:pomodorofocus/data/repositories/session_history_repository.dart';
import 'package:pomodorofocus/data/repositories/tasks_repository.dart';
import 'package:pomodorofocus/services/audio/focus_audio_delegate.dart';
import 'package:pomodorofocus/services/haptic_service.dart';
import 'package:pomodorofocus/services/home_widget_service.dart';
import 'package:pomodorofocus/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'session_state.dart';
import 'session_tick_driver.dart';

class SessionController extends StateNotifier<SessionState>
    with WidgetsBindingObserver {
  SessionController({
    required SharedPreferences preferences,
    required SessionTickDriver tickDriver,
    required NotificationService notificationService,
    required HomeWidgetService homeWidgetService,
    required HapticService hapticService,
    required SessionHistoryRepository sessionHistoryRepository,
    required TasksRepository tasksRepository,
    required AppLogger logger,
    FocusAudioDelegate focusAudioDelegate = const NoopFocusAudioDelegate(),
  }) : _preferences = preferences,
       _tickDriver = tickDriver,
       _notificationService = notificationService,
       _homeWidgetService = homeWidgetService,
       _hapticService = hapticService,
       _sessionHistoryRepository = sessionHistoryRepository,
       _tasksRepository = tasksRepository,
       _logger = logger,
       _focusAudioDelegate = focusAudioDelegate,
       super(SessionState.initial()) {
    WidgetsBinding.instance.addObserver(this);
    unawaited(initialize());
  }

  final SharedPreferences _preferences;
  final SessionTickDriver _tickDriver;
  final NotificationService _notificationService;
  final HomeWidgetService _homeWidgetService;
  final HapticService _hapticService;
  final SessionHistoryRepository _sessionHistoryRepository;
  final TasksRepository _tasksRepository;
  final AppLogger _logger;
  final FocusAudioDelegate _focusAudioDelegate;
  var _disposed = false;

  Timer? _saveDebounce;

  static const _kStateVersion = 'session_state_v2';
  static const _kCurrentStreak = 'current_streak';
  static const _kLastSessionDate = 'last_session_date';
  static const _kCurrentTaskId = 'current_task_id';
  static const _kLastTickEpochMs = 'session_last_tick_epoch_ms';

  Future<void> initialize() async {
    if (_disposed) return;
    await _migrateLegacyData();
    if (_disposed) return;
    final workDuration = _preferences.getInt('work_duration') ?? 25;
    final shortBreakDuration = _preferences.getInt('short_break_duration') ?? 5;
    final longBreakDuration = _preferences.getInt('long_break_duration') ?? 15;

    final updated = state.copyWith(
      workDurationMinutes: workDuration,
      shortBreakDurationMinutes: shortBreakDuration,
      longBreakDurationMinutes: longBreakDuration,
      currentTask: _preferences.getString('current_task') ?? '',
      currentTaskId: _preferences.getString(_kCurrentTaskId),
      notificationsEnabled:
          _preferences.getBool('notifications_enabled') ?? true,
      vibrationEnabled: _preferences.getBool('vibration_enabled') ?? true,
      currentStreak: _preferences.getInt(_kCurrentStreak) ?? 0,
      lastTickEpochMs: _preferences.getInt(_kLastTickEpochMs),
    );
    state = _resetForKind(updated, updated.kind, keepPhase: true);
    if (_disposed) return;

    final interruptedJson = _preferences.getString('interrupted_snapshot_v2');
    if (interruptedJson != null) {
      try {
        final decoded = jsonDecode(interruptedJson) as Map<String, dynamic>;
        state = state.copyWith(
          interruptedSnapshot: InterruptedSessionSnapshot.fromJson(decoded),
        );
      } catch (_) {
        await _preferences.remove('interrupted_snapshot_v2');
      }
    }

    await _notificationService.initialize();
    if (_disposed) return;
    await _homeWidgetService.initialize();
    if (_disposed) return;
    await _updateLiveSurfaces();
  }

  void setTask(String task) {
    state = state.copyWith(currentTask: task, currentTaskId: null);
    _persistTransitionState();
  }

  void setNotificationsEnabled(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
    _persistTransitionState();
    unawaited(_updateLiveSurfaces());
  }

  void setVibrationEnabled(bool enabled) {
    state = state.copyWith(vibrationEnabled: enabled);
    _persistTransitionState();
  }

  void updateDurations({
    required int workDurationMinutes,
    required int shortBreakDurationMinutes,
    required int longBreakDurationMinutes,
  }) {
    var updated = state.copyWith(
      workDurationMinutes: workDurationMinutes,
      shortBreakDurationMinutes: shortBreakDurationMinutes,
      longBreakDurationMinutes: longBreakDurationMinutes,
    );
    updated = _resetForKind(updated, updated.kind, keepPhase: true);
    state = updated;
    _persistTransitionState();
  }

  void start() {
    if (state.isRunning) return;
    final nowEpochMs = DateTime.now().millisecondsSinceEpoch;

    if (!state.isBreak) {
      unawaited(_ensureTaskLinkedForFocus());
    }
    if (state.vibrationEnabled) {
      _hapticService.sessionStart();
    }

    final nextPhase = state.isBreak
        ? SessionPhase.breakActive
        : SessionPhase.focusActive;

    state = state.copyWith(phase: nextPhase, lastTickEpochMs: nowEpochMs);

    if (state.isBreak) {
      unawaited(
        _focusAudioDelegate.onFocusSessionStopped(
          reason: 'break_session_started',
        ),
      );
    } else {
      unawaited(_focusAudioDelegate.onFocusSessionStarted());
    }

    _tickDriver.start(interval: const Duration(seconds: 1), onTick: _onTick);

    unawaited(_updateLiveSurfaces());
    _persistTransitionState();
  }

  void pause() {
    if (!state.isRunning) return;
    _tickDriver.stop();

    state = state.copyWith(
      phase: state.isBreak
          ? SessionPhase.breakPaused
          : SessionPhase.focusPaused,
      lastTickEpochMs: null,
    );

    if (state.vibrationEnabled) {
      _hapticService.buttonPress();
    }

    if (!state.isBreak) {
      unawaited(_focusAudioDelegate.onFocusSessionPaused());
    }

    unawaited(_updateLiveSurfaces());
    _persistTransitionState();
  }

  void resume() {
    if (!state.isPaused) return;
    start();
  }

  void stop() {
    _tickDriver.stop();
    unawaited(
      _focusAudioDelegate.onFocusSessionStopped(reason: 'session_stopped'),
    );
    state = _resetForKind(
      state,
      SessionKind.focus,
      phase: SessionPhase.idle,
    ).copyWith(interruptedSnapshot: null, lastTickEpochMs: null);
    _clearInterruptedSnapshot();
    unawaited(_updateLiveSurfaces());
    _persistTransitionState();
  }

  void startBreakAfterCompletion() {
    if (state.phase != SessionPhase.sessionComplete) return;
    state = state.copyWith(
      phase: SessionPhase.breakActive,
      interruptedSnapshot: null,
      lastTickEpochMs: DateTime.now().millisecondsSinceEpoch,
    );
    unawaited(
      _focusAudioDelegate.onFocusSessionStopped(
        reason: 'break_after_completion',
      ),
    );
    _tickDriver.start(interval: const Duration(seconds: 1), onTick: _onTick);
    _clearInterruptedSnapshot();
    unawaited(_updateLiveSurfaces());
    _persistTransitionState();
  }

  void skipBreak() {
    if (!state.isBreak && state.phase != SessionPhase.sessionComplete) return;
    _tickDriver.stop();
    unawaited(
      _focusAudioDelegate.onFocusSessionStopped(reason: 'break_skipped'),
    );
    state = _resetForKind(
      state,
      SessionKind.focus,
      phase: SessionPhase.idle,
    ).copyWith(interruptedSnapshot: null, lastTickEpochMs: null);
    _clearInterruptedSnapshot();
    unawaited(_updateLiveSurfaces());
    _persistTransitionState();
  }

  void markReflectionPending() {
    state = state.copyWith(phase: SessionPhase.reflectionPending);
    _persistTransitionState();
  }

  void clearInterruptedSession() {
    state = state.copyWith(interruptedSnapshot: null);
    _clearInterruptedSnapshot();
    _persistTransitionState();
  }

  void restoreInterruptedSession() {
    final snapshot = state.interruptedSnapshot;
    if (snapshot == null) return;

    var updated = state.copyWith(
      kind: snapshot.kind,
      sessionInCycle: snapshot.sessionInCycle,
      interruptedSnapshot: null,
    );
    updated = _resetForKind(
      updated,
      snapshot.kind,
      phase: snapshot.kind == SessionKind.focus
          ? SessionPhase.focusPaused
          : SessionPhase.breakPaused,
      overrideRemainingSeconds: snapshot.remainingSeconds,
    );

    state = updated;
    if (snapshot.kind == SessionKind.focus) {
      unawaited(_focusAudioDelegate.onFocusSessionPaused());
    } else {
      unawaited(
        _focusAudioDelegate.onFocusSessionStopped(
          reason: 'restored_non_focus_session',
        ),
      );
    }
    _clearInterruptedSnapshot();
    _persistTransitionState();
  }

  void _onTick() {
    if (!state.isRunning) return;

    if (state.remainingSeconds > 0) {
      state = state.copyWith(
        remainingSeconds: state.remainingSeconds - 1,
        lastTickEpochMs: DateTime.now().millisecondsSinceEpoch,
      );
      unawaited(_updateLiveSurfaces());
      return;
    }

    _tickDriver.stop();
    _onSessionComplete();
  }

  Future<void> _ensureTaskLinkedForFocus() async {
    var rawTask = state.currentTask.trim();
    if (state.currentTaskId != null) return;
    try {
      if (rawTask.isEmpty) {
        final activeTask = await _tasksRepository.getActiveTask();
        if (activeTask != null) {
          rawTask = activeTask.title;
          state = state.copyWith(currentTask: activeTask.title);
        }
      }
      if (rawTask.isEmpty) return;

      final taskId = await _tasksRepository.ensureTaskFromIntent(rawTask);
      if (taskId == null || _disposed) return;
      state = state.copyWith(currentTaskId: taskId);
      _persistTransitionState();
    } catch (error, stackTrace) {
      _logger.warn(
        'session_controller',
        'Failed to auto-link task intent',
        error: error,
        stackTrace: stackTrace,
        data: {'task': rawTask},
      );
    }
  }

  void _reconcileElapsedTimeOnResume() {
    if (!state.isRunning) return;
    final previousTick = state.lastTickEpochMs;
    if (previousTick == null) {
      state = state.copyWith(
        lastTickEpochMs: DateTime.now().millisecondsSinceEpoch,
      );
      return;
    }

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final elapsedSeconds = ((nowMs - previousTick) / 1000).floor();
    if (elapsedSeconds <= 0) return;

    final nextRemaining = state.remainingSeconds - elapsedSeconds;
    if (nextRemaining > 0) {
      state = state.copyWith(
        remainingSeconds: nextRemaining,
        lastTickEpochMs: nowMs,
      );
      unawaited(_updateLiveSurfaces());
      return;
    }

    state = state.copyWith(remainingSeconds: 0, lastTickEpochMs: nowMs);
    _tickDriver.stop();
    unawaited(_onSessionComplete());
  }

  Future<void> _onSessionComplete() async {
    if (_disposed) return;
    final linkedTaskId = state.currentTaskId;
    await _sessionHistoryRepository.addEntry(
      sessionType: state.sessionLabel,
      taskId: linkedTaskId,
      durationSeconds: state.totalSeconds,
      completed: true,
    );

    if (state.vibrationEnabled) {
      _hapticService.sessionComplete();
    }

    if (state.kind == SessionKind.focus) {
      if (linkedTaskId != null && linkedTaskId.isNotEmpty) {
        await _tasksRepository.incrementProgress(linkedTaskId);
      }
      unawaited(
        _focusAudioDelegate.onFocusSessionStopped(
          reason: 'focus_session_completed',
        ),
      );
      final completedSessions = state.completedSessions + 1;
      final nextSessionInCycle = state.sessionInCycle >= 4
          ? 1
          : state.sessionInCycle + 1;
      final nextBreakKind = state.sessionInCycle >= 4
          ? SessionKind.longBreak
          : SessionKind.shortBreak;

      final streak = await _updateStreak();
      var updated = state.copyWith(
        completedSessions: completedSessions,
        sessionInCycle: nextSessionInCycle,
        currentStreak: streak,
        lastTickEpochMs: null,
      );
      updated = _resetForKind(
        updated,
        nextBreakKind,
        phase: SessionPhase.sessionComplete,
      );
      state = updated;

      if (state.notificationsEnabled) {
        await _notificationService.cancelTimerNotification();
        await _notificationService.showSessionCompleteNotification();
      }
    } else {
      state = _resetForKind(
        state,
        SessionKind.focus,
        phase: SessionPhase.idle,
      ).copyWith(lastTickEpochMs: null);

      if (state.notificationsEnabled) {
        await _notificationService.cancelTimerNotification();
        await _notificationService.showBreakEndNotification();
      }
    }

    _clearInterruptedSnapshot();
    if (_disposed) return;
    await _updateLiveSurfaces();
    _persistTransitionState();
  }

  Future<void> _updateLiveSurfaces() async {
    if (_disposed) return;
    if (state.notificationsEnabled) {
      if (state.isRunning || state.isPaused) {
        await _notificationService.updateTimerNotification(
          sessionType: state.sessionLabel,
          remainingTime: state.formattedRemainingTime,
          isPaused: state.isPaused,
        );
      } else {
        await _notificationService.cancelTimerNotification();
      }
    }

    await _homeWidgetService.updateWidget(
      formattedTime: state.formattedRemainingTime,
      sessionLabel: state.sessionLabel,
      isRunning: state.isRunning,
      sessionType: state.kind.name,
    );
  }

  SessionState _resetForKind(
    SessionState current,
    SessionKind kind, {
    SessionPhase? phase,
    bool keepPhase = false,
    int? overrideRemainingSeconds,
  }) {
    int totalSeconds;
    switch (kind) {
      case SessionKind.focus:
        totalSeconds = current.workDurationMinutes * 60;
        break;
      case SessionKind.shortBreak:
        totalSeconds = current.shortBreakDurationMinutes * 60;
        break;
      case SessionKind.longBreak:
        totalSeconds = current.longBreakDurationMinutes * 60;
        break;
    }

    return current.copyWith(
      kind: kind,
      totalSeconds: totalSeconds,
      remainingSeconds: overrideRemainingSeconds ?? totalSeconds,
      phase: phase ?? (keepPhase ? current.phase : SessionPhase.idle),
    );
  }

  Future<int> _updateStreak() async {
    final lastSessionDate = _preferences.getString(_kLastSessionDate);
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    var streak = state.currentStreak;
    if (lastSessionDate == null) {
      streak = 1;
    } else {
      final last = DateTime.tryParse(lastSessionDate);
      if (last == null) {
        streak = 1;
      } else {
        final lastDateOnly = DateTime(last.year, last.month, last.day);
        final diffDays = todayDateOnly.difference(lastDateOnly).inDays;
        if (diffDays == 1) {
          streak += 1;
        } else if (diffDays > 1) {
          streak = 1;
        }
      }
    }

    await _preferences.setInt(_kCurrentStreak, streak);
    await _preferences.setString(
      _kLastSessionDate,
      todayDateOnly.toIso8601String(),
    );
    return streak;
  }

  void _persistTransitionState() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 250), () async {
      await _preferences.setInt('work_duration', state.workDurationMinutes);
      await _preferences.setInt(
        'short_break_duration',
        state.shortBreakDurationMinutes,
      );
      await _preferences.setInt(
        'long_break_duration',
        state.longBreakDurationMinutes,
      );
      await _preferences.setBool(
        'notifications_enabled',
        state.notificationsEnabled,
      );
      await _preferences.setBool('vibration_enabled', state.vibrationEnabled);
      await _preferences.setInt('completed_sessions', state.completedSessions);
      await _preferences.setInt('session_in_cycle', state.sessionInCycle);
      await _preferences.setString('current_task', state.currentTask);
      if (state.currentTaskId == null || state.currentTaskId!.isEmpty) {
        await _preferences.remove(_kCurrentTaskId);
      } else {
        await _preferences.setString(_kCurrentTaskId, state.currentTaskId!);
      }
      if (state.lastTickEpochMs == null) {
        await _preferences.remove(_kLastTickEpochMs);
      } else {
        await _preferences.setInt(_kLastTickEpochMs, state.lastTickEpochMs!);
      }
      await _preferences.setString(_kStateVersion, '1');
    });
  }

  Future<void> _migrateLegacyData() async {
    if (_preferences.getString(_kStateVersion) == '1') return;

    final legacyInProgress = _preferences.getBool('sessionInProgress') ?? false;
    if (legacyInProgress) {
      final legacyRemaining = _preferences.getInt('savedRemainingSeconds') ?? 0;
      final legacyType = _preferences.getString('savedSessionType') ?? 'Focus';
      final legacyKind = switch (legacyType) {
        'Short Break' => SessionKind.shortBreak,
        'Long Break' => SessionKind.longBreak,
        _ => SessionKind.focus,
      };
      final snapshot = InterruptedSessionSnapshot(
        kind: legacyKind,
        remainingSeconds: legacyRemaining,
        sessionInCycle: _preferences.getInt('session_in_cycle') ?? 1,
      );
      await _preferences.setString(
        'interrupted_snapshot_v2',
        jsonEncode(snapshot.toJson()),
      );
    }

    await _preferences.setString(_kStateVersion, '1');
  }

  Future<void> _saveInterruptedSnapshot() async {
    if (_disposed) return;
    if (!state.isRunning && !state.isPaused) return;
    final snapshot = InterruptedSessionSnapshot(
      kind: state.kind,
      remainingSeconds: state.remainingSeconds,
      sessionInCycle: state.sessionInCycle,
    );
    await _preferences.setString(
      'interrupted_snapshot_v2',
      jsonEncode(snapshot.toJson()),
    );
    state = state.copyWith(interruptedSnapshot: snapshot);
  }

  void _clearInterruptedSnapshot() {
    unawaited(_preferences.remove('interrupted_snapshot_v2'));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_saveInterruptedSnapshot());
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _reconcileElapsedTimeOnResume();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _saveDebounce?.cancel();
    _tickDriver.dispose();
    super.dispose();
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodorofocus/data/repositories/session_history_repository.dart';
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
  }) : _preferences = preferences,
       _tickDriver = tickDriver,
       _notificationService = notificationService,
       _homeWidgetService = homeWidgetService,
       _hapticService = hapticService,
       _sessionHistoryRepository = sessionHistoryRepository,
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
  var _disposed = false;

  Timer? _saveDebounce;

  static const _kStateVersion = 'session_state_v2';
  static const _kCurrentStreak = 'current_streak';
  static const _kLastSessionDate = 'last_session_date';

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
      notificationsEnabled:
          _preferences.getBool('notifications_enabled') ?? true,
      vibrationEnabled: _preferences.getBool('vibration_enabled') ?? true,
      currentStreak: _preferences.getInt(_kCurrentStreak) ?? 0,
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
    state = state.copyWith(currentTask: task);
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
    if (state.vibrationEnabled) {
      _hapticService.sessionStart();
    }

    final nextPhase = state.isBreak
        ? SessionPhase.breakActive
        : SessionPhase.focusActive;

    state = state.copyWith(phase: nextPhase);

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
    );

    if (state.vibrationEnabled) {
      _hapticService.buttonPress();
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
    state = _resetForKind(
      state,
      SessionKind.focus,
      phase: SessionPhase.idle,
    ).copyWith(interruptedSnapshot: null);
    _clearInterruptedSnapshot();
    unawaited(_updateLiveSurfaces());
    _persistTransitionState();
  }

  void startBreakAfterCompletion() {
    if (state.phase != SessionPhase.sessionComplete) return;
    state = state.copyWith(
      phase: SessionPhase.breakActive,
      interruptedSnapshot: null,
    );
    _tickDriver.start(interval: const Duration(seconds: 1), onTick: _onTick);
    _clearInterruptedSnapshot();
    unawaited(_updateLiveSurfaces());
    _persistTransitionState();
  }

  void skipBreak() {
    if (!state.isBreak && state.phase != SessionPhase.sessionComplete) return;
    _tickDriver.stop();
    state = _resetForKind(
      state,
      SessionKind.focus,
      phase: SessionPhase.idle,
    ).copyWith(interruptedSnapshot: null);
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
    _clearInterruptedSnapshot();
    _persistTransitionState();
  }

  void _onTick() {
    if (!state.isRunning) return;

    if (state.remainingSeconds > 0) {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      unawaited(_updateLiveSurfaces());
      return;
    }

    _tickDriver.stop();
    _onSessionComplete();
  }

  Future<void> _onSessionComplete() async {
    if (_disposed) return;
    await _sessionHistoryRepository.addEntry(
      sessionType: state.sessionLabel,
      durationSeconds: state.totalSeconds,
      completed: true,
    );

    if (state.vibrationEnabled) {
      _hapticService.sessionComplete();
    }

    if (state.kind == SessionKind.focus) {
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
      state = _resetForKind(state, SessionKind.focus, phase: SessionPhase.idle);

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

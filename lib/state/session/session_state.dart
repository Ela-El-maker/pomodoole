import 'package:flutter/foundation.dart';

enum SessionPhase {
  idle,
  focusActive,
  focusPaused,
  breakActive,
  breakPaused,
  sessionComplete,
  reflectionPending,
}

enum SessionKind { focus, shortBreak, longBreak }

@immutable
class InterruptedSessionSnapshot {
  const InterruptedSessionSnapshot({
    required this.kind,
    required this.remainingSeconds,
    required this.sessionInCycle,
  });

  final SessionKind kind;
  final int remainingSeconds;
  final int sessionInCycle;

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'remainingSeconds': remainingSeconds,
    'sessionInCycle': sessionInCycle,
  };

  factory InterruptedSessionSnapshot.fromJson(Map<String, dynamic> json) {
    return InterruptedSessionSnapshot(
      kind: SessionKind.values.firstWhere(
        (value) => value.name == json['kind'],
        orElse: () => SessionKind.focus,
      ),
      remainingSeconds: (json['remainingSeconds'] as num?)?.toInt() ?? 0,
      sessionInCycle: (json['sessionInCycle'] as num?)?.toInt() ?? 1,
    );
  }
}

@immutable
class SessionState {
  const SessionState({
    required this.phase,
    required this.kind,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.workDurationMinutes,
    required this.shortBreakDurationMinutes,
    required this.longBreakDurationMinutes,
    required this.sessionInCycle,
    required this.completedSessions,
    required this.currentStreak,
    required this.currentTask,
    required this.notificationsEnabled,
    required this.vibrationEnabled,
    this.interruptedSnapshot,
  });

  factory SessionState.initial() {
    const workDuration = 25;
    return const SessionState(
      phase: SessionPhase.idle,
      kind: SessionKind.focus,
      remainingSeconds: workDuration * 60,
      totalSeconds: workDuration * 60,
      workDurationMinutes: workDuration,
      shortBreakDurationMinutes: 5,
      longBreakDurationMinutes: 15,
      sessionInCycle: 1,
      completedSessions: 0,
      currentStreak: 0,
      currentTask: '',
      notificationsEnabled: true,
      vibrationEnabled: true,
    );
  }

  final SessionPhase phase;
  final SessionKind kind;
  final int remainingSeconds;
  final int totalSeconds;
  final int workDurationMinutes;
  final int shortBreakDurationMinutes;
  final int longBreakDurationMinutes;
  final int sessionInCycle;
  final int completedSessions;
  final int currentStreak;
  final String currentTask;
  final bool notificationsEnabled;
  final bool vibrationEnabled;
  final InterruptedSessionSnapshot? interruptedSnapshot;

  bool get isRunning =>
      phase == SessionPhase.focusActive || phase == SessionPhase.breakActive;

  bool get isPaused =>
      phase == SessionPhase.focusPaused || phase == SessionPhase.breakPaused;

  bool get isBreak =>
      kind == SessionKind.shortBreak || kind == SessionKind.longBreak;

  double get progress =>
      totalSeconds == 0 ? 1 : remainingSeconds / totalSeconds;

  String get formattedRemainingTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get sessionLabel {
    switch (kind) {
      case SessionKind.focus:
        return 'Focus';
      case SessionKind.shortBreak:
        return 'Short Break';
      case SessionKind.longBreak:
        return 'Long Break';
    }
  }

  SessionState copyWith({
    SessionPhase? phase,
    SessionKind? kind,
    int? remainingSeconds,
    int? totalSeconds,
    int? workDurationMinutes,
    int? shortBreakDurationMinutes,
    int? longBreakDurationMinutes,
    int? sessionInCycle,
    int? completedSessions,
    int? currentStreak,
    String? currentTask,
    bool? notificationsEnabled,
    bool? vibrationEnabled,
    Object? interruptedSnapshot = _sentinel,
  }) {
    return SessionState(
      phase: phase ?? this.phase,
      kind: kind ?? this.kind,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
      shortBreakDurationMinutes:
          shortBreakDurationMinutes ?? this.shortBreakDurationMinutes,
      longBreakDurationMinutes:
          longBreakDurationMinutes ?? this.longBreakDurationMinutes,
      sessionInCycle: sessionInCycle ?? this.sessionInCycle,
      completedSessions: completedSessions ?? this.completedSessions,
      currentStreak: currentStreak ?? this.currentStreak,
      currentTask: currentTask ?? this.currentTask,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      interruptedSnapshot: interruptedSnapshot == _sentinel
          ? this.interruptedSnapshot
          : interruptedSnapshot as InterruptedSessionSnapshot?,
    );
  }

  static const Object _sentinel = Object();
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pomodorofocus/state/session/session_state.dart';

void main() {
  test('initial state has focus defaults', () {
    final state = SessionState.initial();

    expect(state.phase, SessionPhase.idle);
    expect(state.kind, SessionKind.focus);
    expect(state.workDurationMinutes, 25);
    expect(state.shortBreakDurationMinutes, 5);
    expect(state.longBreakDurationMinutes, 15);
    expect(state.remainingSeconds, 1500);
    expect(state.totalSeconds, 1500);
    expect(state.formattedRemainingTime, '25:00');
    expect(state.sessionLabel, 'Focus');
  });

  test('session labels map to session kind', () {
    final base = SessionState.initial();

    expect(
      base.copyWith(kind: SessionKind.shortBreak).sessionLabel,
      'Short Break',
    );
    expect(base.copyWith(kind: SessionKind.longBreak).sessionLabel, 'Long Break');
  });

  test('progress, running and paused flags reflect phase and timing', () {
    final active = SessionState.initial().copyWith(phase: SessionPhase.focusActive);
    expect(active.isRunning, isTrue);
    expect(active.isPaused, isFalse);

    final paused = active.copyWith(phase: SessionPhase.focusPaused);
    expect(paused.isRunning, isFalse);
    expect(paused.isPaused, isTrue);

    final half = active.copyWith(remainingSeconds: 750, totalSeconds: 1500);
    expect(half.progress, 0.5);

    final zeroTotal = active.copyWith(totalSeconds: 0, remainingSeconds: 0);
    expect(zeroTotal.progress, 1);
  });

  test('copyWith updates and clears interrupted snapshot', () {
    const snapshot = InterruptedSessionSnapshot(
      kind: SessionKind.shortBreak,
      remainingSeconds: 120,
      sessionInCycle: 3,
    );

    final withSnapshot = SessionState.initial().copyWith(
      interruptedSnapshot: snapshot,
      currentTask: 'Write tests',
      completedSessions: 2,
    );
    expect(withSnapshot.interruptedSnapshot, snapshot);
    expect(withSnapshot.currentTask, 'Write tests');
    expect(withSnapshot.completedSessions, 2);

    final cleared = withSnapshot.copyWith(interruptedSnapshot: null);
    expect(cleared.interruptedSnapshot, isNull);
  });

  test('interrupted snapshot json roundtrip and fallback parsing', () {
    const snapshot = InterruptedSessionSnapshot(
      kind: SessionKind.longBreak,
      remainingSeconds: 42,
      sessionInCycle: 4,
    );
    final json = snapshot.toJson();
    final parsed = InterruptedSessionSnapshot.fromJson(json);

    expect(parsed.kind, SessionKind.longBreak);
    expect(parsed.remainingSeconds, 42);
    expect(parsed.sessionInCycle, 4);

    final fallback = InterruptedSessionSnapshot.fromJson(const {
      'kind': 'not-a-kind',
      'remainingSeconds': null,
      'sessionInCycle': null,
    });
    expect(fallback.kind, SessionKind.focus);
    expect(fallback.remainingSeconds, 0);
    expect(fallback.sessionInCycle, 1);
  });
}

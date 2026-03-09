abstract class FocusAudioDelegate {
  Future<void> onFocusSessionStarted();
  Future<void> onFocusSessionPaused();
  Future<void> onFocusSessionStopped({String reason});
}

class NoopFocusAudioDelegate implements FocusAudioDelegate {
  const NoopFocusAudioDelegate();

  @override
  Future<void> onFocusSessionPaused() async {}

  @override
  Future<void> onFocusSessionStarted() async {}

  @override
  Future<void> onFocusSessionStopped({
    String reason = 'focus_session_stopped',
  }) async {}
}

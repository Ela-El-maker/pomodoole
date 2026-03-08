import 'package:flutter_test/flutter_test.dart';
import 'package:pomodorofocus/services/timer_service.dart';

void main() {
  test('timer service has expected default state', () {
    final service = TimerService();

    expect(service.sessionType, SessionType.focus);
    expect(service.formattedTime, '25:00');
    expect(service.progress, 1.0);
    expect(service.sessionLabel, 'Focus');
    expect(service.isRunning, isFalse);
    expect(service.isPaused, isFalse);
  });
}

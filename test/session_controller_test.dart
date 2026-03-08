import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodorofocus/data/db/app_database.dart';
import 'package:pomodorofocus/data/repositories/session_history_repository.dart';
import 'package:pomodorofocus/services/haptic_service.dart';
import 'package:pomodorofocus/services/home_widget_service.dart';
import 'package:pomodorofocus/services/notification_service.dart';
import 'package:pomodorofocus/state/session/session_controller.dart';
import 'package:pomodorofocus/state/session/session_state.dart';
import 'package:pomodorofocus/state/session/session_tick_driver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeTickDriver implements SessionTickDriver {
  void Function()? _onTick;
  int startCalls = 0;
  int stopCalls = 0;

  @override
  void start({required Duration interval, required void Function() onTick}) {
    startCalls += 1;
    _onTick = onTick;
  }

  @override
  void stop() {
    stopCalls += 1;
    _onTick = null;
  }

  @override
  void dispose() {
    _onTick = null;
  }

  void tick() {
    _onTick?.call();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test(
    'session controller transitions start -> pause -> resume -> stop',
    () async {
      SharedPreferences.setMockInitialValues({
        'notifications_enabled': false,
        'vibration_enabled': false,
        'work_duration': 25,
        'short_break_duration': 5,
        'long_break_duration': 15,
      });

      final prefs = await SharedPreferences.getInstance();
      final tickDriver = FakeTickDriver();
      final database = AppDatabase(NativeDatabase.memory());

      final controller = SessionController(
        preferences: prefs,
        tickDriver: tickDriver,
        notificationService: NotificationService(),
        homeWidgetService: HomeWidgetService(),
        hapticService: HapticService(),
        sessionHistoryRepository: SessionHistoryRepository(database),
      );

      await controller.initialize();

      expect(controller.state.phase, SessionPhase.idle);
      expect(controller.state.remainingSeconds, 1500);

      controller.start();
      expect(controller.state.phase, SessionPhase.focusActive);

      tickDriver.tick();
      expect(controller.state.remainingSeconds, 1499);

      controller.pause();
      expect(controller.state.phase, SessionPhase.focusPaused);

      controller.resume();
      expect(controller.state.phase, SessionPhase.focusActive);

      controller.stop();
      expect(controller.state.phase, SessionPhase.idle);
      expect(controller.state.kind, SessionKind.focus);
      expect(controller.state.remainingSeconds, controller.state.totalSeconds);

      controller.dispose();
      await database.close();
    },
  );

  test('focus completion moves to sessionComplete with break queued', () async {
    SharedPreferences.setMockInitialValues({
      'notifications_enabled': false,
      'vibration_enabled': false,
      'work_duration': 1,
      'short_break_duration': 1,
      'long_break_duration': 1,
    });

    final prefs = await SharedPreferences.getInstance();
    final tickDriver = FakeTickDriver();
    final database = AppDatabase(NativeDatabase.memory());

    final controller = SessionController(
      preferences: prefs,
      tickDriver: tickDriver,
      notificationService: NotificationService(),
      homeWidgetService: HomeWidgetService(),
      hapticService: HapticService(),
      sessionHistoryRepository: SessionHistoryRepository(database),
    );

    await controller.initialize();

    controller.start();
    for (var i = 0; i <= 60; i++) {
      tickDriver.tick();
    }
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.phase, SessionPhase.sessionComplete);
    expect(controller.state.isBreak, isTrue);
    expect(controller.state.kind, SessionKind.shortBreak);
    expect(controller.state.completedSessions, 1);

    controller.dispose();
    await database.close();
  });

  test('rapid start calls do not create duplicate running transitions', () async {
    SharedPreferences.setMockInitialValues({
      'notifications_enabled': false,
      'vibration_enabled': false,
      'work_duration': 25,
      'short_break_duration': 5,
      'long_break_duration': 15,
    });

    final prefs = await SharedPreferences.getInstance();
    final tickDriver = FakeTickDriver();
    final database = AppDatabase(NativeDatabase.memory());

    final controller = SessionController(
      preferences: prefs,
      tickDriver: tickDriver,
      notificationService: NotificationService(),
      homeWidgetService: HomeWidgetService(),
      hapticService: HapticService(),
      sessionHistoryRepository: SessionHistoryRepository(database),
    );

    await controller.initialize();

    controller.start();
    controller.start();
    controller.start();
    tickDriver.tick();

    expect(controller.state.phase, SessionPhase.focusActive);
    expect(tickDriver.startCalls, 1);
    expect(controller.state.remainingSeconds, 1499);

    controller.dispose();
    await database.close();
  });

  test('break completion returns state to idle focus', () async {
    SharedPreferences.setMockInitialValues({
      'notifications_enabled': false,
      'vibration_enabled': false,
      'work_duration': 1,
      'short_break_duration': 1,
      'long_break_duration': 1,
    });

    final prefs = await SharedPreferences.getInstance();
    final tickDriver = FakeTickDriver();
    final database = AppDatabase(NativeDatabase.memory());

    final controller = SessionController(
      preferences: prefs,
      tickDriver: tickDriver,
      notificationService: NotificationService(),
      homeWidgetService: HomeWidgetService(),
      hapticService: HapticService(),
      sessionHistoryRepository: SessionHistoryRepository(database),
    );

    await controller.initialize();

    controller.start();
    for (var i = 0; i <= 60; i++) {
      tickDriver.tick();
    }
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.phase, SessionPhase.sessionComplete);
    expect(controller.state.isBreak, isTrue);

    controller.startBreakAfterCompletion();
    for (var i = 0; i <= 60; i++) {
      tickDriver.tick();
    }
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.phase, SessionPhase.idle);
    expect(controller.state.kind, SessionKind.focus);
    expect(controller.state.remainingSeconds, controller.state.totalSeconds);

    controller.dispose();
    await database.close();
  });

  test('interrupted snapshot restores on next launch', () async {
    SharedPreferences.setMockInitialValues({
      'notifications_enabled': false,
      'vibration_enabled': false,
      'work_duration': 25,
      'short_break_duration': 5,
      'long_break_duration': 15,
    });

    final prefs = await SharedPreferences.getInstance();
    final tickDriver = FakeTickDriver();
    final databaseA = AppDatabase(NativeDatabase.memory());

    final firstController = SessionController(
      preferences: prefs,
      tickDriver: tickDriver,
      notificationService: NotificationService(),
      homeWidgetService: HomeWidgetService(),
      hapticService: HapticService(),
      sessionHistoryRepository: SessionHistoryRepository(databaseA),
    );
    await firstController.initialize();
    firstController.start();
    tickDriver.tick();
    tickDriver.tick();
    final remainingBeforePause = firstController.state.remainingSeconds;
    firstController.didChangeAppLifecycleState(AppLifecycleState.paused);
    await Future<void>.delayed(Duration.zero);
    firstController.dispose();
    await databaseA.close();

    final restoreTickDriver = FakeTickDriver();
    final databaseB = AppDatabase(NativeDatabase.memory());
    final restoredController = SessionController(
      preferences: prefs,
      tickDriver: restoreTickDriver,
      notificationService: NotificationService(),
      homeWidgetService: HomeWidgetService(),
      hapticService: HapticService(),
      sessionHistoryRepository: SessionHistoryRepository(databaseB),
    );
    await restoredController.initialize();

    expect(restoredController.state.interruptedSnapshot, isNotNull);

    restoredController.restoreInterruptedSession();
    expect(restoredController.state.phase, SessionPhase.focusPaused);
    expect(
      restoredController.state.remainingSeconds,
      remainingBeforePause,
    );
    expect(restoredController.state.interruptedSnapshot, isNull);

    restoredController.dispose();
    await databaseB.close();
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodorofocus/services/haptic_service.dart';
import 'package:pomodorofocus/services/home_widget_service.dart';
import 'package:pomodorofocus/services/notification_service.dart';
import 'package:pomodorofocus/state/app/app_providers.dart';
import 'package:pomodorofocus/state/app/data_providers.dart';
import 'package:pomodorofocus/state/session/session_controller.dart';
import 'package:pomodorofocus/state/session/session_state.dart';
import 'package:pomodorofocus/state/session/session_tick_driver.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final homeWidgetServiceProvider = Provider<HomeWidgetService>((ref) {
  return HomeWidgetService();
});

final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService();
});

final sessionTickDriverProvider = Provider<SessionTickDriver>((ref) {
  final tickDriver = TimerSessionTickDriver();
  ref.onDispose(tickDriver.dispose);
  return tickDriver;
});

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
      return SessionController(
        preferences: ref.watch(sharedPreferencesProvider),
        tickDriver: ref.watch(sessionTickDriverProvider),
        notificationService: ref.watch(notificationServiceProvider),
        homeWidgetService: ref.watch(homeWidgetServiceProvider),
        hapticService: ref.watch(hapticServiceProvider),
        sessionHistoryRepository: ref.watch(sessionHistoryRepositoryProvider),
      );
    });

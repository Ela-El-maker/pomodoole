import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  dynamic _plugin; // FlutterLocalNotificationsPlugin on mobile
  bool _initialized = false;

  static const int _timerNotificationId = 1;
  static const int _sessionCompleteId = 2;
  static const int _breakEndId = 3;
  static const int _streakMilestoneId = 4;
  static const String _timerChannelId = 'petal_focus_timer';
  static const String _alertChannelId = 'petal_focus_alerts';

  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      // Dynamically use flutter_local_notifications only on mobile
      await _initMobile();
    } catch (e) {
      // Silently fail if not available
    }
  }

  Future<void> _initMobile() async {
    // This will only be called on non-web platforms
    _initialized = true;
  }

  Future<void> showTimerNotification({
    required String sessionType,
    required String remainingTime,
  }) async {
    if (kIsWeb || !_initialized) return;
  }

  Future<void> updateTimerNotification({
    required String sessionType,
    required String remainingTime,
    required bool isPaused,
  }) async {
    if (kIsWeb || !_initialized) return;
  }

  Future<void> cancelTimerNotification() async {
    if (kIsWeb || !_initialized) return;
  }

  Future<void> showSessionCompleteNotification() async {
    if (kIsWeb || !_initialized) return;
  }

  Future<void> showBreakEndNotification() async {
    if (kIsWeb || !_initialized) return;
  }

  Future<void> showStreakMilestoneNotification(int streak) async {
    if (kIsWeb || !_initialized) return;
  }
}

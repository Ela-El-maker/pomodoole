import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const int _timerNotificationId = 1;
  static const int _sessionCompleteId = 2;
  static const int _breakEndId = 3;
  static const int _streakMilestoneId = 4;

  static const String _timerChannelId = 'petal_focus_timer';
  static const String _alertsChannelId = 'petal_focus_alerts';

  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iOSSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iOSSettings,
      );

      await _plugin.initialize(initSettings);

      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _timerChannelId,
          'Timer Session',
          description: 'Active timer notifications',
          importance: Importance.low,
        ),
      );
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _alertsChannelId,
          'Session Alerts',
          description: 'Session completion and streak notifications',
          importance: Importance.high,
        ),
      );

      _initialized = true;
    } catch (_) {
      // Keep app running when notification setup is unavailable.
    }
  }

  Future<void> showTimerNotification({
    required String sessionType,
    required String remainingTime,
  }) async {
    if (kIsWeb || !_initialized) return;
    await _showOrUpdateTimerNotification(
      sessionType: sessionType,
      remainingTime: remainingTime,
      isPaused: false,
    );
  }

  Future<void> updateTimerNotification({
    required String sessionType,
    required String remainingTime,
    required bool isPaused,
  }) async {
    if (kIsWeb || !_initialized) return;
    await _showOrUpdateTimerNotification(
      sessionType: sessionType,
      remainingTime: remainingTime,
      isPaused: isPaused,
    );
  }

  Future<void> cancelTimerNotification() async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancel(_timerNotificationId);
  }

  Future<void> showSessionCompleteNotification() async {
    if (kIsWeb || !_initialized) return;
    await _plugin.show(
      _sessionCompleteId,
      'Focus session complete',
      'Great work. Time for a mindful break.',
      _alertDetails(),
    );
  }

  Future<void> showBreakEndNotification() async {
    if (kIsWeb || !_initialized) return;
    await _plugin.show(
      _breakEndId,
      'Break finished',
      'Ready for your next focus session?',
      _alertDetails(),
    );
  }

  Future<void> showStreakMilestoneNotification(int streak) async {
    if (kIsWeb || !_initialized) return;
    await _plugin.show(
      _streakMilestoneId,
      'Streak milestone',
      'You reached a $streak-day focus streak.',
      _alertDetails(),
    );
  }

  Future<void> _showOrUpdateTimerNotification({
    required String sessionType,
    required String remainingTime,
    required bool isPaused,
  }) async {
    final pausedSuffix = isPaused ? ' (Paused)' : '';
    await _plugin.show(
      _timerNotificationId,
      '$sessionType$pausedSuffix',
      'Remaining: $remainingTime',
      _timerDetails(),
    );
  }

  NotificationDetails _timerDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _timerChannelId,
        'Timer Session',
        channelDescription: 'Active timer notifications',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        onlyAlertOnce: true,
        category: AndroidNotificationCategory.progress,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      ),
    );
  }

  NotificationDetails _alertDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _alertsChannelId,
        'Session Alerts',
        channelDescription: 'Session completion and streak notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }
}

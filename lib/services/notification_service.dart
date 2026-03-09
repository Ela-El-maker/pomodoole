import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  AudioPlayer? _cuePlayer;

  static const int _timerNotificationId = 1;
  static const int _sessionCompleteId = 2;
  static const int _breakEndId = 3;
  static const int _streakMilestoneId = 4;
  static const int _taskReminderBaseId = 10000;

  static const String _timerChannelId = 'petal_focus_timer';
  static const String _alertsChannelId = 'petal_focus_alerts';
  static const String _taskRemindersChannelId = 'petal_focus_task_reminders';

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
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _taskRemindersChannelId,
          'Task Reminders',
          description: 'One-shot reminders for scheduled tasks',
          importance: Importance.high,
        ),
      );

      tz_data.initializeTimeZones();

      _initialized = true;
    } catch (_) {
      // Keep app running when notification setup is unavailable.
    }
  }

  Future<void> showTimerNotification({
    required String sessionType,
    required String remainingTime,
  }) async {
    if (kIsWeb) return;
    await _ensureInitialized();
    if (!_initialized) return;
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
    if (kIsWeb) return;
    await _ensureInitialized();
    if (!_initialized) return;
    await _showOrUpdateTimerNotification(
      sessionType: sessionType,
      remainingTime: remainingTime,
      isPaused: isPaused,
    );
  }

  Future<void> cancelTimerNotification() async {
    if (kIsWeb) return;
    await _ensureInitialized();
    if (!_initialized) return;
    await _plugin.cancel(_timerNotificationId);
  }

  Future<void> showSessionCompleteNotification() async {
    if (kIsWeb) return;
    await _ensureInitialized();
    if (!_initialized) return;
    await _playConfiguredCue(prefKey: 'default_focus_alert_sound');
    await _plugin.show(
      _sessionCompleteId,
      'Focus session complete',
      'Great work. Time for a mindful break.',
      _alertDetails(),
    );
  }

  Future<void> showBreakEndNotification() async {
    if (kIsWeb) return;
    await _ensureInitialized();
    if (!_initialized) return;
    await _playConfiguredCue(prefKey: 'default_focus_alert_sound');
    await _plugin.show(
      _breakEndId,
      'Break finished',
      'Ready for your next focus session?',
      _alertDetails(),
    );
  }

  Future<void> showStreakMilestoneNotification(int streak) async {
    if (kIsWeb) return;
    await _ensureInitialized();
    if (!_initialized) return;
    await _plugin.show(
      _streakMilestoneId,
      'Streak milestone',
      'You reached a $streak-day focus streak.',
      _alertDetails(),
    );
  }

  Future<void> showTaskDueNotification({
    required String taskId,
    required String taskTitle,
    String? notes,
  }) async {
    if (kIsWeb) return;
    await _ensureInitialized();
    if (!_initialized) return;
    await _playConfiguredCue(prefKey: 'default_task_reminder_sound');
    await _plugin.show(
      _taskNotificationId(taskId),
      'Task reminder',
      notes?.trim().isNotEmpty == true
          ? '$taskTitle\n${notes!.trim()}'
          : taskTitle,
      _taskReminderDetails(),
      payload: 'task:$taskId',
    );
  }

  Future<void> scheduleTaskReminder({
    required String taskId,
    required String taskTitle,
    required DateTime scheduledAtLocal,
    String? notes,
  }) async {
    if (kIsWeb) return;
    await _ensureInitialized();
    if (!_initialized) return;

    final now = DateTime.now();
    if (!scheduledAtLocal.isAfter(now.add(const Duration(seconds: 2)))) {
      await showTaskDueNotification(
        taskId: taskId,
        taskTitle: taskTitle,
        notes: notes,
      );
      return;
    }

    await _plugin.zonedSchedule(
      _taskNotificationId(taskId),
      'Task reminder',
      notes?.trim().isNotEmpty == true
          ? '$taskTitle\n${notes!.trim()}'
          : taskTitle,
      tz.TZDateTime.from(scheduledAtLocal, tz.local),
      _taskReminderDetails(),
      payload: 'task:$taskId',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelTaskReminder(String taskId) async {
    if (kIsWeb) return;
    await _ensureInitialized();
    if (!_initialized) return;
    await _plugin.cancel(_taskNotificationId(taskId));
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await initialize();
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

  NotificationDetails _taskReminderDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _taskRemindersChannelId,
        'Task Reminders',
        channelDescription: 'One-shot reminders for scheduled tasks',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  int _taskNotificationId(String taskId) {
    return _taskReminderBaseId + (taskId.hashCode.abs() % 1000000);
  }

  Future<void> _playConfiguredCue({required String prefKey}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('notifications_enabled') ?? true;
      final volume = (prefs.getDouble('volume') ?? 0.8).clamp(0.0, 1.0);
      if (!enabled || volume <= 0) return;

      final soundLabel =
          prefs.getString(prefKey) ?? prefs.getString('selected_sound');
      final assetPath = switch (soundLabel) {
        'Birdsong' => 'sounds/bird-song-1.mp3',
        'Fireplace' => 'sounds/fire-place-1.mp3',
        'Rain' => 'sounds/rain-1.mp3',
        'Forest' => 'sounds/forest-1.mp3',
        'Cafe' => 'sounds/cafe-1.mp3',
        _ => null,
      };
      if (assetPath == null) return;

      final cuePlayer = await _getCuePlayer();
      if (cuePlayer == null) return;
      await cuePlayer.stop();
      await cuePlayer.play(
        AssetSource(assetPath),
        volume: volume.toDouble(),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      // Keep notifications reliable even if cue playback fails.
    }
  }

  Future<AudioPlayer?> _getCuePlayer() async {
    if (_cuePlayer != null) return _cuePlayer;
    try {
      _cuePlayer = AudioPlayer();
      return _cuePlayer;
    } catch (_) {
      return null;
    }
  }
}

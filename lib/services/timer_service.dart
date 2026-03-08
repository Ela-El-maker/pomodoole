import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './home_widget_service.dart';
import './notification_service.dart';

// Conditional imports for platform-specific features

enum SessionType { focus, shortBreak, longBreak }

class TimerService {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  // State
  SessionType _sessionType = SessionType.focus;
  int _remainingSeconds = 25 * 60;
  int _totalSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isPaused = false;
  int _completedSessions = 0;
  int _sessionInCycle = 1;
  int _currentStreak = 0;
  String _currentTask = '';

  Timer? _timer;

  // Settings
  int _workDuration = 25;
  int _shortBreakDuration = 5;
  int _longBreakDuration = 15;
  bool _notificationsEnabled = true;
  bool _vibrationEnabled = true;

  // Stream controllers for UI updates
  final StreamController<TimerState> _stateController =
      StreamController<TimerState>.broadcast();

  Stream<TimerState> get stateStream => _stateController.stream;

  // Getters
  SessionType get sessionType => _sessionType;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  int get completedSessions => _completedSessions;
  int get sessionInCycle => _sessionInCycle;
  int get currentStreak => _currentStreak;
  String get currentTask => _currentTask;

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress =>
      _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 1.0;

  String get sessionLabel {
    switch (_sessionType) {
      case SessionType.focus:
        return 'Focus';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  String get sessionTypeForNotification {
    switch (_sessionType) {
      case SessionType.focus:
        return 'Focus Session';
      case SessionType.shortBreak:
      case SessionType.longBreak:
        return 'Break Time';
    }
  }

  Future<void> initialize() async {
    await _loadSettings();
    await _loadState();
    if (!kIsWeb) {
      await NotificationService().initialize();
      await HomeWidgetService().initialize();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _workDuration = prefs.getInt('work_duration') ?? 25;
    _shortBreakDuration = prefs.getInt('short_break_duration') ?? 5;
    _longBreakDuration = prefs.getInt('long_break_duration') ?? 15;
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
    _currentStreak = prefs.getInt('current_streak') ?? 0;
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _completedSessions = prefs.getInt('completed_sessions') ?? 0;
    _sessionInCycle = prefs.getInt('session_in_cycle') ?? 1;
    _currentTask = prefs.getString('current_task') ?? '';
    _updateTotalDuration();
    _remainingSeconds = _totalSeconds;
  }

  void _updateTotalDuration() {
    switch (_sessionType) {
      case SessionType.focus:
        _totalSeconds = _workDuration * 60;
        break;
      case SessionType.shortBreak:
        _totalSeconds = _shortBreakDuration * 60;
        break;
      case SessionType.longBreak:
        _totalSeconds = _longBreakDuration * 60;
        break;
    }
  }

  void setCurrentTask(String task) {
    _currentTask = task;
    _saveState();
  }

  void start() {
    if (_isRunning) return;
    if (!kIsWeb && _vibrationEnabled) HapticFeedback.mediumImpact();
    _isRunning = true;
    _isPaused = false;
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    _notifyListeners();
    if (!kIsWeb && _notificationsEnabled) {
      NotificationService().showTimerNotification(
        sessionType: sessionTypeForNotification,
        remainingTime: formattedTime,
      );
    }
    _updateHomeWidget();
  }

  void pause() {
    if (!_isRunning) return;
    if (!kIsWeb && _vibrationEnabled) HapticFeedback.lightImpact();
    _timer?.cancel();
    _isRunning = false;
    _isPaused = true;
    _notifyListeners();
    if (!kIsWeb && _notificationsEnabled) {
      NotificationService().updateTimerNotification(
        sessionType: sessionTypeForNotification,
        remainingTime: formattedTime,
        isPaused: true,
      );
    }
    _updateHomeWidget();
  }

  void resume() {
    if (_isRunning) return;
    start();
  }

  void stop() {
    if (!kIsWeb && _vibrationEnabled) HapticFeedback.heavyImpact();
    _timer?.cancel();
    _isRunning = false;
    _isPaused = false;
    _updateTotalDuration();
    _remainingSeconds = _totalSeconds;
    _notifyListeners();
    if (!kIsWeb) {
      NotificationService().cancelTimerNotification();
    }
    _updateHomeWidget();
  }

  void _onTick(Timer timer) {
    if (_remainingSeconds > 0) {
      _remainingSeconds--;
      _notifyListeners();
      if (!kIsWeb && _notificationsEnabled) {
        NotificationService().updateTimerNotification(
          sessionType: sessionTypeForNotification,
          remainingTime: formattedTime,
          isPaused: false,
        );
      }
      _updateHomeWidget();
    } else {
      _onSessionComplete();
    }
  }

  void _onSessionComplete() {
    _timer?.cancel();
    if (!kIsWeb && _vibrationEnabled) HapticFeedback.vibrate();
    _isRunning = false;
    _isPaused = false;

    final wasWork = _sessionType == SessionType.focus;

    if (wasWork) {
      _completedSessions++;
      if (_sessionInCycle >= 4) {
        _sessionType = SessionType.longBreak;
        _sessionInCycle = 1;
      } else {
        _sessionType = SessionType.shortBreak;
        _sessionInCycle++;
      }
      // Update streak
      _updateStreak();
      // Send session complete notification
      if (!kIsWeb && _notificationsEnabled) {
        NotificationService().cancelTimerNotification();
        NotificationService().showSessionCompleteNotification();
      }
    } else {
      _sessionType = SessionType.focus;
      // Send break end notification
      if (!kIsWeb && _notificationsEnabled) {
        NotificationService().cancelTimerNotification();
        NotificationService().showBreakEndNotification();
      }
    }

    _updateTotalDuration();
    _remainingSeconds = _totalSeconds;
    _saveState();
    _notifyListeners();
    _updateHomeWidget();
  }

  Future<void> _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSessionDate = prefs.getString('last_session_date');
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (lastSessionDate == null) {
      _currentStreak = 1;
    } else {
      final last = DateTime.parse(lastSessionDate);
      final diff = today.difference(last).inDays;
      if (diff == 0) {
        // Same day, no change
      } else if (diff == 1) {
        _currentStreak++;
      } else {
        _currentStreak = 1;
      }
    }

    await prefs.setInt('current_streak', _currentStreak);
    await prefs.setString('last_session_date', todayStr);

    // Check streak milestones
    const milestones = [3, 7, 14, 30];
    if (milestones.contains(_currentStreak) &&
        !kIsWeb &&
        _notificationsEnabled) {
      unawaited(
        NotificationService().showStreakMilestoneNotification(_currentStreak),
      );
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('completed_sessions', _completedSessions);
    await prefs.setInt('session_in_cycle', _sessionInCycle);
    await prefs.setString('current_task', _currentTask);
    // Save widget data
    await prefs.setString('widget_time', formattedTime);
    await prefs.setString('widget_session', sessionLabel);
    await prefs.setBool('widget_running', _isRunning);
  }

  void _updateHomeWidget() {
    if (!kIsWeb) {
      HomeWidgetService().updateWidget(
        formattedTime: formattedTime,
        sessionLabel: sessionLabel,
        isRunning: _isRunning,
        sessionType: _sessionType.name,
      );
    }
    _saveState();
  }

  void _notifyListeners() {
    if (!_stateController.isClosed) {
      _stateController.add(
        TimerState(
          sessionType: _sessionType,
          remainingSeconds: _remainingSeconds,
          totalSeconds: _totalSeconds,
          isRunning: _isRunning,
          isPaused: _isPaused,
          completedSessions: _completedSessions,
          sessionInCycle: _sessionInCycle,
          currentStreak: _currentStreak,
          formattedTime: formattedTime,
          progress: progress,
          sessionLabel: sessionLabel,
          currentTask: _currentTask,
        ),
      );
    }
  }

  void reloadSettings() {
    _loadSettings();
  }

  /// Resume timer from an interrupted session with a specific remaining seconds
  void resumeFromInterruption(int remainingSeconds) {
    if (remainingSeconds <= 0) return;
    _remainingSeconds = remainingSeconds;
    _isRunning = false;
    _isPaused = true;
    _notifyListeners();
    // Auto-start after restoring
    start();
  }

  void dispose() {
    _timer?.cancel();
    _stateController.close();
  }
}

class TimerState {
  final SessionType sessionType;
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final bool isPaused;
  final int completedSessions;
  final int sessionInCycle;
  final int currentStreak;
  final String formattedTime;
  final double progress;
  final String sessionLabel;
  final String currentTask;

  const TimerState({
    required this.sessionType,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
    required this.isPaused,
    required this.completedSessions,
    required this.sessionInCycle,
    required this.currentStreak,
    required this.formattedTime,
    required this.progress,
    required this.sessionLabel,
    required this.currentTask,
  });
}

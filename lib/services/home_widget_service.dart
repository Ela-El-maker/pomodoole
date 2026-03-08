import 'package:flutter/foundation.dart';

import './timer_service.dart';

class HomeWidgetService {
  static final HomeWidgetService _instance = HomeWidgetService._internal();
  factory HomeWidgetService() => _instance;
  HomeWidgetService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      _initialized = true;
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> updateWidget({
    required String formattedTime,
    required String sessionLabel,
    required bool isRunning,
    required SessionType sessionType,
  }) async {
    if (kIsWeb || !_initialized) return;
    // Widget data is saved to SharedPreferences by TimerService._saveState()
    // The Android PetalFocusWidget reads from SharedPreferences directly
    // home_widget package updates are handled natively
  }
}

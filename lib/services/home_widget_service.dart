import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  static final HomeWidgetService _instance = HomeWidgetService._internal();
  factory HomeWidgetService() => _instance;
  HomeWidgetService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await HomeWidget.setAppGroupId('group.io.petalfocus.app');
      _initialized = true;
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> updateWidget({
    required String formattedTime,
    required String sessionLabel,
    required bool isRunning,
    required String sessionType,
  }) async {
    if (kIsWeb || !_initialized) return;
    await HomeWidget.saveWidgetData<String>('widget_time', formattedTime);
    await HomeWidget.saveWidgetData<String>('widget_session', sessionLabel);
    await HomeWidget.saveWidgetData<bool>('widget_running', isRunning);
    await HomeWidget.saveWidgetData<String>('widget_type', sessionType);
    await HomeWidget.updateWidget(
      androidName: 'PetalFocusWidget',
      iOSName: 'PetalFocusWidget',
    );
  }
}

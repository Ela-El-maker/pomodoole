import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import './app_state_service.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  final AppStateService _appState = AppStateService();

  /// General button press haptic
  void buttonPress() {
    if (!_appState.hapticOnButtonPress) return;
    _triggerByIntensity();
  }

  /// Session start haptic
  void sessionStart() {
    if (!_appState.hapticOnSessionStart) return;
    _triggerByIntensity();
  }

  /// Session complete haptic
  void sessionComplete() {
    if (!_appState.hapticOnSessionComplete) return;
    _triggerByIntensity();
  }

  /// Generic haptic with intensity
  void trigger() {
    _triggerByIntensity();
  }

  void _triggerByIntensity() {
    if (kIsWeb) return;
    switch (_appState.hapticIntensity) {
      case HapticIntensity.none:
        break;
      case HapticIntensity.light:
        HapticFeedback.lightImpact();
        break;
      case HapticIntensity.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticIntensity.strong:
        HapticFeedback.heavyImpact();
        break;
    }
  }
}

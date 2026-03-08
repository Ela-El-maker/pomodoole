import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AudioState { normal, retrying, error, silent }

enum HapticIntensity { none, light, medium, strong }

class AppStateService extends ChangeNotifier {
  static final AppStateService _instance = AppStateService._internal();
  factory AppStateService() => _instance;
  AppStateService._internal();

  // Audio state
  AudioState _audioState = AudioState.normal;
  AudioState get audioState => _audioState;

  // High contrast mode
  bool _highContrastMode = false;
  bool get highContrastMode => _highContrastMode;

  // Haptic preferences
  HapticIntensity _hapticIntensity = HapticIntensity.medium;
  HapticIntensity get hapticIntensity => _hapticIntensity;

  bool _hapticOnSessionStart = true;
  bool get hapticOnSessionStart => _hapticOnSessionStart;

  bool _hapticOnSessionComplete = true;
  bool get hapticOnSessionComplete => _hapticOnSessionComplete;

  bool _hapticOnButtonPress = true;
  bool get hapticOnButtonPress => _hapticOnButtonPress;

  bool _reduceMotion = false;
  bool get reduceMotion => _reduceMotion;

  // Session interruption
  bool _hasInterruptedSession = false;
  bool get hasInterruptedSession => _hasInterruptedSession;
  int _interruptedRemainingSeconds = 0;
  int get interruptedRemainingSeconds => _interruptedRemainingSeconds;
  String _interruptedSessionType = 'Focus';
  String get interruptedSessionType => _interruptedSessionType;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _highContrastMode = prefs.getBool('high_contrast_mode') ?? false;
    final storedHapticIntensity = prefs.getInt('haptic_intensity');
    if (storedHapticIntensity != null &&
        storedHapticIntensity >= 0 &&
        storedHapticIntensity < HapticIntensity.values.length) {
      _hapticIntensity = HapticIntensity.values[storedHapticIntensity];
    } else {
      _hapticIntensity = HapticIntensity.medium;
    }
    _hapticOnSessionStart = prefs.getBool('haptic_on_session_start') ?? true;
    _hapticOnSessionComplete =
        prefs.getBool('haptic_on_session_complete') ?? true;
    _hapticOnButtonPress = prefs.getBool('haptic_on_button_press') ?? true;
    _reduceMotion = prefs.getBool('reduce_motion') ?? false;

    // Check for interrupted session
    final sessionInProgress = prefs.getBool('sessionInProgress') ?? false;
    if (sessionInProgress) {
      _hasInterruptedSession = true;
      _interruptedRemainingSeconds = prefs.getInt('savedRemainingSeconds') ?? 0;
      _interruptedSessionType = prefs.getString('savedSessionType') ?? 'Focus';
    }
    notifyListeners();
  }

  // Audio state management
  void setAudioState(AudioState state) {
    _audioState = state;
    notifyListeners();
  }

  // High contrast mode
  Future<void> setHighContrastMode(bool value) async {
    _highContrastMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast_mode', value);
    notifyListeners();
  }

  // Haptic intensity
  Future<void> setHapticIntensity(HapticIntensity intensity) async {
    _hapticIntensity = intensity;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('haptic_intensity', intensity.index);
    notifyListeners();
  }

  Future<void> setHapticOnSessionStart(bool value) async {
    _hapticOnSessionStart = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic_on_session_start', value);
    notifyListeners();
  }

  Future<void> setHapticOnSessionComplete(bool value) async {
    _hapticOnSessionComplete = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic_on_session_complete', value);
    notifyListeners();
  }

  Future<void> setHapticOnButtonPress(bool value) async {
    _hapticOnButtonPress = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic_on_button_press', value);
    notifyListeners();
  }

  Future<void> setReduceMotion(bool value) async {
    _reduceMotion = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reduce_motion', value);
    notifyListeners();
  }

  // Session interruption management
  Future<void> markSessionInProgress({
    required int remainingSeconds,
    required String sessionType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sessionInProgress', true);
    await prefs.setInt('savedRemainingSeconds', remainingSeconds);
    await prefs.setString('savedSessionType', sessionType);
  }

  Future<void> clearInterruptedSession() async {
    _hasInterruptedSession = false;
    _interruptedRemainingSeconds = 0;
    _interruptedSessionType = 'Focus';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sessionInProgress', false);
    await prefs.remove('savedRemainingSeconds');
    await prefs.remove('savedSessionType');
    notifyListeners();
  }

  Future<void> clearSessionInProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sessionInProgress', false);
  }
}

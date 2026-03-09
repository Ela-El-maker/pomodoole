import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/app_state_service.dart';
import '../../services/haptic_service.dart';
import '../../app/router/route_paths.dart';
import '../../state/session/session_providers.dart';
import './widgets/audio_preferences_section_widget.dart';
import './widgets/settings_section_header_widget.dart';
import './widgets/timer_duration_section_widget.dart';
import './widgets/vibration_settings_section_widget.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Timer durations
  int _workDuration = 25;
  int _shortBreakDuration = 5;
  int _longBreakDuration = 15;

  // Audio preferences
  bool _soundEnabled = true;
  double _volume = 0.8;
  String _selectedSound = 'Bell';
  String _defaultFocusAlertSound = 'Bell';
  String _defaultTaskReminderSound = 'Bell';

  // Vibration settings
  bool _vibrationEnabled = true;
  bool _completionVibration = true;

  // Accessibility
  bool _highContrastMode = false;

  // Haptic / Motor Accessibility
  HapticIntensity _hapticIntensity = HapticIntensity.medium;
  bool _hapticOnSessionStart = true;
  bool _hapticOnSessionComplete = true;
  bool _hapticOnButtonPress = true;
  bool _reduceMotion = false;

  bool _isLoading = true;

  final AppStateService _appState = AppStateService();
  final HapticService _haptic = HapticService();
  final AudioPlayer _previewPlayer = AudioPlayer();

  final List<String> _soundOptions = [
    'Birdsong',
    'Fireplace',
    'Rain',
    'Forest',
    'Cafe',
  ];

  // Focus nodes for keyboard navigation
  final List<FocusNode> _focusNodes = List.generate(12, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    unawaited(_previewPlayer.dispose());
    for (final fn in _focusNodes) {
      fn.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _workDuration = prefs.getInt('work_duration') ?? 25;
      _shortBreakDuration = prefs.getInt('short_break_duration') ?? 5;
      _longBreakDuration = prefs.getInt('long_break_duration') ?? 15;
      _soundEnabled = prefs.getBool('notifications_enabled') ?? true;
      _volume = prefs.getDouble('volume') ?? 0.8;
      _selectedSound = prefs.getString('selected_sound') ?? 'Birdsong';
      _defaultFocusAlertSound =
          prefs.getString('default_focus_alert_sound') ?? _selectedSound;
      _defaultTaskReminderSound =
          prefs.getString('default_task_reminder_sound') ?? _selectedSound;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _completionVibration = prefs.getBool('completion_vibration') ?? true;
      _highContrastMode = _appState.highContrastMode;
      _hapticIntensity = _appState.hapticIntensity;
      _hapticOnSessionStart = _appState.hapticOnSessionStart;
      _hapticOnSessionComplete = _appState.hapticOnSessionComplete;
      _hapticOnButtonPress = _appState.hapticOnButtonPress;
      _reduceMotion = _appState.reduceMotion;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is int) await prefs.setInt(key, value);
    if (value is bool) await prefs.setBool(key, value);
    if (value is double) await prefs.setDouble(key, value);
    if (value is String) await prefs.setString(key, value);

    ref
        .read(sessionControllerProvider.notifier)
        .updateDurations(
          workDurationMinutes: _workDuration,
          shortBreakDurationMinutes: _shortBreakDuration,
          longBreakDurationMinutes: _longBreakDuration,
        );

    _showSavedFeedback();
  }

  void _showSavedFeedback() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved'),
        duration: Duration(milliseconds: 800),
      ),
    );
  }

  Future<void> _showResetConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Text('Reset to Defaults', style: theme.textTheme.titleMedium),
          content: Text(
            'This will reset all settings to their default values. Are you sure?',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await _resetToDefaults();
    }
  }

  Future<void> _resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('work_duration');
    await prefs.remove('short_break_duration');
    await prefs.remove('long_break_duration');
    await prefs.remove('notifications_enabled');
    await prefs.remove('volume');
    await prefs.remove('selected_sound');
    await prefs.remove('default_focus_alert_sound');
    await prefs.remove('default_task_reminder_sound');
    await prefs.remove('vibration_enabled');
    await prefs.remove('completion_vibration');
    setState(() {
      _workDuration = 25;
      _shortBreakDuration = 5;
      _longBreakDuration = 15;
      _soundEnabled = true;
      _volume = 0.8;
      _selectedSound = 'Birdsong';
      _defaultFocusAlertSound = 'Birdsong';
      _defaultTaskReminderSound = 'Birdsong';
      _vibrationEnabled = true;
      _completionVibration = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings reset to defaults')),
      );
    }
  }

  void _showDurationPicker(
    String label,
    int currentValue,
    int min,
    int max,
    ValueChanged<int> onChanged,
  ) {
    int tempValue = currentValue;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return StatefulBuilder(
          builder: (ctx2, setModalState) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: theme.textTheme.titleMedium),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: tempValue > min
                            ? () => setModalState(() => tempValue--)
                            : null,
                        icon: CustomIconWidget(
                          iconName: 'remove_circle_outline',
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '$tempValue min',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      IconButton(
                        onPressed: tempValue < max
                            ? () => setModalState(() => tempValue++)
                            : null,
                        icon: CustomIconWidget(
                          iconName: 'add_circle_outline',
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx2).pop();
                        onChanged(tempValue);
                      },
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSoundPicker() {
    _showSoundSelectionBottomSheet(
      title: 'Select Notification Sound',
      current: _selectedSound,
      onSelected: (sound) async {
        setState(() => _selectedSound = sound);
        await _saveSetting('selected_sound', sound);
        await _previewSound(sound);
      },
    );
  }

  void _showDefaultSoundPicker({
    required String title,
    required String current,
    required ValueChanged<String> onSelected,
  }) {
    _showSoundSelectionBottomSheet(
      title: title,
      current: current,
      onSelected: (sound) async {
        onSelected(sound);
        await _previewSound(sound);
      },
    );
  }

  void _showSoundSelectionBottomSheet({
    required String title,
    required String current,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const Divider(),
              ..._soundOptions.map(
                (sound) => ListTile(
                  title: Text(sound, style: theme.textTheme.bodyLarge),
                  trailing: current == sound
                      ? CustomIconWidget(
                          iconName: 'check_circle',
                          color: theme.colorScheme.primary,
                          size: 22,
                        )
                      : null,
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    onSelected(sound);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _previewSound(String soundLabel) async {
    final relativePath = switch (soundLabel) {
      'Birdsong' => 'sounds/bird-song-1.mp3',
      'Fireplace' => 'sounds/fire-place-1.mp3',
      'Rain' => 'sounds/rain-1.mp3',
      'Forest' => 'sounds/forest-1.mp3',
      'Cafe' => 'sounds/cafe-1.mp3',
      _ => null,
    };

    if (relativePath == null || !_soundEnabled) return;
    try {
      await _previewPlayer.stop();
      await _previewPlayer.play(
        AssetSource(relativePath),
        volume: _volume.clamp(0.0, 1.0).toDouble(),
      );
      Future<void>.delayed(const Duration(milliseconds: 1800), () {
        unawaited(_previewPlayer.stop());
      });
    } catch (_) {
      // Keep settings stable if preview playback fails on some devices.
    }
  }

  Widget _buildSettingsRow({
    required String title,
    String? subtitle,
    required Widget trailing,
    VoidCallback? onTap,
    FocusNode? focusNode,
    String? semanticsLabel,
  }) {
    return Semantics(
      label: semanticsLabel ?? title,
      child: Focus(
        focusNode: focusNode,
        child: Builder(
          builder: (ctx) {
            final hasFocus = Focus.of(ctx).hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(bottom: 1.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF0EFEA),
                borderRadius: BorderRadius.circular(16.0),
                border: hasFocus
                    ? Border.all(color: const Color(0xFFA8C3A0), width: 2)
                    : null,
              ),
              child: ListTile(
                onTap: onTap,
                title: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2F2F2F),
                  ),
                ),
                subtitle: subtitle != null
                    ? Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF6F6F6F),
                        ),
                      )
                    : null,
                trailing: trailing,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHapticIntensitySelector() {
    final options = [
      (HapticIntensity.none, 'None'),
      (HapticIntensity.light, 'Light'),
      (HapticIntensity.medium, 'Medium'),
      (HapticIntensity.strong, 'Strong'),
    ];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EFEA),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Haptic Intensity',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2F2F2F),
            ),
          ),
          SizedBox(height: 1.h),
          Semantics(
            label:
                'Haptic intensity selector, currently ${_hapticIntensity.name}',
            child: Row(
              children: options.map((opt) {
                final isSelected = _hapticIntensity == opt.$1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _haptic.buttonPress();
                      setState(() => _hapticIntensity = opt.$1);
                      _appState.setHapticIntensity(opt.$1);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                        right: opt.$1 != HapticIntensity.strong ? 1.w : 0,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE76F6F)
                            : Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFE76F6F)
                              : const Color(0xFFD0D0D0),
                        ),
                      ),
                      child: Text(
                        opt.$2,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6F6F6F),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          onPressed: () => context.go(AppRoutes.timer),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color:
                theme.appBarTheme.foregroundColor ??
                theme.colorScheme.onSurface,
            size: 24,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                child: FocusTraversalGroup(
                  policy: OrderedTraversalPolicy(),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Timer Duration ──
                        SettingsSectionHeaderWidget(title: 'Timer Duration'),
                        SizedBox(height: 1.h),
                        TimerDurationSectionWidget(
                          workDuration: _workDuration,
                          shortBreakDuration: _shortBreakDuration,
                          longBreakDuration: _longBreakDuration,
                          onWorkDurationTap: () => _showDurationPicker(
                            'Work Session Duration',
                            _workDuration,
                            1,
                            60,
                            (val) {
                              setState(() => _workDuration = val);
                              _saveSetting('work_duration', val);
                            },
                          ),
                          onShortBreakTap: () => _showDurationPicker(
                            'Short Break Duration',
                            _shortBreakDuration,
                            1,
                            30,
                            (val) {
                              setState(() => _shortBreakDuration = val);
                              _saveSetting('short_break_duration', val);
                            },
                          ),
                          onLongBreakTap: () => _showDurationPicker(
                            'Long Break Duration',
                            _longBreakDuration,
                            5,
                            60,
                            (val) {
                              setState(() => _longBreakDuration = val);
                              _saveSetting('long_break_duration', val);
                            },
                          ),
                        ),
                        SizedBox(height: 3.h),

                        // ── Audio Preferences ──
                        SettingsSectionHeaderWidget(title: 'Audio Preferences'),
                        SizedBox(height: 1.h),
                        AudioPreferencesSectionWidget(
                          soundEnabled: _soundEnabled,
                          volume: _volume,
                          selectedSound: _selectedSound,
                          onSoundToggle: (val) {
                            setState(() => _soundEnabled = val);
                            _saveSetting('notifications_enabled', val);
                            ref
                                .read(sessionControllerProvider.notifier)
                                .setNotificationsEnabled(val);
                          },
                          onVolumeChanged: (val) {
                            setState(() => _volume = val);
                          },
                          onVolumeChangeEnd: (val) async {
                            await _saveSetting('volume', val);
                            await _previewSound(_selectedSound);
                          },
                          onSoundPickerTap: _showSoundPicker,
                        ),
                        SizedBox(height: 1.h),
                        _buildSettingsRow(
                          title: 'Focus completion sound',
                          subtitle: _defaultFocusAlertSound,
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: _soundEnabled
                              ? () => _showDefaultSoundPicker(
                                  title: 'Focus Completion Sound',
                                  current: _defaultFocusAlertSound,
                                  onSelected: (sound) {
                                    setState(
                                      () => _defaultFocusAlertSound = sound,
                                    );
                                    unawaited(
                                      _saveSetting(
                                        'default_focus_alert_sound',
                                        sound,
                                      ),
                                    );
                                  },
                                )
                              : null,
                        ),
                        _buildSettingsRow(
                          title: 'Task reminder sound',
                          subtitle: _defaultTaskReminderSound,
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: _soundEnabled
                              ? () => _showDefaultSoundPicker(
                                  title: 'Task Reminder Sound',
                                  current: _defaultTaskReminderSound,
                                  onSelected: (sound) {
                                    setState(
                                      () => _defaultTaskReminderSound = sound,
                                    );
                                    unawaited(
                                      _saveSetting(
                                        'default_task_reminder_sound',
                                        sound,
                                      ),
                                    );
                                  },
                                )
                              : null,
                        ),
                        SizedBox(height: 1.5.h),
                        // Sound Mixer navigation
                        Semantics(
                          label:
                              'Sound Mixer, create custom ambient atmospheres',
                          button: true,
                          child: GestureDetector(
                            onTap: () =>
                                context.push(AppRoutes.customSoundMixer),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.8.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0EFEA),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Row(
                                children: [
                                  ExcludeSemantics(
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFE76F6F,
                                        ).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.library_music_rounded,
                                        color: Color(0xFFE76F6F),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Sound Mixer',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF2F2F2F),
                                          ),
                                        ),
                                        Text(
                                          'Create custom ambient atmospheres',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w300,
                                            color: const Color(0xFF6F6F6F),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ExcludeSemantics(
                                    child: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: Color(0xFF6F6F6F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),

                        // ── Vibration Settings ──
                        SettingsSectionHeaderWidget(
                          title: 'Vibration Settings',
                        ),
                        SizedBox(height: 1.h),
                        VibrationSettingsSectionWidget(
                          vibrationEnabled: _vibrationEnabled,
                          completionVibration: _completionVibration,
                          onVibrationToggle: (val) {
                            setState(() => _vibrationEnabled = val);
                            _saveSetting('vibration_enabled', val);
                            ref
                                .read(sessionControllerProvider.notifier)
                                .setVibrationEnabled(val);
                          },
                          onCompletionVibrationToggle: (val) {
                            setState(() => _completionVibration = val);
                            _saveSetting('completion_vibration', val);
                            _appState.setHapticOnSessionComplete(val);
                          },
                        ),
                        SizedBox(height: 3.h),

                        // ── Appearance ──
                        SettingsSectionHeaderWidget(title: 'Appearance'),
                        SizedBox(height: 1.h),
                        _buildSettingsRow(
                          title: 'High Contrast Mode',
                          subtitle: 'Increases contrast for better readability',
                          semanticsLabel:
                              'High Contrast Mode, currently ${_highContrastMode ? 'on' : 'off'}',
                          focusNode: _focusNodes[0],
                          trailing: Semantics(
                            label:
                                'High contrast mode toggle, currently ${_highContrastMode ? 'enabled' : 'disabled'}',
                            child: Switch(
                              value: _highContrastMode,
                              activeThumbColor: const Color(0xFFE76F6F),
                              onChanged: (val) {
                                _haptic.buttonPress();
                                setState(() => _highContrastMode = val);
                                _appState.setHighContrastMode(val);
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),

                        // ── Motor Accessibility ──
                        SettingsSectionHeaderWidget(
                          title: 'Motor Accessibility',
                        ),
                        SizedBox(height: 1.h),
                        _buildHapticIntensitySelector(),
                        SizedBox(height: 1.h),
                        _buildSettingsRow(
                          title: 'Haptic on Session Start',
                          semanticsLabel:
                              'Haptic feedback on session start, currently ${_hapticOnSessionStart ? 'on' : 'off'}',
                          focusNode: _focusNodes[1],
                          trailing: Semantics(
                            label:
                                'Haptic on session start toggle, currently ${_hapticOnSessionStart ? 'enabled' : 'disabled'}',
                            child: Switch(
                              value: _hapticOnSessionStart,
                              activeThumbColor: const Color(0xFFE76F6F),
                              onChanged: (val) {
                                _haptic.buttonPress();
                                setState(() => _hapticOnSessionStart = val);
                                _appState.setHapticOnSessionStart(val);
                              },
                            ),
                          ),
                        ),
                        _buildSettingsRow(
                          title: 'Haptic on Session Complete',
                          semanticsLabel:
                              'Haptic feedback on session complete, currently ${_hapticOnSessionComplete ? 'on' : 'off'}',
                          focusNode: _focusNodes[2],
                          trailing: Semantics(
                            label:
                                'Haptic on session complete toggle, currently ${_hapticOnSessionComplete ? 'enabled' : 'disabled'}',
                            child: Switch(
                              value: _hapticOnSessionComplete,
                              activeThumbColor: const Color(0xFFE76F6F),
                              onChanged: (val) {
                                _haptic.buttonPress();
                                setState(() => _hapticOnSessionComplete = val);
                                _appState.setHapticOnSessionComplete(val);
                              },
                            ),
                          ),
                        ),
                        _buildSettingsRow(
                          title: 'Haptic on Button Press',
                          semanticsLabel:
                              'Haptic feedback on button press, currently ${_hapticOnButtonPress ? 'on' : 'off'}',
                          focusNode: _focusNodes[3],
                          trailing: Semantics(
                            label:
                                'Haptic on button press toggle, currently ${_hapticOnButtonPress ? 'enabled' : 'disabled'}',
                            child: Switch(
                              value: _hapticOnButtonPress,
                              activeThumbColor: const Color(0xFFE76F6F),
                              onChanged: (val) {
                                _haptic.buttonPress();
                                setState(() => _hapticOnButtonPress = val);
                                _appState.setHapticOnButtonPress(val);
                              },
                            ),
                          ),
                        ),
                        _buildSettingsRow(
                          title: 'Reduce Motion',
                          subtitle:
                              'Disables animations and timer pulse effect',
                          semanticsLabel:
                              'Reduce motion, currently ${_reduceMotion ? 'on' : 'off'}',
                          focusNode: _focusNodes[4],
                          trailing: Semantics(
                            label:
                                'Reduce motion toggle, currently ${_reduceMotion ? 'enabled' : 'disabled'}',
                            child: Switch(
                              value: _reduceMotion,
                              activeThumbColor: const Color(0xFFE76F6F),
                              onChanged: (val) {
                                _haptic.buttonPress();
                                setState(() => _reduceMotion = val);
                                _appState.setReduceMotion(val);
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),

                        if (kDebugMode) ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  context.push(RoutePaths.debugDiagnostics),
                              icon: const Icon(Icons.bug_report_outlined),
                              label: const Text('Open Debug Diagnostics'),
                            ),
                          ),
                          SizedBox(height: 2.h),
                        ],

                        SizedBox(
                          width: double.infinity,
                          child: Semantics(
                            label: 'Reset all settings to defaults',
                            button: true,
                            child: OutlinedButton.icon(
                              onPressed: _showResetConfirmation,
                              icon: CustomIconWidget(
                                iconName: 'restore',
                                color: theme.colorScheme.error,
                                size: 20,
                              ),
                              label: Text(
                                'Reset to Defaults',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.error,
                                side: BorderSide(
                                  color: theme.colorScheme.error,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

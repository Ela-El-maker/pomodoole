import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:pomodorofocus/core/monitoring/app_logger.dart';
import 'package:pomodorofocus/data/models/sound_models.dart';
import 'package:pomodorofocus/data/repositories/sound_mix_repository.dart';
import 'package:pomodorofocus/services/audio/ambient_audio_engine.dart';
import 'package:pomodorofocus/services/audio/focus_audio_delegate.dart';
import 'package:pomodorofocus/services/audio/sound_registry.dart';

class SavedSoundMix {
  const SavedSoundMix({
    required this.id,
    required this.name,
    required this.payload,
    required this.isActive,
  });

  final String id;
  final String name;
  final SoundMixPayload payload;
  final bool isActive;
}

class MixerController extends ChangeNotifier implements FocusAudioDelegate {
  MixerController({
    required SoundMixRepository repository,
    required AmbientAudioEngine audioEngine,
    required SoundRegistry registry,
    required AppLogger logger,
  }) : _repository = repository,
       _audioEngine = audioEngine,
       _registry = registry,
       _logger = logger {
    unawaited(initialize());
  }

  final SoundMixRepository _repository;
  final AmbientAudioEngine _audioEngine;
  final SoundRegistry _registry;
  final AppLogger _logger;

  final Map<String, double> _levels = {};
  final Set<String> _enabledSoundIds = <String>{};
  final Map<String, EventDensity> _densities = {};

  List<SavedSoundMix> _savedMixes = const [];
  String? _activeMixId;
  bool _isLoading = true;
  bool _initialized = false;
  bool _previewAttached = false;
  bool _focusSessionActive = false;

  bool get isLoading => _isLoading;
  List<SavedSoundMix> get savedMixes => _savedMixes;
  String? get activeMixId => _activeMixId;
  bool get hasActiveSounds => _enabledSoundIds.isNotEmpty;
  bool get focusSessionActive => _focusSessionActive;

  UnmodifiableMapView<String, double> get levels =>
      UnmodifiableMapView(_levels);
  UnmodifiableSetView<String> get enabledSoundIds =>
      UnmodifiableSetView(_enabledSoundIds);
  UnmodifiableMapView<String, EventDensity> get densities =>
      UnmodifiableMapView(_densities);

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _seedDefaultRuntimeState();
    notifyListeners();

    try {
      await _repository.migrateFromPreferencesIfNeeded();
      await _reloadSavedMixes(loadActiveIntoRuntime: true);
    } catch (error, stackTrace) {
      _logger.warn(
        'mixer_controller',
        'Failed to initialize sound mixer state',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isEventSound(String soundId) => _registry.isEvent(soundId);

  bool isEnabled(String soundId) => _enabledSoundIds.contains(soundId);

  double volumeFor(String soundId) {
    return _levels[soundId] ?? _registry.defaultVolume(soundId);
  }

  EventDensity densityFor(String soundId) {
    return _densities[soundId] ?? _registry.defaultDensity(soundId);
  }

  Future<String?> toggleSound(String soundId, bool enabled) async {
    if (_registry.find(soundId) == null) {
      return 'Sound source is not configured yet.';
    }

    _levels[soundId] = volumeFor(soundId);
    if (isEventSound(soundId)) {
      _densities.putIfAbsent(soundId, () => _registry.defaultDensity(soundId));
    }

    if (enabled) {
      _enabledSoundIds.add(soundId);
    } else {
      _enabledSoundIds.remove(soundId);
    }
    notifyListeners();

    if (!_shouldControlPlayback) return null;
    if (enabled) {
      final startResult = await _audioEngine.startSound(
        soundId,
        volume: volumeFor(soundId),
        density: densityFor(soundId),
        transition: VolumeTransition.onStart,
      );
      if (!startResult.success) {
        _enabledSoundIds.remove(soundId);
        notifyListeners();
        return startResult.message;
      }
      return null;
    }

    await _audioEngine.stopSound(soundId, transition: VolumeTransition.onStop);
    return null;
  }

  Future<void> setVolume(String soundId, double value) async {
    if (_registry.find(soundId) == null) return;
    final normalized = value.clamp(0.0, 1.0).toDouble();
    _levels[soundId] = normalized;

    if (normalized <= 0) {
      _enabledSoundIds.remove(soundId);
    }
    notifyListeners();

    if (!_shouldControlPlayback) return;

    if (_enabledSoundIds.contains(soundId)) {
      final startResult = await _audioEngine.startSound(
        soundId,
        volume: normalized,
        density: densityFor(soundId),
        transition: VolumeTransition.onVolumeChange,
      );
      if (!startResult.success) {
        _enabledSoundIds.remove(soundId);
        notifyListeners();
      }
      return;
    }

    await _audioEngine.stopSound(
      soundId,
      transition: VolumeTransition.onVolumeChange,
    );
  }

  Future<void> setEventDensity(String soundId, EventDensity density) async {
    if (!isEventSound(soundId)) return;
    _densities[soundId] = density;
    notifyListeners();

    if (_shouldControlPlayback && _enabledSoundIds.contains(soundId)) {
      await _audioEngine.setEventDensity(soundId, density);
    }
  }

  Future<void> saveMix(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final payload = _currentPayload();
    await _repository.upsertPayload(
      id: id,
      name: trimmed,
      payload: payload,
      isActive: true,
    );
    await _repository.setActive(id);
    _activeMixId = id;
    await _reloadSavedMixes(loadActiveIntoRuntime: false);
  }

  Future<void> renameMix(String mixId, String nextName) async {
    final trimmed = nextName.trim();
    if (trimmed.isEmpty) return;
    SavedSoundMix? mix;
    for (final item in _savedMixes) {
      if (item.id == mixId) {
        mix = item;
        break;
      }
    }
    if (mix == null) return;

    await _repository.upsertPayload(
      id: mix.id,
      name: trimmed,
      payload: mix.payload,
      isActive: mix.id == _activeMixId,
    );
    await _reloadSavedMixes(loadActiveIntoRuntime: false);
  }

  Future<void> deleteMix(String mixId) async {
    await _repository.delete(mixId);
    if (_activeMixId == mixId) {
      _activeMixId = null;
    }
    await _reloadSavedMixes(loadActiveIntoRuntime: false);
  }

  Future<String?> applySavedMix(String mixId) async {
    SavedSoundMix? mix;
    for (final item in _savedMixes) {
      if (item.id == mixId) {
        mix = item;
        break;
      }
    }
    if (mix == null) return null;

    _loadPayloadIntoRuntime(mix.payload);
    _activeMixId = mixId;
    notifyListeners();

    await _repository.setActive(mixId);
    await _reloadSavedMixes(loadActiveIntoRuntime: false);

    if (!_shouldControlPlayback) return null;

    final result = await _audioEngine.applyMix(
      mix.payload,
      transition: VolumeTransition.onApplyMix,
    );
    if (result.skippedSoundIds.isEmpty) return null;
    return 'Some sounds could not be started due to layer limits.';
  }

  Future<void> attachMixerPreview() async {
    await initialize();
    _previewAttached = true;
    if (_focusSessionActive) return;

    _audioEngine.setFocusSessionActive(false);
    await _audioEngine.applyMix(
      _currentPayload(),
      transition: VolumeTransition.onApplyMix,
    );
  }

  Future<void> detachMixerPreview() async {
    _previewAttached = false;
    await _audioEngine.stopAll(reason: 'mixer_preview_detached');
    if (_focusSessionActive) {
      await _audioEngine.applyMix(
        _currentPayload(),
        transition: VolumeTransition.onApplyMix,
      );
    }
  }

  Future<String?> soloSound(String soundId) async {
    final definition = _registry.find(soundId);
    if (definition == null) {
      return 'Sound source is not configured yet.';
    }

    _enabledSoundIds
      ..clear()
      ..add(soundId);
    _levels[soundId] = (_levels[soundId] ?? definition.defaultVolume)
        .clamp(0.0, 1.0)
        .toDouble();
    if (definition.isEvent) {
      _densities.putIfAbsent(soundId, () => _registry.defaultDensity(soundId));
    }
    notifyListeners();

    if (!_shouldControlPlayback) return null;
    final result = await _audioEngine.applyMix(
      _currentPayload(),
      transition: VolumeTransition.onApplyMix,
    );
    if (result.skippedSoundIds.isEmpty) return null;
    return 'Unable to solo this sound due to current engine limits.';
  }

  @override
  Future<void> onFocusSessionStarted() async {
    await initialize();
    _focusSessionActive = true;
    _audioEngine.setFocusSessionActive(true);

    final payload = _currentPayload();
    final result = await _audioEngine.applyMix(
      payload,
      transition: VolumeTransition.onApplyMix,
    );
    if (result.skippedSoundIds.isNotEmpty) {
      _logger.warn(
        'mixer_controller',
        'Some channels skipped when focus session started',
        data: {'skipped': result.skippedSoundIds},
      );
    }
  }

  @override
  Future<void> onFocusSessionPaused() async {
    if (!_focusSessionActive) return;
    await _audioEngine.pauseAll(reason: 'focus_session_paused');
  }

  @override
  Future<void> onFocusSessionStopped({
    String reason = 'focus_session_stopped',
  }) async {
    _focusSessionActive = false;
    _audioEngine.setFocusSessionActive(false);

    if (_previewAttached) {
      await _audioEngine.applyMix(
        _currentPayload(),
        transition: VolumeTransition.onApplyMix,
      );
      return;
    }
    await _audioEngine.stopAll(reason: reason);
  }

  @override
  void dispose() {
    unawaited(_audioEngine.dispose());
    super.dispose();
  }

  Future<void> _reloadSavedMixes({required bool loadActiveIntoRuntime}) async {
    final rows = await _repository.fetchAll();
    final mixes = rows
        .map(
          (row) => SavedSoundMix(
            id: row.id,
            name: row.name,
            payload: SoundMixPayload.fromStoredJson(row.levelsJson),
            isActive: row.isActive,
          ),
        )
        .toList();

    _savedMixes = mixes;
    SavedSoundMix? activeMix;
    for (final mix in mixes) {
      if (mix.isActive) {
        activeMix = mix;
        break;
      }
    }
    _activeMixId = activeMix?.id;

    if (loadActiveIntoRuntime && _activeMixId != null) {
      if (activeMix != null) {
        _loadPayloadIntoRuntime(activeMix.payload);
      }
    }
    notifyListeners();
  }

  SoundMixPayload _currentPayload() {
    final enabled = _enabledSoundIds
        .where((soundId) => (_levels[soundId] ?? 0) > 0)
        .toSet();
    final densities = {
      for (final entry in _densities.entries)
        if (_registry.isEvent(entry.key)) entry.key: entry.value,
    };
    return SoundMixPayload(
      version: SoundMixPayload.currentVersion,
      levels: Map<String, double>.from(_levels),
      enabledSoundIds: enabled,
      densities: densities,
    );
  }

  void _loadPayloadIntoRuntime(SoundMixPayload payload) {
    _seedDefaultRuntimeState();

    for (final entry in payload.levels.entries) {
      if (_registry.find(entry.key) != null) {
        _levels[entry.key] = entry.value.clamp(0.0, 1.0).toDouble();
      }
    }

    _enabledSoundIds
      ..clear()
      ..addAll(
        payload.enabledSoundIds.where(
          (soundId) =>
              _registry.find(soundId) != null && (_levels[soundId] ?? 0) > 0,
        ),
      );

    for (final entry in payload.densities.entries) {
      if (_registry.isEvent(entry.key)) {
        _densities[entry.key] = entry.value;
      }
    }
  }

  void _seedDefaultRuntimeState() {
    for (final definition in _registry.definitions) {
      _levels.putIfAbsent(definition.id, () => definition.defaultVolume);
      if (definition.isEvent) {
        _densities.putIfAbsent(
          definition.id,
          () => _registry.defaultDensity(definition.id),
        );
      }
    }
  }

  bool get _shouldControlPlayback => _previewAttached || _focusSessionActive;
}

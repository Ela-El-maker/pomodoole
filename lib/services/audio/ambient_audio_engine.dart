import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pomodorofocus/core/monitoring/app_logger.dart';
import 'package:pomodorofocus/data/models/sound_models.dart';
import 'package:pomodorofocus/services/audio/sound_registry.dart';

enum VolumeTransition { onStart, onStop, onVolumeChange, onApplyMix }

enum SoundStartFailureCode {
  disposed,
  unregistered,
  continuousCapReached,
  eventCapReached,
  assetMissing,
  playbackFailed,
}

class SoundStartResult {
  const SoundStartResult._({
    required this.success,
    this.message,
    this.code,
    this.data,
  });

  const SoundStartResult.success() : this._(success: true);

  const SoundStartResult.failure(
    String message, {
    SoundStartFailureCode? code,
    Map<String, Object?>? data,
  }) : this._(success: false, message: message, code: code, data: data);

  final bool success;
  final String? message;
  final SoundStartFailureCode? code;
  final Map<String, Object?>? data;
}

class ApplyMixResult {
  const ApplyMixResult({required this.skippedSoundIds});

  final List<String> skippedSoundIds;
}

class AmbientAudioEngine with WidgetsBindingObserver {
  AmbientAudioEngine({
    required SoundRegistry registry,
    required AppLogger logger,
    Random? random,
  }) : _registry = registry,
       _logger = logger,
       _random = random ?? Random() {
    WidgetsBinding.instance.addObserver(this);
  }

  static const int maxContinuousChannels = 3;
  static const int maxEventChannels = 2;

  final SoundRegistry _registry;
  final AppLogger _logger;
  final Random _random;

  final Map<String, _ContinuousChannel> _continuousChannels = {};
  final Map<String, _EventChannel> _eventChannels = {};

  var _disposed = false;
  var _isPaused = false;
  var _focusSessionActive = false;

  bool get hasActivePlayback =>
      _continuousChannels.isNotEmpty ||
      _eventChannels.values.any((channel) => channel.enabled);

  bool get focusSessionActive => _focusSessionActive;

  void setFocusSessionActive(bool value) {
    _focusSessionActive = value;
  }

  Future<SoundStartResult> startSound(
    String soundId, {
    required double volume,
    EventDensity density = EventDensity.medium,
    VolumeTransition transition = VolumeTransition.onStart,
  }) async {
    if (_disposed) {
      return const SoundStartResult.failure(
        'Audio engine has been disposed.',
        code: SoundStartFailureCode.disposed,
      );
    }

    final definition = _registry.find(soundId);
    if (definition == null) {
      _logger.warn(
        'audio_engine',
        'Attempted to start unregistered sound',
        data: {'soundId': soundId},
      );
      return const SoundStartResult.failure(
        'Sound source is not configured yet.',
        code: SoundStartFailureCode.unregistered,
      );
    }

    if (definition.isEvent) {
      return _startEventSound(
        definition: definition,
        volume: volume,
        density: density,
      );
    }

    return _startContinuousSound(
      definition: definition,
      volume: volume,
      transition: transition,
    );
  }

  Future<void> stopSound(
    String soundId, {
    VolumeTransition transition = VolumeTransition.onStop,
  }) async {
    if (_disposed) return;
    if (_continuousChannels.containsKey(soundId)) {
      await _stopContinuousChannel(soundId, transition: transition);
      return;
    }
    if (_eventChannels.containsKey(soundId)) {
      await _stopEventChannel(soundId);
    }
  }

  Future<void> setVolume(
    String soundId,
    double volume, {
    VolumeTransition transition = VolumeTransition.onVolumeChange,
  }) async {
    if (_disposed) return;
    final normalizedVolume = _normalizeVolume(volume);
    final continuous = _continuousChannels[soundId];
    if (continuous != null) {
      await _rampContinuousVolume(
        continuous,
        normalizedVolume,
        _transitionDuration(transition),
      );
      return;
    }

    final event = _eventChannels[soundId];
    if (event != null) {
      event.volume = normalizedVolume;
      await Future.wait(
        event.activePlayers.map(
          (player) => player.setVolume(normalizedVolume).catchError((_) {}),
        ),
      );
    }
  }

  Future<void> setEventDensity(String soundId, EventDensity density) async {
    final channel = _eventChannels[soundId];
    if (channel == null) return;
    channel.density = density;
    _rescheduleEventChannel(channel);
  }

  Future<ApplyMixResult> applyMix(
    SoundMixPayload payload, {
    VolumeTransition transition = VolumeTransition.onApplyMix,
  }) async {
    if (_disposed) {
      return const ApplyMixResult(skippedSoundIds: []);
    }

    final desiredEnabled = payload.enabledSoundIds
        .where((soundId) => (payload.levels[soundId] ?? 0) > 0)
        .toSet();

    final currentlyActive = {
      ..._continuousChannels.keys,
      ..._eventChannels.keys,
    };

    final toStop = currentlyActive.difference(desiredEnabled);
    for (final soundId in toStop) {
      await stopSound(soundId, transition: transition);
    }

    final skipped = <String>[];
    final toStart = desiredEnabled.toList()
      ..sort((a, b) {
        final aDef = _registry.find(a);
        final bDef = _registry.find(b);
        if (aDef == null || bDef == null) return a.compareTo(b);
        if (aDef.kind == bDef.kind) return a.compareTo(b);
        if (aDef.kind == SoundKind.event) return 1;
        if (bDef.kind == SoundKind.event) return -1;
        return a.compareTo(b);
      });

    for (final soundId in toStart) {
      final startResult = await startSound(
        soundId,
        volume: payload.levels[soundId] ?? _registry.defaultVolume(soundId),
        density:
            payload.densities[soundId] ?? _registry.defaultDensity(soundId),
        transition: transition,
      );
      if (!startResult.success) {
        skipped.add(soundId);
      }
    }

    return ApplyMixResult(skippedSoundIds: skipped);
  }

  Future<void> pauseAll({String reason = 'manual_pause'}) async {
    if (_disposed || _isPaused) return;
    _isPaused = true;

    _logger.info(
      'audio_engine',
      'Pausing all channels',
      data: {'reason': reason},
    );

    await Future.wait(
      _continuousChannels.values.map(
        (channel) => channel.player.pause().catchError((_) {}),
      ),
    );

    for (final channel in _eventChannels.values) {
      channel.timer?.cancel();
      channel.timer = null;
      final players = channel.activePlayers.toList();
      channel.activePlayers.clear();
      channel.activeInstances = 0;
      await Future.wait(players.map((player) => _disposePlayer(player)));
    }
  }

  Future<void> resumeAll({String reason = 'manual_resume'}) async {
    if (_disposed || !_isPaused) return;
    _isPaused = false;

    _logger.info(
      'audio_engine',
      'Resuming all channels',
      data: {'reason': reason},
    );

    await Future.wait(
      _continuousChannels.values.map(
        (channel) => channel.player.resume().catchError((_) {}),
      ),
    );

    for (final channel in _eventChannels.values) {
      if (channel.enabled) {
        _scheduleNextEvent(channel);
      }
    }
  }

  Future<void> stopAll({String reason = 'manual_stop'}) async {
    if (_disposed) return;
    _logger.info(
      'audio_engine',
      'Stopping all channels',
      data: {'reason': reason},
    );

    final continuousIds = _continuousChannels.keys.toList();
    for (final soundId in continuousIds) {
      await _stopContinuousChannel(
        soundId,
        transition: VolumeTransition.onStop,
      );
    }

    final eventIds = _eventChannels.keys.toList();
    for (final soundId in eventIds) {
      await _stopEventChannel(soundId);
    }
    _isPaused = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (!_focusSessionActive) {
        unawaited(pauseAll(reason: 'background_without_focus'));
      }
      return;
    }

    if (state == AppLifecycleState.resumed) {
      if (_focusSessionActive && _isPaused) {
        unawaited(resumeAll(reason: 'foreground_with_focus'));
      }
    }
  }

  Future<SoundStartResult> _startContinuousSound({
    required SoundDefinition definition,
    required double volume,
    required VolumeTransition transition,
  }) async {
    final normalizedVolume = _normalizeVolume(volume);
    final existing = _continuousChannels[definition.id];
    if (existing != null) {
      await _rampContinuousVolume(
        existing,
        normalizedVolume,
        _transitionDuration(transition),
      );
      return const SoundStartResult.success();
    }

    if (_continuousChannels.length >= maxContinuousChannels) {
      _logger.warn(
        'audio_engine',
        'Continuous channel cap reached',
        data: {'cap': maxContinuousChannels, 'soundId': definition.id},
      );
      return const SoundStartResult.failure(
        'You can only play up to 3 continuous sounds at once.',
        code: SoundStartFailureCode.continuousCapReached,
      );
    }

    final player = AudioPlayer();
    String? selectedAssetPath;
    try {
      await _configurePlayer(player, loop: true);
      selectedAssetPath = _pickAsset(definition);
      final validatedAssetPath = await _resolveValidatedAssetPath(
        selectedAssetPath,
      );
      await _playAssetWithFallback(player, validatedAssetPath, volume: 0.0);
      await _trySeekRandomOffset(player);

      final channel = _ContinuousChannel(
        definition: definition,
        player: player,
        currentVolume: 0.0,
      );
      _continuousChannels[definition.id] = channel;
      await _rampContinuousVolume(
        channel,
        normalizedVolume,
        _transitionDuration(transition),
      );
      return const SoundStartResult.success();
    } catch (error, stackTrace) {
      _logger.warn(
        'audio_engine',
        'Failed to start continuous sound',
        error: error,
        stackTrace: stackTrace,
        data: {'soundId': definition.id, 'assetPath': selectedAssetPath},
      );
      await _disposePlayer(player);
      final isAssetMissing = error is FlutterError || error is StateError;
      return SoundStartResult.failure(
        isAssetMissing
            ? 'Asset missing for ${definition.id}. Check assets/sounds and pubspec.'
            : 'Unable to start this sound on this device.',
        code: isAssetMissing
            ? SoundStartFailureCode.assetMissing
            : SoundStartFailureCode.playbackFailed,
        data: {'soundId': definition.id, 'assetPath': selectedAssetPath},
      );
    }
  }

  Future<SoundStartResult> _startEventSound({
    required SoundDefinition definition,
    required double volume,
    required EventDensity density,
  }) async {
    final normalizedVolume = _normalizeVolume(volume);
    final existing = _eventChannels[definition.id];
    if (existing != null) {
      existing.enabled = true;
      existing.volume = normalizedVolume;
      existing.density = density;
      _rescheduleEventChannel(existing);
      return const SoundStartResult.success();
    }

    if (_eventChannels.length >= maxEventChannels) {
      _logger.warn(
        'audio_engine',
        'Event channel cap reached',
        data: {'cap': maxEventChannels, 'soundId': definition.id},
      );
      return const SoundStartResult.failure(
        'You can only play up to 2 event sounds at once.',
        code: SoundStartFailureCode.eventCapReached,
      );
    }

    final channel = _EventChannel(
      definition: definition,
      density: density,
      volume: normalizedVolume,
      enabled: true,
    );
    _eventChannels[definition.id] = channel;
    _rescheduleEventChannel(channel, playSoon: true);
    return const SoundStartResult.success();
  }

  Future<void> _stopContinuousChannel(
    String soundId, {
    required VolumeTransition transition,
  }) async {
    final channel = _continuousChannels.remove(soundId);
    if (channel == null) return;

    await _rampContinuousVolume(channel, 0.0, _transitionDuration(transition));
    await _disposePlayer(channel.player);
  }

  Future<void> _stopEventChannel(String soundId) async {
    final channel = _eventChannels.remove(soundId);
    if (channel == null) return;

    channel.enabled = false;
    channel.timer?.cancel();
    channel.timer = null;

    final players = channel.activePlayers.toList();
    channel.activePlayers.clear();
    channel.activeInstances = 0;
    await Future.wait(players.map((player) => _disposePlayer(player)));
  }

  void _rescheduleEventChannel(_EventChannel channel, {bool playSoon = false}) {
    if (_disposed || _isPaused || !channel.enabled) return;
    channel.timer?.cancel();
    channel.timer = null;

    final window = channel.definition.densityWindows[channel.density];
    if (window == null) return;

    final nextDelay = playSoon
        ? const Duration(milliseconds: 400)
        : _randomDuration(window.minDelay, window.maxDelay);

    channel.timer = Timer(nextDelay, () {
      if (_disposed || _isPaused || !channel.enabled) return;
      unawaited(_triggerEventPlayback(channel));
    });
  }

  Future<void> _triggerEventPlayback(_EventChannel channel) async {
    if (_disposed || _isPaused || !channel.enabled) return;
    final now = DateTime.now();
    if (channel.lastPlayedAt != null &&
        now.difference(channel.lastPlayedAt!) < channel.definition.minGap) {
      _scheduleNextEvent(channel);
      return;
    }

    if (channel.activeInstances >= channel.definition.maxSimultaneous) {
      _scheduleNextEvent(channel);
      return;
    }

    final player = AudioPlayer();
    String? selectedAssetPath;
    try {
      await _configurePlayer(player, loop: false);
      selectedAssetPath = _pickAsset(channel.definition);
      final validatedAssetPath = await _resolveValidatedAssetPath(
        selectedAssetPath,
      );
      channel.activeInstances += 1;
      channel.activePlayers.add(player);
      channel.lastPlayedAt = now;

      late final StreamSubscription<void> completeSub;
      completeSub = player.onPlayerComplete.listen((_) async {
        await completeSub.cancel();
        await _releaseEventPlayer(channel, player);
      });

      await _playAssetWithFallback(
        player,
        validatedAssetPath,
        volume: channel.volume,
      );
      _scheduleNextEvent(channel);
    } catch (error, stackTrace) {
      _logger.warn(
        'audio_engine',
        'Failed to play event sound',
        error: error,
        stackTrace: stackTrace,
        data: {
          'soundId': channel.definition.id,
          'assetPath': selectedAssetPath,
        },
      );
      await _releaseEventPlayer(channel, player);
      _scheduleNextEvent(channel);
    }
  }

  void _scheduleNextEvent(_EventChannel channel) {
    if (_disposed || _isPaused || !channel.enabled) return;
    final window = channel.definition.densityWindows[channel.density];
    if (window == null) return;
    channel.timer?.cancel();
    channel.timer = Timer(
      _randomDuration(window.minDelay, window.maxDelay),
      () => unawaited(_triggerEventPlayback(channel)),
    );
  }

  Future<void> _releaseEventPlayer(
    _EventChannel channel,
    AudioPlayer player,
  ) async {
    channel.activePlayers.remove(player);
    channel.activeInstances = max(0, channel.activeInstances - 1);
    await _disposePlayer(player);
  }

  Future<void> _rampContinuousVolume(
    _ContinuousChannel channel,
    double targetVolume,
    Duration duration,
  ) async {
    final from = channel.currentVolume;
    channel.rampToken += 1;
    final rampToken = channel.rampToken;

    if (duration <= Duration.zero) {
      await channel.player.setVolume(targetVolume);
      channel.currentVolume = targetVolume;
      return;
    }

    final steps = max(1, duration.inMilliseconds ~/ 50);
    for (var i = 1; i <= steps; i++) {
      if (_disposed || channel.rampToken != rampToken) return;
      await Future<void>.delayed(
        Duration(milliseconds: duration.inMilliseconds ~/ steps),
      );
      if (_disposed || channel.rampToken != rampToken) return;
      final t = i / steps;
      final next = from + (targetVolume - from) * t;
      await channel.player.setVolume(next);
      channel.currentVolume = next;
    }
  }

  Duration _transitionDuration(VolumeTransition transition) {
    return switch (transition) {
      VolumeTransition.onStart => const Duration(milliseconds: 400),
      VolumeTransition.onStop => const Duration(milliseconds: 400),
      VolumeTransition.onVolumeChange => const Duration(milliseconds: 200),
      VolumeTransition.onApplyMix => const Duration(milliseconds: 600),
    };
  }

  Future<void> _configurePlayer(
    AudioPlayer player, {
    required bool loop,
  }) async {
    try {
      await player.setPlayerMode(PlayerMode.mediaPlayer);
    } catch (_) {
      // Best effort only; default player mode is acceptable.
    }
    try {
      await player.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
    } catch (_) {
      // Best effort only; fallback still plays.
    }
    try {
      await player.setAudioContext(
        AudioContextConfig(
          route: AudioContextConfigRoute.system,
          focus: AudioContextConfigFocus.duckOthers,
        ).build(),
      );
    } catch (_) {
      // Some device/plugin combos reject custom context; keep playback alive.
    }
  }

  Future<void> _playAssetWithFallback(
    AudioPlayer player,
    String assetPath, {
    required double volume,
  }) async {
    final sourcePath = _assetSourcePath(assetPath);
    try {
      await player.play(
        AssetSource(sourcePath),
        volume: volume,
        mode: PlayerMode.mediaPlayer,
      );
      return;
    } catch (_) {
      final fallback = sourcePath.startsWith('assets/')
          ? sourcePath.replaceFirst('assets/', '')
          : 'assets/$sourcePath';
      if (fallback == sourcePath) {
        rethrow;
      }
      await player.play(
        AssetSource(fallback),
        volume: volume,
        mode: PlayerMode.mediaPlayer,
      );
    }
  }

  Future<String> _resolveValidatedAssetPath(String rawPath) async {
    final candidatePaths = rawPath.startsWith('assets/')
        ? <String>[rawPath, rawPath.replaceFirst('assets/', '')]
        : <String>[rawPath, 'assets/$rawPath'];
    for (final path in candidatePaths) {
      try {
        await rootBundle.load(path);
        return path;
      } catch (_) {
        // try next candidate
      }
    }
    throw FlutterError('Asset not found for path: $rawPath');
  }

  String _assetSourcePath(String path) {
    return path.startsWith('assets/') ? path.replaceFirst('assets/', '') : path;
  }

  String _pickAsset(SoundDefinition definition) {
    if (definition.assetVariants.isEmpty) {
      throw StateError('No assets configured for ${definition.id}');
    }
    if (definition.assetVariants.length == 1) {
      return definition.assetVariants.first;
    }
    final index = _random.nextInt(definition.assetVariants.length);
    return definition.assetVariants[index];
  }

  Future<void> _trySeekRandomOffset(AudioPlayer player) async {
    try {
      final duration = await player.getDuration();
      if (duration == null || duration <= const Duration(seconds: 2)) {
        return;
      }
      final maxMillis = max(1, duration.inMilliseconds - 1000);
      final sampled = _random.nextInt(maxMillis);
      await player.seek(Duration(milliseconds: sampled));
    } catch (_) {
      // Keep startup resilient if duration/seek is unsupported.
    }
  }

  Duration _randomDuration(Duration minDelay, Duration maxDelay) {
    final minMs = minDelay.inMilliseconds;
    final maxMs = max(maxDelay.inMilliseconds, minMs + 1);
    final sampledMs = minMs + _random.nextInt(maxMs - minMs);
    return Duration(milliseconds: sampledMs);
  }

  double _normalizeVolume(double value) => value.clamp(0.0, 1.0).toDouble();

  Future<void> _disposePlayer(AudioPlayer player) async {
    try {
      await player.stop();
    } catch (_) {}
    try {
      await player.dispose();
    } catch (_) {}
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    await stopAll(reason: 'engine_dispose');
  }
}

class _ContinuousChannel {
  _ContinuousChannel({
    required this.definition,
    required this.player,
    required this.currentVolume,
  });

  final SoundDefinition definition;
  final AudioPlayer player;
  double currentVolume;
  int rampToken = 0;
}

class _EventChannel {
  _EventChannel({
    required this.definition,
    required this.density,
    required this.volume,
    required this.enabled,
  });

  final SoundDefinition definition;
  EventDensity density;
  double volume;
  bool enabled;

  Timer? timer;
  DateTime? lastPlayedAt;
  int activeInstances = 0;
  final Set<AudioPlayer> activePlayers = {};
}

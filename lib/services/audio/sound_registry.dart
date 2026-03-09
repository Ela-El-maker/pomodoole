import 'package:pomodorofocus/data/models/sound_models.dart';

class SoundRegistry {
  const SoundRegistry();

  SoundDefinition? find(String soundId) => _definitions[soundId];

  Iterable<SoundDefinition> get definitions => _definitions.values;

  Iterable<String> get ids => _definitions.keys;

  bool isEvent(String soundId) => _definitions[soundId]?.isEvent ?? false;

  EventDensity defaultDensity(String soundId) {
    final definition = _definitions[soundId];
    if (definition == null || !definition.isEvent) {
      return EventDensity.medium;
    }
    return definition.densityWindows.containsKey(EventDensity.medium)
        ? EventDensity.medium
        : definition.densityWindows.keys.first;
  }

  double defaultVolume(String soundId) {
    return _definitions[soundId]?.defaultVolume ?? 0.5;
  }

  static final Map<String, SoundDefinition> _definitions = {
    'rain': const SoundDefinition(
      id: 'rain',
      kind: SoundKind.longTrack,
      maxLayersGroup: 'continuous',
      assetVariants: ['sounds/rain-1.mp3', 'sounds/rain-2.mp3'],
      estimatedDuration: Duration(minutes: 20),
      defaultVolume: 0.6,
    ),
    'forest': const SoundDefinition(
      id: 'forest',
      kind: SoundKind.longTrack,
      maxLayersGroup: 'continuous',
      assetVariants: [
        'sounds/forest-1.mp3',
        'sounds/forest-2.mp3',
        'sounds/forest-3.mp3',
        'sounds/forest-4.mp3',
      ],
      estimatedDuration: Duration(minutes: 20),
      defaultVolume: 0.5,
    ),
    'cafe': const SoundDefinition(
      id: 'cafe',
      kind: SoundKind.loopTrack,
      maxLayersGroup: 'continuous',
      assetVariants: ['sounds/cafe-1.mp3', 'sounds/cafe-2.mp3'],
      estimatedDuration: Duration(minutes: 10),
      defaultVolume: 0.4,
    ),
    'white_noise': const SoundDefinition(
      id: 'white_noise',
      kind: SoundKind.longTrack,
      maxLayersGroup: 'continuous',
      assetVariants: [
        'sounds/white-noise-1.mp3',
        'sounds/white-noise-2.mp3',
        'sounds/white-noise-3.mp3',
        'sounds/white-noise-4.mp3',
        'sounds/brown-noise-1.mp3',
      ],
      estimatedDuration: Duration(minutes: 20),
      defaultVolume: 0.45,
    ),
    'birdsong': const SoundDefinition(
      id: 'birdsong',
      kind: SoundKind.event,
      maxLayersGroup: 'event',
      assetVariants: [
        'sounds/bird-song-1.mp3',
        'sounds/bird-song-2.mp3',
        'sounds/bird-song-3.mp3',
        'sounds/bird-song-4.mp3',
        'sounds/bird-song-5.mp3',
      ],
      defaultVolume: 0.5,
      minGap: Duration(seconds: 5),
      maxSimultaneous: 1,
      densityWindows: {
        EventDensity.low: EventWindow(
          minDelay: Duration(seconds: 90),
          maxDelay: Duration(seconds: 180),
        ),
        EventDensity.medium: EventWindow(
          minDelay: Duration(seconds: 40),
          maxDelay: Duration(seconds: 120),
        ),
        EventDensity.high: EventWindow(
          minDelay: Duration(seconds: 15),
          maxDelay: Duration(seconds: 60),
        ),
      },
    ),
    'fireplace': const SoundDefinition(
      id: 'fireplace',
      kind: SoundKind.loopTrack,
      maxLayersGroup: 'continuous',
      assetVariants: [
        'sounds/fire-place-1.mp3',
        'sounds/fire-place-2.mp3',
        'sounds/fire-place-3.mp3',
        'sounds/fire-place-4.mp3',
        'sounds/fire-place-5.mp3',
      ],
      estimatedDuration: Duration(minutes: 3),
      defaultVolume: 0.35,
    ),
  };
}

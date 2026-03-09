import 'dart:convert';

enum SoundKind { longTrack, loopTrack, event }

enum EventDensity { low, medium, high }

EventDensity eventDensityFromString(String? value) {
  switch (value) {
    case 'low':
      return EventDensity.low;
    case 'high':
      return EventDensity.high;
    case 'medium':
    default:
      return EventDensity.medium;
  }
}

String eventDensityToString(EventDensity value) {
  switch (value) {
    case EventDensity.low:
      return 'low';
    case EventDensity.medium:
      return 'medium';
    case EventDensity.high:
      return 'high';
  }
}

class EventWindow {
  const EventWindow({required this.minDelay, required this.maxDelay});

  final Duration minDelay;
  final Duration maxDelay;
}

class SoundDefinition {
  const SoundDefinition({
    required this.id,
    required this.kind,
    required this.assetVariants,
    required this.defaultVolume,
    required this.maxLayersGroup,
    this.estimatedDuration,
    this.densityWindows = const {},
    this.minGap = Duration.zero,
    this.maxSimultaneous = 1,
  });

  final String id;
  final SoundKind kind;
  final List<String> assetVariants;
  final double defaultVolume;
  final String maxLayersGroup;
  final Duration? estimatedDuration;
  final Map<EventDensity, EventWindow> densityWindows;
  final Duration minGap;
  final int maxSimultaneous;

  bool get isEvent => kind == SoundKind.event;
}

class SoundMixPayload {
  const SoundMixPayload({
    required this.version,
    required this.levels,
    required this.enabledSoundIds,
    required this.densities,
  });

  static const int currentVersion = 2;

  final int version;
  final Map<String, double> levels;
  final Set<String> enabledSoundIds;
  final Map<String, EventDensity> densities;

  factory SoundMixPayload.empty() {
    return const SoundMixPayload(
      version: currentVersion,
      levels: {},
      enabledSoundIds: {},
      densities: {},
    );
  }

  factory SoundMixPayload.fromStoredJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return SoundMixPayload.empty();
      }

      final rawMap = Map<String, dynamic>.from(decoded);
      final version = (rawMap['v'] as num?)?.toInt();

      if (version == currentVersion) {
        final levels = _parseLevels(rawMap['levels']);
        final enabled = _parseEnabled(
          rawMap['enabled'],
          fallbackLevels: levels,
        );
        final densities = _parseDensities(rawMap['densities']);
        return SoundMixPayload(
          version: currentVersion,
          levels: levels,
          enabledSoundIds: enabled,
          densities: densities,
        );
      }

      final legacyLevels = rawMap.containsKey('soundLevels')
          ? _parseLevels(rawMap['soundLevels'])
          : _parseLevels(rawMap);
      final enabled = legacyLevels.entries
          .where((entry) => entry.value > 0)
          .map((entry) => entry.key)
          .toSet();
      return SoundMixPayload(
        version: 1,
        levels: legacyLevels,
        enabledSoundIds: enabled,
        densities: {for (final key in enabled) key: EventDensity.medium},
      );
    } catch (_) {
      return SoundMixPayload.empty();
    }
  }

  String toStoredJson() {
    final sortedLevels = Map<String, double>.fromEntries(
      levels.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    final sortedEnabled = enabledSoundIds.toList()..sort();
    final sortedDensities = Map<String, String>.fromEntries(
      densities.entries
          .map(
            (entry) => MapEntry(entry.key, eventDensityToString(entry.value)),
          )
          .toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );
    return jsonEncode({
      'v': currentVersion,
      'levels': sortedLevels,
      'enabled': sortedEnabled,
      'densities': sortedDensities,
    });
  }

  SoundMixPayload copyWith({
    int? version,
    Map<String, double>? levels,
    Set<String>? enabledSoundIds,
    Map<String, EventDensity>? densities,
  }) {
    return SoundMixPayload(
      version: version ?? this.version,
      levels: levels ?? this.levels,
      enabledSoundIds: enabledSoundIds ?? this.enabledSoundIds,
      densities: densities ?? this.densities,
    );
  }

  static Map<String, double> _parseLevels(dynamic raw) {
    if (raw is! Map) {
      return {};
    }
    return Map<String, double>.fromEntries(
      raw.entries
          .where((entry) => entry.key is String)
          .map((entry) {
            final value = entry.value;
            final parsed = switch (value) {
              num() => value.toDouble(),
              String() => double.tryParse(value) ?? 0.0,
              _ => 0.0,
            };
            final normalized = parsed.clamp(0.0, 1.0).toDouble();
            return MapEntry(entry.key as String, normalized);
          })
          .where((entry) => entry.value >= 0.0),
    );
  }

  static Set<String> _parseEnabled(
    dynamic raw, {
    required Map<String, double> fallbackLevels,
  }) {
    if (raw is List) {
      return raw.whereType<String>().toSet();
    }

    if (raw is Map) {
      return raw.entries
          .where(
            (entry) =>
                entry.key is String &&
                (entry.value == true || entry.value == 1 || entry.value == '1'),
          )
          .map((entry) => entry.key as String)
          .toSet();
    }

    return fallbackLevels.entries
        .where((entry) => entry.value > 0)
        .map((entry) => entry.key)
        .toSet();
  }

  static Map<String, EventDensity> _parseDensities(dynamic raw) {
    if (raw is! Map) {
      return {};
    }
    return Map<String, EventDensity>.fromEntries(
      raw.entries
          .where((entry) => entry.key is String)
          .map(
            (entry) => MapEntry(
              entry.key as String,
              eventDensityFromString(entry.value?.toString()),
            ),
          ),
    );
  }
}

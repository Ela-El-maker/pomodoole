import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pomodorofocus/data/models/sound_models.dart';

void main() {
  test('legacy map payload parses with medium event density defaults', () {
    final payload = SoundMixPayload.fromStoredJson(
      jsonEncode({'rain': 0.8, 'birdsong': 0.4}),
    );

    expect(payload.version, 1);
    expect(payload.levels['rain'], 0.8);
    expect(payload.enabledSoundIds, containsAll(['rain', 'birdsong']));
    expect(payload.densities['birdsong'], EventDensity.medium);
  });

  test(
    'versioned payload roundtrips levels, enabled channels and densities',
    () {
      final input = SoundMixPayload(
        version: SoundMixPayload.currentVersion,
        levels: const {'rain': 0.7, 'birdsong': 0.2},
        enabledSoundIds: const {'rain', 'birdsong'},
        densities: const {'birdsong': EventDensity.high},
      );

      final encoded = input.toStoredJson();
      final decoded = SoundMixPayload.fromStoredJson(encoded);

      expect(decoded.version, SoundMixPayload.currentVersion);
      expect(decoded.levels['rain'], 0.7);
      expect(decoded.enabledSoundIds, containsAll(['rain', 'birdsong']));
      expect(decoded.densities['birdsong'], EventDensity.high);
    },
  );
}

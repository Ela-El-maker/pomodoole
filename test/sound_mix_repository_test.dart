import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodorofocus/data/db/app_database.dart';
import 'package:pomodorofocus/data/repositories/sound_mix_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'migrates legacy sound mixes from SharedPreferences to database',
    () async {
      SharedPreferences.setMockInitialValues({
        'saved_sound_mixes': jsonEncode([
          {
            'id': 'mix_1',
            'name': 'Rainy Library',
            'soundLevels': {'rain': 0.8, 'white_noise': 0.4},
          },
        ]),
        'active_mix_id': 'mix_1',
      });

      final prefs = await SharedPreferences.getInstance();
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(() => db.close());

      final repository = SoundMixRepository(database: db, preferences: prefs);

      await repository.migrateFromPreferencesIfNeeded();

      final mixes = await repository.fetchAll();
      expect(mixes.length, 1);
      expect(mixes.first.name, 'Rainy Library');
      expect(mixes.first.isActive, isTrue);
    },
  );
}

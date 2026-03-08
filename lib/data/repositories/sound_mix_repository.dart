import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pomodorofocus/data/db/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundMixRepository {
  SoundMixRepository({
    required AppDatabase database,
    required SharedPreferences preferences,
  }) : _database = database,
       _preferences = preferences;

  final AppDatabase _database;
  final SharedPreferences _preferences;

  static const _legacyMixesKey = 'saved_sound_mixes';
  static const _legacyActiveMixKey = 'active_mix_id';
  static const _migrationKey = 'sound_mixes_db_migrated_v1';

  Future<void> migrateFromPreferencesIfNeeded() async {
    if (_preferences.getBool(_migrationKey) == true) {
      return;
    }

    final legacyRaw = _preferences.getString(_legacyMixesKey);
    final activeMixId = _preferences.getString(_legacyActiveMixKey);

    if (legacyRaw != null && legacyRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(legacyRaw) as List<dynamic>;
        for (final dynamic mix in decoded) {
          final map = mix as Map<String, dynamic>;
          final id = map['id'] as String?;
          final name = map['name'] as String?;
          final levels = map['soundLevels'];
          if (id == null || name == null || levels == null) continue;

          await _database.upsertSoundMix(
            SoundMixesTableCompanion.insert(
              id: id,
              name: name,
              levelsJson: jsonEncode(levels),
              isActive: Value(id == activeMixId),
            ),
          );
        }
      } catch (_) {
        // Ignore malformed legacy payload and still mark migration complete.
      }
    }

    await _preferences.setBool(_migrationKey, true);
  }

  Future<List<SoundMixesTableData>> fetchAll() => _database.getAllSoundMixes();

  Future<void> upsert({
    required String id,
    required String name,
    required Map<String, double> levels,
    bool isActive = false,
  }) {
    return _database.upsertSoundMix(
      SoundMixesTableCompanion(
        id: Value(id),
        name: Value(name),
        levelsJson: Value(jsonEncode(levels)),
        isActive: Value(isActive),
      ),
    );
  }

  Future<void> setActive(String mixId) => _database.setActiveMix(mixId);

  Future<int> delete(String mixId) => _database.deleteSoundMixById(mixId);
}

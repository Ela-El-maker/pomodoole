import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodorofocus/data/db/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'v1 database upgrades non-destructively and seeds reference data',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'pomodoro_migration_',
      );
      final file = File('${tempDir.path}/migration_test.sqlite');
      final raw = sqlite.sqlite3.open(file.path);
      addTearDown(() async {
        await tempDir.delete(recursive: true);
      });

      raw.execute('''
      CREATE TABLE tasks_table (
        id TEXT NOT NULL PRIMARY KEY,
        title TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        estimated_pomodoros INTEGER NOT NULL DEFAULT 1,
        completed_pomodoros INTEGER NOT NULL DEFAULT 0,
        is_completed INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');
      raw.execute('''
      CREATE TABLE session_history_table (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        session_type TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        completed INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL
      );
    ''');
      raw.execute('''
      CREATE TABLE reflections_table (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        mood TEXT,
        went_well TEXT,
        distracted_by TEXT,
        next_focus TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL
      );
    ''');
      raw.execute('''
      CREATE TABLE sound_mixes_table (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        levels_json TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      );
    ''');

      final now = DateTime(2026, 3, 8).millisecondsSinceEpoch;
      raw.execute(
        '''
      INSERT INTO tasks_table (
        id, title, notes, estimated_pomodoros, completed_pomodoros,
        is_completed, is_active, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
      ''',
        [
          'task-legacy',
          'Legacy task',
          'before migration',
          3,
          1,
          0,
          1,
          now,
          now,
        ],
      );
      raw.execute(
        '''
      INSERT INTO sound_mixes_table (id, name, levels_json, is_active, created_at)
      VALUES (?, ?, ?, ?, ?);
      ''',
        ['mix-legacy', 'Legacy Mix', '{"rain":0.7}', 1, now],
      );
      raw.execute(
        '''
      INSERT INTO session_history_table (
        session_type, duration_seconds, completed, created_at
      ) VALUES (?, ?, ?, ?);
      ''',
        ['Focus', 1500, 1, now],
      );
      raw.execute(
        '''
      INSERT INTO reflections_table (
        mood, went_well, distracted_by, next_focus, notes, created_at
      ) VALUES (?, ?, ?, ?, ?, ?);
      ''',
        ['Focused', 'Deep work', 'None', 'Continue', 'Legacy reflection', now],
      );
      raw.execute('PRAGMA user_version = 1;');
      raw.close();

      final db = AppDatabase(NativeDatabase(file));
      addTearDown(() => db.close());

      final tasks = await db.getAllTasks();
      expect(tasks, hasLength(1));
      expect(tasks.first.id, 'task-legacy');
      expect(tasks.first.title, 'Legacy task');
      expect(tasks.first.dueAt, isNull);
      expect(tasks.first.reminderAt, isNull);
      expect(tasks.first.reminderEnabled, isFalse);

      final mixes = await db.getAllSoundMixes();
      expect(mixes, hasLength(1));
      expect(mixes.first.id, 'mix-legacy');

      final completedFocusSessions = await db.getCompletedFocusSessions();
      expect(completedFocusSessions, hasLength(1));
      expect(completedFocusSessions.first.durationSeconds, 1500);
      expect(completedFocusSessions.first.taskId, isNull);

      final reflections = await db.select(db.reflectionsTable).get();
      expect(reflections, hasLength(1));
      expect(reflections.first.mood, 'Focused');
      expect(reflections.first.notes, 'Legacy reflection');

      final moodsBefore = await db.getCatalogItemsByType('mood');
      final achievementsBefore = await db.getAchievementDefinitions();
      expect(moodsBefore, isNotEmpty);
      expect(achievementsBefore, isNotEmpty);

      await db.seedReferenceDataIfMissing();
      final moodsAfter = await db.getCatalogItemsByType('mood');
      final achievementsAfter = await db.getAchievementDefinitions();

      expect(moodsAfter.length, moodsBefore.length);
      expect(achievementsAfter.length, achievementsBefore.length);
    },
  );
}

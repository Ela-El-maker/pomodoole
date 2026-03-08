import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodorofocus/data/db/app_database.dart';
import 'package:pomodorofocus/data/repositories/reflections_repository.dart';
import 'package:pomodorofocus/data/repositories/session_history_repository.dart';
import 'package:pomodorofocus/data/repositories/sound_mix_repository.dart';
import 'package:pomodorofocus/data/repositories/tasks_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('tasks repository supports upsert, watch and delete', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() => db.close());
    final repo = TasksRepository(db);

    await repo.upsert(
      id: 'task-1',
      title: 'Deep Work',
      notes: 'Morning block',
      estimatedPomodoros: 4,
      completedPomodoros: 1,
      isActive: true,
    );

    final watched = await repo.watchAll().first;
    expect(watched, hasLength(1));
    expect(watched.first.title, 'Deep Work');
    expect(watched.first.notes, 'Morning block');
    expect(watched.first.isActive, isTrue);

    final fetched = await repo.fetchAll();
    expect(fetched, hasLength(1));

    final deletedCount = await repo.delete('task-1');
    expect(deletedCount, 1);
    expect(await repo.fetchAll(), isEmpty);
  });

  test('session history and reflections repositories persist records', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() => db.close());

    final history = SessionHistoryRepository(db);
    final reflections = ReflectionsRepository(db);

    await history.addEntry(
      sessionType: 'Focus',
      durationSeconds: 1500,
      completed: true,
    );

    await reflections.addReflection(
      mood: 'Calm',
      wentWell: 'Stayed on task',
      distractedBy: 'Phone',
      nextFocus: 'Start writing immediately',
      notes: 'Good momentum',
    );

    final historyRows = await db.select(db.sessionHistoryTable).get();
    expect(historyRows, hasLength(1));
    expect(historyRows.first.sessionType, 'Focus');
    expect(historyRows.first.durationSeconds, 1500);
    expect(historyRows.first.completed, isTrue);

    final reflectionRows = await db.select(db.reflectionsTable).get();
    expect(reflectionRows, hasLength(1));
    expect(reflectionRows.first.mood, 'Calm');
    expect(reflectionRows.first.nextFocus, 'Start writing immediately');
  });

  test('sound mix repository upsert, activate, fetch and delete', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() => db.close());

    final repo = SoundMixRepository(database: db, preferences: prefs);

    await repo.upsert(
      id: 'mix-1',
      name: 'Rain + Wind',
      levels: {'rain': 0.7, 'wind': 0.4},
      isActive: false,
    );
    await repo.upsert(
      id: 'mix-2',
      name: 'Forest',
      levels: {'birds': 0.8},
      isActive: false,
    );

    await repo.setActive('mix-2');

    final mixes = await repo.fetchAll();
    expect(mixes, hasLength(2));
    expect(mixes.where((m) => m.isActive), hasLength(1));
    expect(mixes.firstWhere((m) => m.isActive).id, 'mix-2');

    final removed = await repo.delete('mix-1');
    expect(removed, 1);
    expect(await repo.fetchAll(), hasLength(1));
  });
}

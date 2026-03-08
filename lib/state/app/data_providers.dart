import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodorofocus/data/db/app_database.dart';
import 'package:pomodorofocus/data/repositories/reflections_repository.dart';
import 'package:pomodorofocus/data/repositories/session_history_repository.dart';
import 'package:pomodorofocus/data/repositories/sound_mix_repository.dart';
import 'package:pomodorofocus/data/repositories/tasks_repository.dart';
import 'package:pomodorofocus/state/app/app_providers.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository(ref.watch(appDatabaseProvider));
});

final sessionHistoryRepositoryProvider = Provider<SessionHistoryRepository>((
  ref,
) {
  return SessionHistoryRepository(ref.watch(appDatabaseProvider));
});

final reflectionsRepositoryProvider = Provider<ReflectionsRepository>((ref) {
  return ReflectionsRepository(ref.watch(appDatabaseProvider));
});

final soundMixRepositoryProvider = Provider<SoundMixRepository>((ref) {
  return SoundMixRepository(
    database: ref.watch(appDatabaseProvider),
    preferences: ref.watch(sharedPreferencesProvider),
  );
});

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodorofocus/data/db/app_database.dart';
import 'package:pomodorofocus/data/models/catalog_item.dart';
import 'package:pomodorofocus/data/models/statistics_models.dart';
import 'package:pomodorofocus/data/repositories/catalog_repository.dart';
import 'package:pomodorofocus/data/repositories/reflections_repository.dart';
import 'package:pomodorofocus/data/repositories/session_history_repository.dart';
import 'package:pomodorofocus/data/repositories/sound_mix_repository.dart';
import 'package:pomodorofocus/data/repositories/statistics_repository.dart';
import 'package:pomodorofocus/data/repositories/tasks_repository.dart';
import 'package:pomodorofocus/services/audio/ambient_audio_engine.dart';
import 'package:pomodorofocus/services/audio/sound_registry.dart';
import 'package:pomodorofocus/state/app/app_providers.dart';
import 'package:pomodorofocus/state/sound/mixer_controller.dart';

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

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(appDatabaseProvider));
});

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return StatisticsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

final soundRegistryProvider = Provider<SoundRegistry>((ref) {
  return const SoundRegistry();
});

final ambientAudioEngineProvider = Provider<AmbientAudioEngine>((ref) {
  final engine = AmbientAudioEngine(
    registry: ref.watch(soundRegistryProvider),
    logger: ref.watch(appLoggerProvider),
  );
  ref.onDispose(() {
    unawaited(engine.dispose());
  });
  return engine;
});

final mixerControllerProvider = ChangeNotifierProvider<MixerController>((ref) {
  return MixerController(
    repository: ref.watch(soundMixRepositoryProvider),
    audioEngine: ref.watch(ambientAudioEngineProvider),
    registry: ref.watch(soundRegistryProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final catalogItemsProvider =
    StreamProvider.family<List<CatalogItem>, CatalogType>((ref, type) {
      return ref.watch(catalogRepositoryProvider).watchByType(type);
    });

final statisticsSummaryProvider = FutureProvider<StatsSummary>((ref) async {
  return ref.watch(statisticsRepositoryProvider).getSummary();
});

final statisticsBucketsProvider =
    FutureProvider.family<List<TimeBucketStat>, StatsRange>((ref, range) async {
      return ref
          .watch(statisticsRepositoryProvider)
          .getBuckets(range, DateTime.now());
    });

final achievementsProvider = FutureProvider<List<AchievementView>>((ref) async {
  return ref
      .watch(statisticsRepositoryProvider)
      .getAchievements(DateTime.now());
});

final reflectionSummaryProvider = FutureProvider<ReflectionSummary>((
  ref,
) async {
  return ref
      .watch(statisticsRepositoryProvider)
      .getWeeklyReflectionSummary(DateTime.now());
});

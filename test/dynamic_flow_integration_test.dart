import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodorofocus/data/db/app_database.dart';
import 'package:pomodorofocus/data/models/statistics_models.dart';
import 'package:pomodorofocus/data/repositories/reflections_repository.dart';
import 'package:pomodorofocus/data/repositories/session_history_repository.dart';
import 'package:pomodorofocus/data/repositories/statistics_repository.dart';
import 'package:pomodorofocus/data/repositories/tasks_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'create task, complete sessions, save reflection updates stats and achievements without restart',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(() => db.close());

      final tasksRepository = TasksRepository(db);
      final sessionHistoryRepository = SessionHistoryRepository(db);
      final reflectionsRepository = ReflectionsRepository(db);
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final statisticsRepository = StatisticsRepository(db, prefs);

      final achievementsBefore = await statisticsRepository.getAchievements(
        DateTime.now(),
      );
      final firstSessionBefore =
          achievementsBefore
              .where((achievement) => achievement.key == 'first_session')
              .single;
      expect(firstSessionBefore.unlocked, isFalse);

      await tasksRepository.upsert(id: 'task-1', title: 'Ship dynamic data');
      final tasks = await tasksRepository.fetchAll();
      expect(tasks, hasLength(1));
      expect(tasks.first.title, 'Ship dynamic data');

      await sessionHistoryRepository.addEntry(
        sessionType: 'Focus',
        durationSeconds: 1500,
        completed: true,
      );
      await sessionHistoryRepository.addEntry(
        sessionType: 'Focus',
        durationSeconds: 1500,
        completed: true,
      );

      await reflectionsRepository.addReflection(
        mood: 'Focused',
        wentWell: 'Stayed on task',
        nextFocus: 'Keep momentum',
        notes: 'Integration flow',
      );

      final reflections = await db.select(db.reflectionsTable).get();
      expect(reflections, hasLength(1));
      expect(reflections.first.mood, 'Focused');

      final summary = await statisticsRepository.getSummary();
      expect(summary.todaySessions, 2);
      expect(summary.totalFocusMinutes, 50);

      final buckets = await statisticsRepository.getBuckets(
        StatsRange.daily,
        DateTime.now(),
      );
      expect(buckets.fold<int>(0, (sum, item) => sum + item.sessions), 2);

      final achievementsAfter = await statisticsRepository.getAchievements(
        DateTime.now(),
      );
      final firstSessionAfter =
          achievementsAfter
              .where((achievement) => achievement.key == 'first_session')
              .single;
      expect(firstSessionAfter.unlocked, isTrue);
      expect(firstSessionAfter.currentValue, greaterThanOrEqualTo(2));
    },
  );
}

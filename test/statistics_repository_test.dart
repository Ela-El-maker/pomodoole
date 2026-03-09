import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodorofocus/data/db/app_database.dart';
import 'package:pomodorofocus/data/models/statistics_models.dart';
import 'package:pomodorofocus/data/repositories/statistics_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _insertFocusSession(
  AppDatabase db, {
  required DateTime createdAt,
  int durationSeconds = 1500,
}) async {
  await db
      .into(db.sessionHistoryTable)
      .insert(
        SessionHistoryTableCompanion.insert(
          sessionType: 'Focus',
          durationSeconds: durationSeconds,
          completed: const Value(true),
          createdAt: Value(createdAt),
        ),
      );
}

Future<void> _insertReflection(
  AppDatabase db, {
  required DateTime createdAt,
  String? mood,
}) async {
  await db
      .into(db.reflectionsTable)
      .insert(
        ReflectionsTableCompanion.insert(
          mood: Value(mood),
          createdAt: Value(createdAt),
        ),
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('statistics buckets aggregate by calendar periods', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() => db.close());
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final repo = StatisticsRepository(db, prefs);

    await _insertFocusSession(db, createdAt: DateTime(2026, 3, 8, 9));
    await _insertFocusSession(db, createdAt: DateTime(2026, 3, 7, 10));
    await _insertFocusSession(db, createdAt: DateTime(2026, 3, 1, 8));
    await _insertFocusSession(db, createdAt: DateTime(2026, 2, 27, 8));

    final now = DateTime(2026, 3, 8, 12);
    final daily = await repo.getBuckets(StatsRange.daily, now);
    final weekly = await repo.getBuckets(StatsRange.weekly, now);
    final monthly = await repo.getBuckets(StatsRange.monthly, now);

    expect(daily, hasLength(7));
    expect(weekly, hasLength(6));
    expect(monthly, hasLength(6));
    expect(daily.fold<int>(0, (sum, row) => sum + row.sessions), 2);
    expect(weekly.fold<int>(0, (sum, row) => sum + row.sessions), 4);
    expect(monthly.fold<int>(0, (sum, row) => sum + row.sessions), 4);
  });

  test('achievements unlock according to history thresholds', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() => db.close());
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final repo = StatisticsRepository(db, prefs);

    for (var i = 0; i < 7; i++) {
      await _insertFocusSession(db, createdAt: DateTime(2026, 3, 2 + i, 9));
    }

    final achievements = await repo.getAchievements(DateTime(2026, 3, 8));
    final byKey = {
      for (final achievement in achievements) achievement.key: achievement,
    };

    expect(byKey['first_session']?.unlocked, isTrue);
    expect(byKey['streak_7']?.unlocked, isTrue);
    expect(byKey['sessions_100']?.unlocked, isFalse);
    expect(byKey['streak_30']?.unlocked, isFalse);
  });

  test(
    'summary reflects today sessions, streak and total focus minutes',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(() => db.close());
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final repo = StatisticsRepository(db, prefs);

      await _insertFocusSession(
        db,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      await _insertFocusSession(
        db,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      final summary = await repo.getSummary();
      expect(summary.todaySessions, 1);
      expect(summary.totalFocusMinutes, 50);
      expect(summary.currentStreak, greaterThanOrEqualTo(1));
    },
  );

  test('weekly goal edit locks within current week until achieved', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() => db.close());
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(
      Duration(days: today.weekday - DateTime.monday),
    );

    SharedPreferences.setMockInitialValues(<String, Object>{
      'weekly_goal_sessions': 5,
      'weekly_goal_week_start_epoch_ms': weekStart.millisecondsSinceEpoch,
    });
    final prefs = await SharedPreferences.getInstance();
    final repo = StatisticsRepository(db, prefs);

    final summary = await repo.getSummary();
    expect(summary.canEditWeeklyGoal, isFalse);
    expect(summary.weeklyGoalLockMessage, isNotNull);
  });

  test('weekly goal edit unlocks once goal is achieved', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() => db.close());
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(
      Duration(days: today.weekday - DateTime.monday),
    );

    SharedPreferences.setMockInitialValues(<String, Object>{
      'weekly_goal_sessions': 1,
      'weekly_goal_week_start_epoch_ms': weekStart.millisecondsSinceEpoch,
    });
    final prefs = await SharedPreferences.getInstance();
    final repo = StatisticsRepository(db, prefs);

    await _insertFocusSession(db, createdAt: now);
    final summary = await repo.getSummary();
    expect(summary.canEditWeeklyGoal, isTrue);
  });

  test('weekly goal edit unlocks after the locked week ends', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() => db.close());
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentWeekStart = today.subtract(
      Duration(days: today.weekday - DateTime.monday),
    );
    final previousWeekStart = currentWeekStart.subtract(
      const Duration(days: 7),
    );

    SharedPreferences.setMockInitialValues(<String, Object>{
      'weekly_goal_sessions': 5,
      'weekly_goal_week_start_epoch_ms':
          previousWeekStart.millisecondsSinceEpoch,
    });
    final prefs = await SharedPreferences.getInstance();
    final repo = StatisticsRepository(db, prefs);

    final summary = await repo.getSummary();
    expect(summary.canEditWeeklyGoal, isTrue);
  });

  test(
    'weekly reflection summary groups moods and handles unspecified',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(() => db.close());
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final repo = StatisticsRepository(db, prefs);
      final now = DateTime.now();

      await _insertReflection(
        db,
        createdAt: now.subtract(const Duration(hours: 1)),
        mood: 'Focused',
      );
      await _insertReflection(
        db,
        createdAt: now.subtract(const Duration(hours: 2)),
        mood: 'Focused',
      );
      await _insertReflection(
        db,
        createdAt: now.subtract(const Duration(hours: 3)),
        mood: '',
      );
      await _insertReflection(
        db,
        createdAt: now.subtract(const Duration(days: 10)),
        mood: 'Calm',
      );

      final summary = await repo.getWeeklyReflectionSummary(now);
      expect(summary.weeklyReflectionCount, 3);
      expect(summary.moodBreakdown.first.mood, 'Focused');
      expect(summary.moodBreakdown.first.count, 2);
      expect(
        summary.moodBreakdown.any(
          (item) => item.mood == 'Unspecified' && item.count == 1,
        ),
        isTrue,
      );
    },
  );

  test(
    'weekly goal setup state is editable before first initialization',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(() => db.close());
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final repo = StatisticsRepository(db, prefs);

      final setup = await repo.getWeeklyGoalSetupState();
      expect(setup.initialized, isFalse);
      expect(setup.canEdit, isTrue);
    },
  );

  test('setWeeklyGoalSessions marks weekly goal as initialized', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(() => db.close());
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final repo = StatisticsRepository(db, prefs);

    await repo.setWeeklyGoalSessions(30);
    final setup = await repo.getWeeklyGoalSetupState();
    expect(setup.initialized, isTrue);
    expect(setup.weeklyGoalSessions, 30);
  });
}

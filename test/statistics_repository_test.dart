import 'package:drift/drift.dart';
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
}

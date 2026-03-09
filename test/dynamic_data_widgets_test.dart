import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pomodorofocus/data/models/catalog_item.dart';
import 'package:pomodorofocus/data/models/statistics_models.dart';
import 'package:pomodorofocus/data/models/task_entity.dart';
import 'package:pomodorofocus/data/repositories/sound_mix_repository.dart';
import 'package:pomodorofocus/data/db/app_database.dart';
import 'package:pomodorofocus/presentation/custom_sound_mixer_screen/custom_sound_mixer_screen.dart';
import 'package:pomodorofocus/presentation/onboarding_setup_flow_screen/widgets/atmosphere_step_widget.dart';
import 'package:pomodorofocus/presentation/post_session_reflection_screen/post_session_reflection_screen.dart';
import 'package:pomodorofocus/presentation/statistics_screen/statistics_screen.dart';
import 'package:pomodorofocus/presentation/tasks_screen/tasks_screen.dart';
import 'package:pomodorofocus/state/app/app_providers.dart';
import 'package:pomodorofocus/state/app/data_providers.dart';
import 'package:pomodorofocus/state/tasks/task_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

Future<void> _pumpWithOverrides(
  WidgetTester tester, {
  required Widget child,
  required List<Override> overrides,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: overrides,
      child: Sizer(
        builder: (context, orientation, screenType) {
          return MaterialApp(home: child);
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('fresh install shows empty tasks state without auto-seeding', (
    tester,
  ) async {
    await _pumpWithOverrides(
      tester,
      child: const TasksScreen(),
      overrides: [
        tasksStreamProvider.overrideWith(
          (ref) => Stream.value(const <TaskEntity>[]),
        ),
      ],
    );

    expect(find.text('Your task list is empty'), findsOneWidget);
  });

  testWidgets('statistics empty state appears when there is no history', (
    tester,
  ) async {
    await _pumpWithOverrides(
      tester,
      child: const StatisticsScreen(),
      overrides: [
        statisticsSummaryProvider.overrideWith(
          (ref) async => const StatsSummary(
            todaySessions: 0,
            currentStreak: 0,
            totalFocusMinutes: 0,
            weeklyCompletedSessions: 0,
            weeklyGoalSessions: 40,
            canEditWeeklyGoal: true,
            weeklyGoalLockMessage: null,
            completedTasks: 0,
            onTimeTasks: 0,
          ),
        ),
        statisticsBucketsProvider(
          StatsRange.daily,
        ).overrideWith((ref) async => const <TimeBucketStat>[]),
        achievementsProvider.overrideWith(
          (ref) async => const <AchievementView>[],
        ),
        reflectionSummaryProvider.overrideWith(
          (ref) async => const ReflectionSummary(
            weeklyReflectionCount: 0,
            moodBreakdown: <MoodBreakdownItem>[],
          ),
        ),
      ],
    );

    expect(find.text('No Data Yet'), findsOneWidget);
  });

  testWidgets('statistics renders dynamic values from providers', (
    tester,
  ) async {
    await _pumpWithOverrides(
      tester,
      child: const StatisticsScreen(),
      overrides: [
        statisticsSummaryProvider.overrideWith(
          (ref) async => const StatsSummary(
            todaySessions: 1,
            currentStreak: 3,
            totalFocusMinutes: 50,
            weeklyCompletedSessions: 4,
            weeklyGoalSessions: 40,
            canEditWeeklyGoal: true,
            weeklyGoalLockMessage: null,
            completedTasks: 2,
            onTimeTasks: 1,
          ),
        ),
        statisticsBucketsProvider(StatsRange.daily).overrideWith(
          (ref) async => [
            TimeBucketStat(
              label: 'Mon',
              bucketStart: DateTime(2026, 3, 2),
              sessions: 1,
              focusMinutes: 25,
            ),
            TimeBucketStat(
              label: 'Tue',
              bucketStart: DateTime(2026, 3, 3),
              sessions: 1,
              focusMinutes: 25,
            ),
          ],
        ),
        achievementsProvider.overrideWith(
          (ref) async => [
            const AchievementView(
              key: 'first_session',
              title: 'First Session',
              description: 'Completed your first Pomodoro!',
              iconToken: 'emoji_events',
              colorHex: 0xFFFFD700,
              threshold: 1,
              metric: AchievementMetric.sessionCount,
              currentValue: 2,
              unlocked: true,
            ),
          ],
        ),
        reflectionSummaryProvider.overrideWith(
          (ref) async => const ReflectionSummary(
            weeklyReflectionCount: 2,
            moodBreakdown: <MoodBreakdownItem>[
              MoodBreakdownItem(mood: 'Focused', count: 2, percentage: 1.0),
            ],
          ),
        ),
      ],
    );

    expect(find.text('Sessions Overview'), findsOneWidget);
    expect(find.text('Reflections'), findsOneWidget);
    expect(find.text('Achievements'), findsOneWidget);
  });

  testWidgets('catalog-driven atmosphere and mood entries render', (
    tester,
  ) async {
    await _pumpWithOverrides(
      tester,
      child: const Scaffold(
        body: AtmosphereStepWidget(
          selectedAtmosphere: 'Silent',
          onAtmosphereSelected: _noopAtmosphereSelect,
        ),
      ),
      overrides: [
        catalogItemsProvider(CatalogType.atmosphere).overrideWith(
          (ref) => Stream.value(const [
            CatalogItem(
              id: 'atmosphere_silent',
              type: CatalogType.atmosphere,
              value: 'Silent',
              label: 'Silent',
              description: 'Pure quiet focus',
              emoji: '🤫',
              iconToken: null,
              sortOrder: 1,
              isActive: true,
            ),
          ]),
        ),
      ],
    );
    expect(find.text('Silent'), findsOneWidget);

    await _pumpWithOverrides(
      tester,
      child: const PostSessionReflectionScreen(),
      overrides: [
        catalogItemsProvider(CatalogType.mood).overrideWith(
          (ref) => Stream.value(const [
            CatalogItem(
              id: 'mood_focused',
              type: CatalogType.mood,
              value: 'Focused',
              label: 'Focused',
              description: null,
              emoji: '🙂',
              iconToken: null,
              sortOrder: 1,
              isActive: true,
            ),
          ]),
        ),
      ],
    );
    expect(find.text('Focused'), findsOneWidget);
  });

  testWidgets('custom sound mixer renders catalog-backed sound entries', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(NativeDatabase.memory());
    final soundRepo = SoundMixRepository(database: db, preferences: prefs);
    addTearDown(() => db.close());

    await _pumpWithOverrides(
      tester,
      child: const CustomSoundMixerScreen(),
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        soundMixRepositoryProvider.overrideWithValue(soundRepo),
        catalogItemsProvider(CatalogType.soundSource).overrideWith(
          (ref) => Stream.value(const [
            CatalogItem(
              id: 'sound_rain',
              type: CatalogType.soundSource,
              value: 'rain',
              label: 'Rain',
              description: null,
              emoji: null,
              iconToken: 'water_drop_rounded',
              sortOrder: 1,
              isActive: true,
            ),
          ]),
        ),
      ],
    );

    expect(find.text('Rain'), findsOneWidget);
  });
}

void _noopAtmosphereSelect(String _) {}

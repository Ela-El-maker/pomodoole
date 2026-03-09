import 'package:pomodorofocus/data/db/app_database.dart';
import 'package:pomodorofocus/data/models/statistics_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsRepository {
  StatisticsRepository(this._database, this._preferences);

  final AppDatabase _database;
  final SharedPreferences _preferences;

  static const _weeklyGoalKey = 'weekly_goal_sessions';
  static const _weeklyGoalWeekStartKey = 'weekly_goal_week_start_epoch_ms';
  static const _weeklyGoalInitializedKey = 'weekly_goal_initialized';
  static const int _defaultWeeklyGoalSessions = 40;

  int get weeklyGoalSessions =>
      _preferences.getInt(_weeklyGoalKey) ?? _defaultWeeklyGoalSessions;

  Future<void> setWeeklyGoalSessions(int sessions) async {
    final now = DateTime.now();
    await _preferences.setInt(_weeklyGoalKey, sessions.clamp(1, 200));
    await _preferences.setInt(
      _weeklyGoalWeekStartKey,
      _startOfWeek(now).millisecondsSinceEpoch,
    );
    await _preferences.setBool(_weeklyGoalInitializedKey, true);
  }

  Future<WeeklyGoalSetupState> getWeeklyGoalSetupState() async {
    final summary = await getSummary();
    final initialized =
        _preferences.getBool(_weeklyGoalInitializedKey) ?? false;
    final canEdit = !initialized || summary.canEditWeeklyGoal;
    return WeeklyGoalSetupState(
      weeklyGoalSessions: summary.weeklyGoalSessions,
      initialized: initialized,
      canEdit: canEdit,
      lockMessage: canEdit
          ? null
          : (summary.weeklyGoalLockMessage ??
                'Goal can be edited after reaching it or when this week ends.'),
    );
  }

  Future<ReflectionSummary> getWeeklyReflectionSummary(
    DateTime nowLocal,
  ) async {
    final reflections = await _database.getAllReflections();
    final startOfWeek = _startOfWeek(nowLocal);
    final weeklyReflections = reflections.where((reflection) {
      final localTime = reflection.createdAt.toLocal();
      return !localTime.isBefore(startOfWeek) && !localTime.isAfter(nowLocal);
    }).toList();

    final total = weeklyReflections.length;
    if (total == 0) {
      return const ReflectionSummary(
        weeklyReflectionCount: 0,
        moodBreakdown: [],
      );
    }

    final byMood = <String, int>{};
    for (final reflection in weeklyReflections) {
      final rawMood = reflection.mood?.trim() ?? '';
      final mood = rawMood.isEmpty ? 'Unspecified' : rawMood;
      byMood[mood] = (byMood[mood] ?? 0) + 1;
    }

    final breakdown =
        byMood.entries
            .map(
              (entry) => MoodBreakdownItem(
                mood: entry.key,
                count: entry.value,
                percentage: entry.value / total,
              ),
            )
            .toList()
          ..sort((a, b) {
            final countCompare = b.count.compareTo(a.count);
            if (countCompare != 0) return countCompare;
            return a.mood.compareTo(b.mood);
          });

    return ReflectionSummary(
      weeklyReflectionCount: total,
      moodBreakdown: breakdown,
    );
  }

  Future<StatsSummary> getSummary() async {
    final sessions = await _database.getCompletedFocusSessions();
    final completedTasks = await _database.getCompletedTasksCount();
    final onTimeTasks = await _database.getCompletedTasksOnTimeCount();
    final now = DateTime.now();

    final todaySessions = sessions
        .where((session) => _isSameDay(session.createdAt.toLocal(), now))
        .length;
    final totalFocusMinutes = sessions.fold<int>(
      0,
      (sum, session) => sum + (session.durationSeconds ~/ 60),
    );
    final currentStreak = _computeCurrentStreak(
      sessions.map((session) => session.createdAt.toLocal()),
    );
    final startOfWeek = _startOfWeek(now);
    final weeklyCompletedSessions = sessions
        .where(
          (session) =>
              !session.createdAt.toLocal().isBefore(startOfWeek) &&
              !session.createdAt.toLocal().isAfter(now),
        )
        .length;
    final goalSessions = weeklyGoalSessions;
    final goalAchieved = weeklyCompletedSessions >= goalSessions;
    final editUnlockedByWeek = _isWeekAfterGoalLock(now);
    final canEditWeeklyGoal = goalAchieved || editUnlockedByWeek;
    final weeklyGoalLockMessage = canEditWeeklyGoal
        ? null
        : 'Goal can be edited after reaching it or when this week ends.';

    return StatsSummary(
      todaySessions: todaySessions,
      currentStreak: currentStreak,
      totalFocusMinutes: totalFocusMinutes,
      weeklyCompletedSessions: weeklyCompletedSessions,
      weeklyGoalSessions: goalSessions,
      canEditWeeklyGoal: canEditWeeklyGoal,
      weeklyGoalLockMessage: weeklyGoalLockMessage,
      completedTasks: completedTasks,
      onTimeTasks: onTimeTasks,
    );
  }

  Future<List<TimeBucketStat>> getBuckets(
    StatsRange range,
    DateTime nowLocal,
  ) async {
    final sessions = await _database.getCompletedFocusSessions();
    final aggregates = <DateTime, _BucketAggregate>{};

    for (final session in sessions) {
      final localTime = session.createdAt.toLocal();
      final bucketStart = _bucketStartFor(range, localTime);
      final existing = aggregates[bucketStart] ?? const _BucketAggregate();
      aggregates[bucketStart] = _BucketAggregate(
        sessions: existing.sessions + 1,
        focusMinutes: existing.focusMinutes + (session.durationSeconds ~/ 60),
      );
    }

    final bucketStarts = _recentBuckets(range, nowLocal);
    return bucketStarts.map((bucketStart) {
      final aggregate =
          aggregates[bucketStart] ??
          const _BucketAggregate(sessions: 0, focusMinutes: 0);
      return TimeBucketStat(
        label: _bucketLabel(range, bucketStart),
        bucketStart: bucketStart,
        sessions: aggregate.sessions,
        focusMinutes: aggregate.focusMinutes,
      );
    }).toList();
  }

  Future<List<AchievementView>> getAchievements(DateTime nowLocal) async {
    final sessions = await _database.getCompletedFocusSessions();
    final definitions = await _database.getAchievementDefinitions();

    final sessionCount = sessions.length;
    final streakDays = _computeCurrentStreak(
      sessions.map((session) => session.createdAt.toLocal()),
    );
    final focusMinutes = sessions.fold<int>(
      0,
      (sum, session) => sum + (session.durationSeconds ~/ 60),
    );

    return definitions.map((definition) {
      final metric = achievementMetricFromDb(definition.metric);
      final currentValue = switch (metric) {
        AchievementMetric.sessionCount => sessionCount,
        AchievementMetric.streakDays => streakDays,
        AchievementMetric.focusMinutes => focusMinutes,
      };

      return AchievementView(
        key: definition.key,
        title: definition.title,
        description: definition.description,
        iconToken: definition.iconToken,
        colorHex: definition.colorHex,
        threshold: definition.threshold,
        metric: metric,
        currentValue: currentValue,
        unlocked: currentValue >= definition.threshold,
      );
    }).toList();
  }

  DateTime _bucketStartFor(StatsRange range, DateTime localDateTime) {
    switch (range) {
      case StatsRange.daily:
        return DateTime(
          localDateTime.year,
          localDateTime.month,
          localDateTime.day,
        );
      case StatsRange.weekly:
        return _startOfWeek(localDateTime);
      case StatsRange.monthly:
        return DateTime(localDateTime.year, localDateTime.month);
    }
  }

  List<DateTime> _recentBuckets(StatsRange range, DateTime nowLocal) {
    switch (range) {
      case StatsRange.daily:
        final today = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
        return List<DateTime>.generate(
          7,
          (index) => today.subtract(Duration(days: 6 - index)),
        );
      case StatsRange.weekly:
        final currentWeekStart = _startOfWeek(nowLocal);
        return List<DateTime>.generate(
          6,
          (index) => currentWeekStart.subtract(Duration(days: (5 - index) * 7)),
        );
      case StatsRange.monthly:
        final thisMonth = DateTime(nowLocal.year, nowLocal.month);
        return List<DateTime>.generate(6, (index) {
          final offset = 5 - index;
          final year = thisMonth.year;
          final month = thisMonth.month - offset;
          return DateTime(year, month);
        });
    }
  }

  String _bucketLabel(StatsRange range, DateTime bucketStart) {
    switch (range) {
      case StatsRange.daily:
        const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return weekdays[bucketStart.weekday - 1];
      case StatsRange.weekly:
        return 'W${_weekOfYear(bucketStart)}';
      case StatsRange.monthly:
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return months[bucketStart.month - 1];
    }
  }

  DateTime _startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  bool _isWeekAfterGoalLock(DateTime now) {
    final lockEpoch = _preferences.getInt(_weeklyGoalWeekStartKey);
    if (lockEpoch == null) {
      return true;
    }
    final lockedWeekStart = DateTime.fromMillisecondsSinceEpoch(lockEpoch);
    final currentWeekStart = _startOfWeek(now);
    return currentWeekStart.isAfter(
      DateTime(
        lockedWeekStart.year,
        lockedWeekStart.month,
        lockedWeekStart.day,
      ),
    );
  }

  int _weekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceYearStart = date.difference(firstDayOfYear).inDays;
    final firstWeekdayOffset = firstDayOfYear.weekday - DateTime.monday;
    return ((daysSinceYearStart + firstWeekdayOffset) ~/ 7) + 1;
  }

  int _computeCurrentStreak(Iterable<DateTime> localSessionDates) {
    if (localSessionDates.isEmpty) return 0;
    final uniqueDays =
        localSessionDates
            .map((d) => DateTime(d.year, d.month, d.day))
            .toSet()
            .toList()
          ..sort();

    var streak = 1;
    for (var i = uniqueDays.length - 1; i > 0; i--) {
      final current = uniqueDays[i];
      final previous = uniqueDays[i - 1];
      final diff = current.difference(previous).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _BucketAggregate {
  const _BucketAggregate({this.sessions = 0, this.focusMinutes = 0});

  final int sessions;
  final int focusMinutes;
}

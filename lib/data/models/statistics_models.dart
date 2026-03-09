enum StatsRange { daily, weekly, monthly }

enum AchievementMetric { sessionCount, streakDays, focusMinutes }

AchievementMetric achievementMetricFromDb(String value) {
  switch (value) {
    case 'session_count':
      return AchievementMetric.sessionCount;
    case 'streak_days':
      return AchievementMetric.streakDays;
    case 'focus_minutes':
      return AchievementMetric.focusMinutes;
    default:
      return AchievementMetric.sessionCount;
  }
}

class StatsSummary {
  const StatsSummary({
    required this.todaySessions,
    required this.currentStreak,
    required this.totalFocusMinutes,
    required this.weeklyCompletedSessions,
    required this.weeklyGoalSessions,
    required this.completedTasks,
    required this.onTimeTasks,
  });

  final int todaySessions;
  final int currentStreak;
  final int totalFocusMinutes;
  final int weeklyCompletedSessions;
  final int weeklyGoalSessions;
  final int completedTasks;
  final int onTimeTasks;
}

class TimeBucketStat {
  const TimeBucketStat({
    required this.label,
    required this.bucketStart,
    required this.sessions,
    required this.focusMinutes,
  });

  final String label;
  final DateTime bucketStart;
  final int sessions;
  final int focusMinutes;
}

class AchievementView {
  const AchievementView({
    required this.key,
    required this.title,
    required this.description,
    required this.iconToken,
    required this.colorHex,
    required this.threshold,
    required this.metric,
    required this.currentValue,
    required this.unlocked,
  });

  final String key;
  final String title;
  final String description;
  final String iconToken;
  final int colorHex;
  final int threshold;
  final AchievementMetric metric;
  final int currentValue;
  final bool unlocked;
}

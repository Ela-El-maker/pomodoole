import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodorofocus/data/models/statistics_models.dart';
import 'package:pomodorofocus/state/app/data_providers.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_icon_widget.dart';
import './widgets/achievement_badges_widget.dart';
import './widgets/bar_chart_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/line_chart_widget.dart';
import './widgets/reflections_section_widget.dart';
import './widgets/segment_control_widget.dart';
import './widgets/summary_cards_widget.dart';
import './widgets/weekly_goal_widget.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  int _selectedSegment = 0;

  StatsRange get _selectedRange {
    switch (_selectedSegment) {
      case 1:
        return StatsRange.weekly;
      case 2:
        return StatsRange.monthly;
      default:
        return StatsRange.daily;
    }
  }

  Future<void> _onRefresh() async {
    ref.invalidate(statisticsSummaryProvider);
    ref.invalidate(statisticsBucketsProvider(_selectedRange));
    ref.invalidate(achievementsProvider);
    ref.invalidate(reflectionSummaryProvider);
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  Future<void> _editWeeklyGoal(StatsSummary summary) async {
    if (!summary.canEditWeeklyGoal) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            summary.weeklyGoalLockMessage ??
                'Goal editing is locked for this week.',
          ),
        ),
      );
      return;
    }

    var tempGoal = summary.weeklyGoalSessions;
    final selected = await showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Weekly Sessions Goal',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: tempGoal > 1
                          ? () => setModalState(() => tempGoal--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      '$tempGoal sessions',
                      style: Theme.of(ctx).textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: tempGoal < 200
                          ? () => setModalState(() => tempGoal++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(tempGoal),
                    child: const Text('Save Goal'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null) return;
    await ref
        .read(statisticsRepositoryProvider)
        .setWeeklyGoalSessions(selected.clamp(1, 200));
    ref.invalidate(statisticsSummaryProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(statisticsSummaryProvider);
    final bucketsAsync = ref.watch(statisticsBucketsProvider(_selectedRange));
    final achievementsAsync = ref.watch(achievementsProvider);
    final reflectionsAsync = ref.watch(reflectionSummaryProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          child: summaryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _ErrorState(message: '$error'),
            data: (summary) {
              return bucketsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => _ErrorState(message: '$error'),
                data: (buckets) {
                  return achievementsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) =>
                        _ErrorState(message: '$error'),
                    data: (achievements) {
                      return reflectionsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stackTrace) =>
                            _ErrorState(message: '$error'),
                        data: (reflectionSummary) {
                          final hasData =
                              summary.totalFocusMinutes > 0 ||
                              reflectionSummary.weeklyReflectionCount > 0;
                          if (!hasData) {
                            return const EmptyStateWidget();
                          }
                          return RefreshIndicator(
                            onRefresh: _onRefresh,
                            color: theme.colorScheme.primary,
                            child: CustomScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildHeader(theme),
                                      SizedBox(height: 2.h),
                                      Semantics(
                                        label:
                                            'Today: ${summary.todaySessions} sessions, ${summary.currentStreak} day streak, ${summary.totalFocusMinutes} total focus minutes',
                                        child: SummaryCardsWidget(
                                          todaySessions: summary.todaySessions,
                                          currentStreak: summary.currentStreak,
                                          totalFocusMinutes:
                                              summary.totalFocusMinutes,
                                        ),
                                      ),
                                      SizedBox(height: 1.2.h),
                                      Text(
                                        'Tasks completed: ${summary.completedTasks} • On-time: ${summary.onTimeTasks}',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      SizedBox(height: 2.h),
                                      Semantics(
                                        label: 'Time period selector',
                                        child: SegmentControlWidget(
                                          selectedIndex: _selectedSegment,
                                          onChanged: (index) {
                                            setState(
                                              () => _selectedSegment = index,
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'Sessions Overview',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      SizedBox(height: 1.h),
                                      _buildSemanticBarChart(buckets),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'Focus Time Trend',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      SizedBox(height: 1.h),
                                      LineChartWidget(data: buckets),
                                      SizedBox(height: 2.h),
                                      Semantics(
                                        label:
                                            'Weekly goal: ${summary.weeklyCompletedSessions} of ${summary.weeklyGoalSessions} sessions completed',
                                        child: WeeklyGoalWidget(
                                          completedSessions:
                                              summary.weeklyCompletedSessions,
                                          goalSessions:
                                              summary.weeklyGoalSessions,
                                          canEditGoal:
                                              summary.canEditWeeklyGoal,
                                          onEditGoal: () =>
                                              _editWeeklyGoal(summary),
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      ReflectionsSectionWidget(
                                        summary: reflectionSummary,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'Achievements',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      SizedBox(height: 1.h),
                                      AchievementBadgesWidget(
                                        achievements: achievements,
                                      ),
                                      SizedBox(height: 2.h),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSemanticBarChart(List<TimeBucketStat> data) {
    final range = _selectedRange;
    final descriptions = data
        .map(
          (d) =>
              '${d.label}: ${d.sessions} sessions, ${d.focusMinutes} minutes',
        )
        .join('. ');

    return Semantics(
      label: 'Bar chart for ${_rangeLabel(range)} sessions. $descriptions',
      child: ExcludeSemantics(child: BarChartWidget(data: data)),
    );
  }

  String _rangeLabel(StatsRange range) {
    switch (range) {
      case StatsRange.daily:
        return 'daily';
      case StatsRange.weekly:
        return 'weekly';
      case StatsRange.monthly:
        return 'monthly';
    }
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Statistics',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Semantics(
          label: 'Share statistics',
          button: true,
          child: CustomIconWidget(
            iconName: 'share',
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Failed to load statistics: $message',
        textAlign: TextAlign.center,
      ),
    );
  }
}

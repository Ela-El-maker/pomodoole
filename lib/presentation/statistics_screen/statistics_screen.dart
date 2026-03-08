import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/achievement_badges_widget.dart';
import './widgets/bar_chart_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/line_chart_widget.dart';
import './widgets/segment_control_widget.dart';
import './widgets/summary_cards_widget.dart';
import './widgets/weekly_goal_widget.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedSegment = 0;
  final bool _hasData = true;

  final List<Map<String, dynamic>> _dailySessions = [
    {"day": "Mon", "sessions": 4, "focusMinutes": 100},
    {"day": "Tue", "sessions": 6, "focusMinutes": 150},
    {"day": "Wed", "sessions": 3, "focusMinutes": 75},
    {"day": "Thu", "sessions": 8, "focusMinutes": 200},
    {"day": "Fri", "sessions": 5, "focusMinutes": 125},
    {"day": "Sat", "sessions": 2, "focusMinutes": 50},
    {"day": "Sun", "sessions": 7, "focusMinutes": 175},
  ];

  final List<Map<String, dynamic>> _weeklySessions = [
    {"week": "W1", "sessions": 28, "focusMinutes": 700},
    {"week": "W2", "sessions": 35, "focusMinutes": 875},
    {"week": "W3", "sessions": 22, "focusMinutes": 550},
    {"week": "W4", "sessions": 40, "focusMinutes": 1000},
  ];

  final List<Map<String, dynamic>> _monthlySessions = [
    {"month": "Oct", "sessions": 90, "focusMinutes": 2250},
    {"month": "Nov", "sessions": 110, "focusMinutes": 2750},
    {"month": "Dec", "sessions": 85, "focusMinutes": 2125},
    {"month": "Jan", "sessions": 120, "focusMinutes": 3000},
    {"month": "Feb", "sessions": 95, "focusMinutes": 2375},
    {"month": "Mar", "sessions": 45, "focusMinutes": 1125},
  ];

  final List<Map<String, dynamic>> _achievements = [
    {
      "title": "First Session",
      "description": "Completed your first Pomodoro!",
      "icon": "emoji_events",
      "color": 0xFFFFD700,
      "unlocked": true,
    },
    {
      "title": "7-Day Streak",
      "description": "7 consecutive days of focus",
      "icon": "local_fire_department",
      "color": 0xFFFF6B35,
      "unlocked": true,
    },
    {
      "title": "100 Sessions",
      "description": "Completed 100 total sessions",
      "icon": "military_tech",
      "color": 0xFF7A9CC6,
      "unlocked": true,
    },
    {
      "title": "30-Day Streak",
      "description": "30 consecutive days of focus",
      "icon": "diamond",
      "color": 0xFF9B59B6,
      "unlocked": false,
    },
  ];

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  List<Map<String, dynamic>> get _currentData {
    switch (_selectedSegment) {
      case 1:
        return _weeklySessions;
      case 2:
        return _monthlySessions;
      default:
        return _dailySessions;
    }
  }

  String get _xAxisKey {
    switch (_selectedSegment) {
      case 1:
        return "week";
      case 2:
        return "month";
      default:
        return "day";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          child: _hasData
              ? RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: theme.colorScheme.primary,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(theme),
                            SizedBox(height: 2.h),
                            Semantics(
                              label:
                                  'Today: 5 sessions, 12 day streak, 875 total focus minutes',
                              child: SummaryCardsWidget(
                                todaySessions: 5,
                                currentStreak: 12,
                                totalFocusMinutes: 875,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Semantics(
                              label: 'Time period selector',
                              child: SegmentControlWidget(
                                selectedIndex: _selectedSegment,
                                onChanged: (index) =>
                                    setState(() => _selectedSegment = index),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Sessions Overview',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            _buildSemanticBarChart(),
                            SizedBox(height: 2.h),
                            Text(
                              'Focus Time Trend',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            LineChartWidget(
                              data: _currentData,
                              xAxisKey: _xAxisKey,
                            ),
                            SizedBox(height: 2.h),
                            Semantics(
                              label: 'Weekly goal: 35 of 40 sessions completed',
                              child: WeeklyGoalWidget(
                                completedSessions: 35,
                                goalSessions: 40,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Achievements',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            AchievementBadgesWidget(
                              achievements: _achievements,
                            ),
                            SizedBox(height: 2.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : EmptyStateWidget(),
        ),
      ),
    );
  }

  Widget _buildSemanticBarChart() {
    // Build a semantics description for each bar
    final descriptions = _currentData
        .map((d) {
          final label = d[_xAxisKey] as String;
          final sessions = d['sessions'] as int;
          final minutes = d['focusMinutes'] as int;
          return '$label: $sessions sessions, $minutes minutes';
        })
        .join('. ');

    return Semantics(
      label:
          'Bar chart. $_selectedSegment == 0 ? Daily : (_selectedSegment == 1 ? Weekly : Monthly) sessions. $descriptions',
      child: ExcludeSemantics(
        child: BarChartWidget(data: _currentData, xAxisKey: _xAxisKey),
      ),
    );
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

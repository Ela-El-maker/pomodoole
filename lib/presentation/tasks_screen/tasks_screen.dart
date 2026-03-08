import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import './widgets/task_item_widget.dart';
import './widgets/tasks_empty_state_widget.dart';
import './widgets/add_task_sheet_widget.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../routes/app_routes.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  static const Color _bgColor = Color(0xFFF7F7F5);
  static const Color _accentRed = Color(0xFFE76F6F);
  static const Color _primaryText = Color(0xFF2F2F2F);
  static const Color _secondaryText = Color(0xFF6F6F6F);

  final List<Map<String, dynamic>> _tasks = [
    {
      'id': '1',
      'title': 'Study Biology',
      'notes': 'Chapter 5 - Cell division and mitosis',
      'estimatedPomodoros': 3,
      'completedPomodoros': 1,
      'isCompleted': false,
      'isActive': true,
    },
    {
      'id': '2',
      'title': 'Write Essay',
      'notes': 'Introduction and first two paragraphs',
      'estimatedPomodoros': 2,
      'completedPomodoros': 0,
      'isCompleted': false,
      'isActive': false,
    },
    {
      'id': '3',
      'title': 'Review Pull Requests',
      'notes': '',
      'estimatedPomodoros': 1,
      'completedPomodoros': 1,
      'isCompleted': true,
      'isActive': false,
    },
    {
      'id': '4',
      'title': 'Prepare Presentation',
      'notes': 'Slides for Monday team meeting',
      'estimatedPomodoros': 4,
      'completedPomodoros': 0,
      'isCompleted': false,
      'isActive': false,
    },
  ];

  int _currentNavIndex = 1;

  List<Map<String, dynamic>> get _activeTasks =>
      _tasks.where((t) => t['isCompleted'] != true).toList();

  List<Map<String, dynamic>> get _completedTasks =>
      _tasks.where((t) => t['isCompleted'] == true).toList();

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {});
  }

  void _showAddTaskSheet({Map<String, dynamic>? existingTask}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskSheetWidget(
        existingTask: existingTask,
        onSave: (task) {
          setState(() {
            if (existingTask != null) {
              final idx = _tasks.indexWhere(
                (t) => t['id'] == existingTask['id'],
              );
              if (idx != -1) {
                _tasks[idx] = {...existingTask, ...task};
              }
            } else {
              _tasks.insert(0, {
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'isCompleted': false,
                'isActive': false,
                'completedPomodoros': 0,
                ...task,
              });
            }
          });
        },
      ),
    );
  }

  void _deleteTask(String id) {
    HapticFeedback.mediumImpact();
    setState(() => _tasks.removeWhere((t) => t['id'] == id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Task removed 🌿',
          style: GoogleFonts.dmSans(fontSize: 14),
        ),
        backgroundColor: const Color(0xFF2F2F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleComplete(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      final idx = _tasks.indexWhere((t) => t['id'] == id);
      if (idx != -1) {
        _tasks[idx]['isCompleted'] = !(_tasks[idx]['isCompleted'] as bool);
        if (_tasks[idx]['isCompleted'] == true) {
          _tasks[idx]['isActive'] = false;
        }
      }
    });
  }

  void _setActiveTask(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      for (final task in _tasks) {
        task['isActive'] = task['id'] == id && task['isActive'] != true;
      }
    });
  }

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    setState(() => _currentNavIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.focusScreen);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.statistics);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTasks = _activeTasks;
    final completedTasks = _completedTasks;
    final hasAnyTask = _tasks.isNotEmpty;

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(5.w, 3.h, 5.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Tasks',
                    style: GoogleFonts.dmSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: _primaryText,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${activeTasks.length} task${activeTasks.length != 1 ? 's' : ''} remaining',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: _secondaryText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            // Task list
            Expanded(
              child: !hasAnyTask
                  ? TasksEmptyStateWidget(onAddTask: () => _showAddTaskSheet())
                  : RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: _accentRed,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 1.h,
                        ),
                        children: [
                          // Active tasks
                          if (activeTasks.isNotEmpty)
                            ...activeTasks.map(
                              (task) => Padding(
                                padding: EdgeInsets.only(bottom: 1.2.h),
                                child: TaskItemWidget(
                                  task: task,
                                  onToggleComplete: () =>
                                      _toggleComplete(task['id'] as String),
                                  onDelete: () =>
                                      _deleteTask(task['id'] as String),
                                  onSetActive: () =>
                                      _setActiveTask(task['id'] as String),
                                ),
                              ),
                            ),
                          // Completed section
                          if (completedTasks.isNotEmpty) ...[
                            SizedBox(height: 1.h),
                            Padding(
                              padding: EdgeInsets.only(bottom: 1.h),
                              child: Row(
                                children: [
                                  Text(
                                    'Completed',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: _secondaryText,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFA8C3A0,
                                      ).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${completedTasks.length}',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFA8C3A0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...completedTasks.map(
                              (task) => Padding(
                                padding: EdgeInsets.only(bottom: 1.2.h),
                                child: Opacity(
                                  opacity: 0.65,
                                  child: TaskItemWidget(
                                    task: task,
                                    onToggleComplete: () =>
                                        _toggleComplete(task['id'] as String),
                                    onDelete: () =>
                                        _deleteTask(task['id'] as String),
                                    onSetActive: () {},
                                  ),
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: 10.h),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showAddTaskSheet();
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _accentRed,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _accentRed.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 26),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodorofocus/data/db/app_database.dart';
import 'package:pomodorofocus/state/app/data_providers.dart';
import 'package:pomodorofocus/state/tasks/task_providers.dart';
import 'package:sizer/sizer.dart';

import './widgets/add_task_sheet_widget.dart';
import './widgets/task_item_widget.dart';
import './widgets/tasks_empty_state_widget.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  static const Color _bgColor = Color(0xFFF7F7F5);
  static const Color _accentRed = Color(0xFFE76F6F);
  static const Color _primaryText = Color(0xFF2F2F2F);
  static const Color _secondaryText = Color(0xFF6F6F6F);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _seedIfEmpty();
    });
  }

  Future<void> _seedIfEmpty() async {
    final repository = ref.read(tasksRepositoryProvider);
    final existing = await repository.fetchAll();
    if (existing.isNotEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    await repository.upsert(
      id: '${now + 1}',
      title: 'Study Biology',
      notes: 'Chapter 5 - Cell division and mitosis',
      estimatedPomodoros: 3,
      completedPomodoros: 1,
      isCompleted: false,
      isActive: true,
    );
    await repository.upsert(
      id: '${now + 2}',
      title: 'Write Essay',
      notes: 'Introduction and first two paragraphs',
      estimatedPomodoros: 2,
      completedPomodoros: 0,
    );
    await repository.upsert(
      id: '${now + 3}',
      title: 'Review Pull Requests',
      estimatedPomodoros: 1,
      completedPomodoros: 1,
      isCompleted: true,
    );
  }

  Map<String, dynamic> _toTaskMap(TasksTableData task) {
    return {
      'id': task.id,
      'title': task.title,
      'notes': task.notes,
      'estimatedPomodoros': task.estimatedPomodoros,
      'completedPomodoros': task.completedPomodoros,
      'isCompleted': task.isCompleted,
      'isActive': task.isActive,
    };
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  void _showAddTaskSheet({Map<String, dynamic>? existingTask}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskSheetWidget(
        existingTask: existingTask,
        onSave: (task) async {
          final repository = ref.read(tasksRepositoryProvider);
          final id =
              (existingTask?['id'] as String?) ??
              DateTime.now().millisecondsSinceEpoch.toString();
          await repository.upsert(
            id: id,
            title: task['title'] as String? ?? '',
            notes: task['notes'] as String? ?? '',
            estimatedPomodoros: task['estimatedPomodoros'] as int? ?? 1,
            completedPomodoros:
                existingTask?['completedPomodoros'] as int? ?? 0,
            isCompleted: existingTask?['isCompleted'] as bool? ?? false,
            isActive: existingTask?['isActive'] as bool? ?? false,
          );
        },
      ),
    );
  }

  Future<void> _deleteTask(String id) async {
    unawaited(HapticFeedback.mediumImpact());
    await ref.read(tasksRepositoryProvider).delete(id);
    if (!mounted) return;
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

  Future<void> _toggleComplete(Map<String, dynamic> task) async {
    unawaited(HapticFeedback.lightImpact());
    await ref
        .read(tasksRepositoryProvider)
        .upsert(
          id: task['id'] as String,
          title: task['title'] as String,
          notes: task['notes'] as String? ?? '',
          estimatedPomodoros: task['estimatedPomodoros'] as int? ?? 1,
          completedPomodoros: task['completedPomodoros'] as int? ?? 0,
          isCompleted: !(task['isCompleted'] as bool? ?? false),
          isActive: (task['isCompleted'] as bool? ?? false)
              ? false
              : (task['isActive'] as bool? ?? false),
        );
  }

  Future<void> _setActiveTask(Map<String, dynamic> selectedTask) async {
    unawaited(HapticFeedback.lightImpact());
    final repository = ref.read(tasksRepositoryProvider);
    final all = await repository.fetchAll();
    for (final task in all) {
      await repository.upsert(
        id: task.id,
        title: task.title,
        notes: task.notes,
        estimatedPomodoros: task.estimatedPomodoros,
        completedPomodoros: task.completedPomodoros,
        isCompleted: task.isCompleted,
        isActive: task.id == selectedTask['id'] && !task.isActive,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksStreamProvider);

    return tasksAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('Failed to load tasks: $error'))),
      data: (tasksData) {
        final tasks = tasksData.map(_toTaskMap).toList();
        final activeTasks = tasks
            .where((t) => t['isCompleted'] != true)
            .toList();
        final completedTasks = tasks
            .where((t) => t['isCompleted'] == true)
            .toList();
        final hasAnyTask = tasks.isNotEmpty;

        return Scaffold(
          backgroundColor: _bgColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Expanded(
                  child: !hasAnyTask
                      ? TasksEmptyStateWidget(
                          onAddTask: () => _showAddTaskSheet(),
                        )
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
                              if (activeTasks.isNotEmpty)
                                ...activeTasks.map(
                                  (task) => Padding(
                                    padding: EdgeInsets.only(bottom: 1.2.h),
                                    child: TaskItemWidget(
                                      task: task,
                                      onToggleComplete: () =>
                                          _toggleComplete(task),
                                      onDelete: () =>
                                          _deleteTask(task['id'] as String),
                                      onSetActive: () => _setActiveTask(task),
                                    ),
                                  ),
                                ),
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
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
                                            _toggleComplete(task),
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
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/add_task_bottom_sheet_widget.dart';
import './widgets/task_card_widget.dart';
import './widgets/task_empty_state_widget.dart';

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _tasks = [
    {
      "id": "1",
      "title": "Design new landing page",
      "description":
          "Create wireframes and mockups for the new product landing page",
      "estimatedPomodoros": 4,
      "completedPomodoros": 2,
      "isCompleted": false,
      "isArchived": false,
      "createdAt": "2026-03-07",
    },
    {
      "id": "2",
      "title": "Write quarterly report",
      "description": "Compile data and write the Q1 2026 performance report",
      "estimatedPomodoros": 6,
      "completedPomodoros": 6,
      "isCompleted": true,
      "isArchived": false,
      "createdAt": "2026-03-06",
    },
    {
      "id": "3",
      "title": "Review pull requests",
      "description": "Review and merge pending pull requests from the team",
      "estimatedPomodoros": 2,
      "completedPomodoros": 1,
      "isCompleted": false,
      "isArchived": false,
      "createdAt": "2026-03-07",
    },
    {
      "id": "4",
      "title": "Study Flutter animations",
      "description":
          "Deep dive into implicit and explicit animations in Flutter",
      "estimatedPomodoros": 5,
      "completedPomodoros": 0,
      "isCompleted": false,
      "isArchived": false,
      "createdAt": "2026-03-05",
    },
    {
      "id": "5",
      "title": "Prepare presentation slides",
      "description":
          "Create slides for the upcoming team meeting on project roadmap",
      "estimatedPomodoros": 3,
      "completedPomodoros": 3,
      "isCompleted": true,
      "isArchived": false,
      "createdAt": "2026-03-04",
    },
    {
      "id": "6",
      "title": "Fix authentication bug",
      "description":
          "Investigate and fix the login timeout issue reported by users",
      "estimatedPomodoros": 2,
      "completedPomodoros": 0,
      "isCompleted": false,
      "isArchived": false,
      "createdAt": "2026-03-07",
    },
  ];

  List<Map<String, dynamic>> get _filteredTasks {
    final active = _tasks.where((t) => !(t["isArchived"] as bool)).toList();
    if (_searchQuery.isEmpty) return active;
    return active.where((t) {
      final title = (t["title"] as String).toLowerCase();
      final desc = (t["description"] as String).toLowerCase();
      return title.contains(_searchQuery.toLowerCase()) ||
          desc.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {});
  }

  void _showAddTaskSheet({Map<String, dynamic>? existingTask}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskBottomSheetWidget(
        existingTask: existingTask,
        onSave: (task) {
          setState(() {
            if (existingTask != null) {
              final idx = _tasks.indexWhere(
                (t) => t["id"] == existingTask["id"],
              );
              if (idx != -1) _tasks[idx] = {...existingTask, ...task};
            } else {
              _tasks.insert(0, {
                "id": DateTime.now().millisecondsSinceEpoch.toString(),
                "isCompleted": false,
                "isArchived": false,
                "completedPomodoros": 0,
                "createdAt": "2026-03-07",
                ...task,
              });
            }
          });
        },
      ),
    );
  }

  void _deleteTask(String id) {
    setState(() => _tasks.removeWhere((t) => t["id"] == id));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Task deleted')));
  }

  void _archiveTask(String id) {
    setState(() {
      final idx = _tasks.indexWhere((t) => t["id"] == id);
      if (idx != -1) _tasks[idx]["isArchived"] = true;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Task archived')));
  }

  void _toggleComplete(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      final idx = _tasks.indexWhere((t) => t["id"] == id);
      if (idx != -1) {
        _tasks[idx]["isCompleted"] = !(_tasks[idx]["isCompleted"] as bool);
      }
    });
  }

  void _duplicateTask(Map<String, dynamic> task) {
    setState(() {
      _tasks.insert(0, {
        ...task,
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "title": "${task["title"]} (Copy)",
        "isCompleted": false,
        "completedPomodoros": 0,
      });
    });
  }

  void _showContextMenu(Map<String, dynamic> task) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'edit',
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddTaskSheet(existingTask: task);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'copy_all',
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                title: const Text('Duplicate'),
                onTap: () {
                  Navigator.pop(context);
                  _duplicateTask(task);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'archive',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
                title: const Text('Archive'),
                onTap: () {
                  Navigator.pop(context);
                  _archiveTask(task["id"] as String);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'timer',
                  color: theme.colorScheme.tertiary,
                  size: 22,
                ),
                title: const Text('Assign to Session'),
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.timer);
                },
              ),
              SizedBox(height: 1.h),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredTasks = _filteredTasks;
    final activeTasks = filteredTasks
        .where((t) => !(t['isCompleted'] as bool))
        .toList();
    final completedTasks = filteredTasks
        .where((t) => t['isCompleted'] as bool)
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              SizedBox(height: 2.h),
              _buildSearchBar(theme),
              SizedBox(height: 2.h),
              Expanded(
                child: filteredTasks.isEmpty
                    ? TaskEmptyStateWidget(
                        isSearching: _isSearching,
                        onAddTask: _showAddTaskSheet,
                      )
                    : RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: theme.colorScheme.primary,
                        child: ListView(
                          children: [
                            if (activeTasks.isNotEmpty)
                              ..._buildTaskSection(
                                theme,
                                'Active Tasks',
                                activeTasks,
                                isCompleted: false,
                              ),
                            if (completedTasks.isNotEmpty)
                              ..._buildTaskSection(
                                theme,
                                'Completed',
                                completedTasks,
                                isCompleted: true,
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Semantics(
        label: 'Add new task',
        button: true,
        child: FloatingActionButton(
          onPressed: _showAddTaskSheet,
          child: const Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(theme),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final activeCount = _tasks
        .where((t) => !(t['isCompleted'] as bool) && !(t['isArchived'] as bool))
        .length;
    final completedCount = _tasks.where((t) => t['isCompleted'] as bool).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Management',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            _StatChip(
              label: '$activeCount Active',
              color: theme.colorScheme.primary,
              theme: theme,
            ),
            SizedBox(width: 2.w),
            _StatChip(
              label: '$completedCount Completed',
              color: theme.colorScheme.tertiary,
              theme: theme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search tasks...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                    _isSearching = false;
                  });
                },
              )
            : null,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
          _isSearching = value.isNotEmpty;
        });
      },
    );
  }

  List<Widget> _buildTaskSection(
    ThemeData theme,
    String title,
    List<Map<String, dynamic>> tasks, {
    required bool isCompleted,
  }) {
    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      ...tasks.map(
        (task) => Padding(
          padding: EdgeInsets.only(bottom: 1.5.h),
          child: Semantics(
            label:
                'Task: ${task["title"]}, ${(task["estimatedPomodoros"] as int) - (task["completedPomodoros"] as int)} sessions remaining',
            child: TaskCardWidget(
              task: task,
              onToggleComplete: () => _toggleComplete(task['id'] as String),
              onEdit: () => _showAddTaskSheet(existingTask: task),
              onDelete: () => _deleteTask(task['id'] as String),
              onLongPress: () => _showContextMenu(task),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildBottomNav(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(theme, 'home', 'Home', false),
              _buildNavItem(theme, 'timer', 'Timer', false),
              _buildNavItem(theme, 'checklist', 'Tasks', true),
              _buildNavItem(theme, 'analytics', 'Stats', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    ThemeData theme,
    String icon,
    String label,
    bool isActive,
  ) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  final ThemeData theme;

  const _StatChip({
    required this.label,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

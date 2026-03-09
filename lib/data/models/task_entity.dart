import 'package:pomodorofocus/data/db/app_database.dart';

class TaskEntity {
  const TaskEntity({
    required this.id,
    required this.title,
    required this.notes,
    required this.dueAt,
    required this.reminderAt,
    required this.reminderEnabled,
    required this.estimatedPomodoros,
    required this.completedPomodoros,
    required this.isCompleted,
    required this.isActive,
  });

  final String id;
  final String title;
  final String notes;
  final DateTime? dueAt;
  final DateTime? reminderAt;
  final bool reminderEnabled;
  final int estimatedPomodoros;
  final int completedPomodoros;
  final bool isCompleted;
  final bool isActive;

  factory TaskEntity.fromRow(TasksTableData row) {
    return TaskEntity(
      id: row.id,
      title: row.title,
      notes: row.notes,
      dueAt: row.dueAt,
      reminderAt: row.reminderAt,
      reminderEnabled: row.reminderEnabled,
      estimatedPomodoros: row.estimatedPomodoros,
      completedPomodoros: row.completedPomodoros,
      isCompleted: row.isCompleted,
      isActive: row.isActive,
    );
  }
}

class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.notes,
    required this.dueAt,
    required this.reminderAt,
    required this.reminderEnabled,
    required this.estimatedPomodoros,
  });

  final String title;
  final String notes;
  final DateTime? dueAt;
  final DateTime? reminderAt;
  final bool reminderEnabled;
  final int estimatedPomodoros;
}

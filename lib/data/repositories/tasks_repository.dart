import 'package:drift/drift.dart';
import 'package:pomodorofocus/data/db/app_database.dart';

class TasksRepository {
  TasksRepository(this._database);

  final AppDatabase _database;

  Stream<List<TasksTableData>> watchAll() => _database.watchAllTasks();

  Future<List<TasksTableData>> fetchAll() => _database.getAllTasks();

  Future<void> upsert({
    required String id,
    required String title,
    String notes = '',
    DateTime? dueAt,
    DateTime? reminderAt,
    bool reminderEnabled = false,
    int estimatedPomodoros = 1,
    int completedPomodoros = 0,
    bool isCompleted = false,
    bool isActive = false,
  }) {
    return _database.upsertTask(
      TasksTableCompanion(
        id: Value(id),
        title: Value(title),
        notes: Value(notes),
        dueAt: Value(dueAt),
        reminderAt: Value(reminderAt),
        reminderEnabled: Value(reminderEnabled),
        estimatedPomodoros: Value(estimatedPomodoros),
        completedPomodoros: Value(completedPomodoros),
        isCompleted: Value(isCompleted),
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> delete(String id) => _database.deleteTaskById(id);

  Future<TasksTableData?> findById(String id) => _database.getTaskById(id);

  Future<TasksTableData?> getActiveTask() => _database.getActiveTask();

  Future<void> incrementProgress(String taskId) {
    return _database.incrementTaskProgress(taskId);
  }

  Future<TasksTableData?> findIncompleteByTitle(String rawTitle) async {
    final normalizedTarget = _normalizeTitle(rawTitle);
    if (normalizedTarget.isEmpty) return null;
    final tasks = await _database.getAllTasks();
    for (final task in tasks) {
      if (task.isCompleted) continue;
      if (_normalizeTitle(task.title) == normalizedTarget) {
        return task;
      }
    }
    return null;
  }

  Future<String?> ensureTaskFromIntent(String rawTitle) async {
    final title = rawTitle.trim();
    if (title.isEmpty) return null;

    final existing = await findIncompleteByTitle(title);
    if (existing != null) {
      return existing.id;
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await upsert(
      id: id,
      title: title,
      notes: '',
      estimatedPomodoros: 1,
      completedPomodoros: 0,
      isCompleted: false,
      isActive: true,
    );
    return id;
  }

  String _normalizeTitle(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}

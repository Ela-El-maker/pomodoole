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
        estimatedPomodoros: Value(estimatedPomodoros),
        completedPomodoros: Value(completedPomodoros),
        isCompleted: Value(isCompleted),
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> delete(String id) => _database.deleteTaskById(id);
}

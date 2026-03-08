import 'package:pomodorofocus/data/db/app_database.dart';

class SessionHistoryRepository {
  SessionHistoryRepository(this._database);

  final AppDatabase _database;

  Future<void> addEntry({
    required String sessionType,
    required int durationSeconds,
    required bool completed,
  }) {
    return _database.saveSessionHistory(
      sessionType: sessionType,
      durationSeconds: durationSeconds,
      completed: completed,
    );
  }
}

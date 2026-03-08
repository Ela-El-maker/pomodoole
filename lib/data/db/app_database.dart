import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class TasksTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get estimatedPomodoros =>
      integer().withDefault(const Constant(1))();
  IntColumn get completedPomodoros =>
      integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SessionHistoryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionType => text()();
  IntColumn get durationSeconds => integer()();
  BoolColumn get completed => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class ReflectionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mood => text().nullable()();
  TextColumn get wentWell => text().nullable()();
  TextColumn get distractedBy => text().nullable()();
  TextColumn get nextFocus => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class SoundMixesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get levelsJson => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [TasksTable, SessionHistoryTable, ReflectionsTable, SoundMixesTable],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> upsertTask(TasksTableCompanion task) {
    return into(tasksTable).insertOnConflictUpdate(task);
  }

  Future<List<TasksTableData>> getAllTasks() {
    return (select(tasksTable)..orderBy([
          (table) => OrderingTerm(
            expression: table.createdAt,
            mode: OrderingMode.desc,
          ),
        ]))
        .get();
  }

  Stream<List<TasksTableData>> watchAllTasks() {
    return (select(tasksTable)..orderBy([
          (table) => OrderingTerm(
            expression: table.createdAt,
            mode: OrderingMode.desc,
          ),
        ]))
        .watch();
  }

  Future<int> deleteTaskById(String taskId) {
    return (delete(tasksTable)..where((table) => table.id.equals(taskId))).go();
  }

  Future<void> saveSessionHistory({
    required String sessionType,
    required int durationSeconds,
    required bool completed,
  }) {
    return into(sessionHistoryTable).insert(
      SessionHistoryTableCompanion.insert(
        sessionType: sessionType,
        durationSeconds: durationSeconds,
        completed: Value(completed),
      ),
    );
  }

  Future<void> saveReflection({
    String? mood,
    String? wentWell,
    String? distractedBy,
    String? nextFocus,
    String? notes,
  }) {
    return into(reflectionsTable).insert(
      ReflectionsTableCompanion.insert(
        mood: Value(mood),
        wentWell: Value(wentWell),
        distractedBy: Value(distractedBy),
        nextFocus: Value(nextFocus),
        notes: Value(notes),
      ),
    );
  }

  Future<void> upsertSoundMix(SoundMixesTableCompanion mix) {
    return into(soundMixesTable).insertOnConflictUpdate(mix);
  }

  Future<List<SoundMixesTableData>> getAllSoundMixes() {
    return (select(soundMixesTable)..orderBy([
          (table) => OrderingTerm(
            expression: table.createdAt,
            mode: OrderingMode.desc,
          ),
        ]))
        .get();
  }

  Future<void> setActiveMix(String mixId) async {
    await update(
      soundMixesTable,
    ).write(const SoundMixesTableCompanion(isActive: Value(false)));
    await (update(soundMixesTable)..where((table) => table.id.equals(mixId)))
        .write(const SoundMixesTableCompanion(isActive: Value(true)));
  }

  Future<int> deleteSoundMixById(String mixId) {
    return (delete(
      soundMixesTable,
    )..where((table) => table.id.equals(mixId))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'pomodoro_focus.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

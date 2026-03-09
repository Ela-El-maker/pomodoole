import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pomodorofocus/core/monitoring/app_logger.dart';

part 'app_database.g.dart';

class TasksTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get reminderAt => dateTime().nullable()();
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();
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
  TextColumn get taskId => text().nullable()();
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

class CatalogItemsTable extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get value => text()();
  TextColumn get label => text()();
  TextColumn get description => text().nullable()();
  TextColumn get emoji => text().nullable()();
  TextColumn get iconToken => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AchievementDefinitionsTable extends Table {
  TextColumn get key => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get metric => text()();
  IntColumn get threshold => integer()();
  TextColumn get iconToken => text()();
  IntColumn get colorHex => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    TasksTable,
    SessionHistoryTable,
    ReflectionsTable,
    SoundMixesTable,
    CatalogItemsTable,
    AchievementDefinitionsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());
  static const AppLogger _logger = AppLogger();

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      try {
        await m.createAll();
        await _seedDefaultsIfMissing();
        _logger.info(
          'database',
          'Migration completed (create)',
          data: {'schemaVersion': schemaVersion},
        );
      } catch (error, stackTrace) {
        _logger.warn(
          'database',
          'Migration failed (create)',
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    },
    onUpgrade: (m, from, to) async {
      try {
        if (from < 2) {
          await m.createTable(catalogItemsTable);
          await m.createTable(achievementDefinitionsTable);
        }
        if (from < 3) {
          await m.addColumn(tasksTable, tasksTable.dueAt);
          await m.addColumn(tasksTable, tasksTable.reminderAt);
          await m.addColumn(tasksTable, tasksTable.reminderEnabled);
          await m.addColumn(sessionHistoryTable, sessionHistoryTable.taskId);
        }
        await _seedDefaultsIfMissing();
        _logger.info(
          'database',
          'Migration completed (upgrade)',
          data: {'from': from, 'to': to},
        );
      } catch (error, stackTrace) {
        _logger.warn(
          'database',
          'Migration failed (upgrade)',
          error: error,
          stackTrace: stackTrace,
          data: {'from': from, 'to': to},
        );
        rethrow;
      }
    },
  );

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

  Future<TasksTableData?> getTaskById(String taskId) {
    return (select(tasksTable)..where((table) => table.id.equals(taskId)))
        .getSingleOrNull();
  }

  Future<TasksTableData?> getActiveTask() {
    return (select(tasksTable)
          ..where(
            (table) =>
                table.isActive.equals(true) & table.isCompleted.equals(false),
          )
          ..limit(1))
        .getSingleOrNull();
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
    String? taskId,
    required int durationSeconds,
    required bool completed,
  }) {
    return into(sessionHistoryTable).insert(
      SessionHistoryTableCompanion.insert(
        sessionType: sessionType,
        taskId: Value(taskId),
        durationSeconds: durationSeconds,
        completed: Value(completed),
      ),
    );
  }

  Future<void> incrementTaskProgress(String taskId) async {
    final task = await getTaskById(taskId);
    if (task == null) return;
    final nextCompleted = task.completedPomodoros + 1;
    final reachedEstimate = nextCompleted >= task.estimatedPomodoros;

    await (update(tasksTable)..where((t) => t.id.equals(taskId))).write(
      TasksTableCompanion(
        completedPomodoros: Value(nextCompleted),
        isCompleted: Value(reachedEstimate),
        isActive: Value(reachedEstimate ? false : task.isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<TasksTableData>> getReminderEnabledTasks() {
    return (select(tasksTable)
          ..where(
            (table) =>
                table.reminderEnabled.equals(true) &
                table.isCompleted.equals(false),
          ))
        .get();
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

  Stream<List<CatalogItemsTableData>> watchCatalogItemsByType(String type) {
    return (select(catalogItemsTable)
          ..where(
            (table) => table.type.equals(type) & table.isActive.equals(true),
          )
          ..orderBy([(table) => OrderingTerm(expression: table.sortOrder)]))
        .watch();
  }

  Future<List<CatalogItemsTableData>> getCatalogItemsByType(String type) {
    return (select(catalogItemsTable)
          ..where(
            (table) => table.type.equals(type) & table.isActive.equals(true),
          )
          ..orderBy([(table) => OrderingTerm(expression: table.sortOrder)]))
        .get();
  }

  Future<void> insertCatalogItemsIfMissing(
    List<CatalogItemsTableCompanion> items,
  ) async {
    if (items.isEmpty) return;
    await batch((b) {
      b.insertAll(catalogItemsTable, items, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<List<AchievementDefinitionsTableData>> getAchievementDefinitions() {
    return (select(achievementDefinitionsTable)
          ..where((table) => table.isActive.equals(true))
          ..orderBy([(table) => OrderingTerm(expression: table.sortOrder)]))
        .get();
  }

  Future<void> insertAchievementDefinitionsIfMissing(
    List<AchievementDefinitionsTableCompanion> definitions,
  ) async {
    if (definitions.isEmpty) return;
    await batch((b) {
      b.insertAll(
        achievementDefinitionsTable,
        definitions,
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  Future<List<SessionHistoryTableData>> getCompletedFocusSessions() {
    return (select(sessionHistoryTable)
          ..where(
            (table) =>
                table.completed.equals(true) &
                table.sessionType.equals('Focus'),
          )
          ..orderBy([(table) => OrderingTerm(expression: table.createdAt)]))
        .get();
  }

  Future<int> getCompletedTasksCount() async {
    final completedExpr = tasksTable.isCompleted.equals(true).count();
    final query = selectOnly(tasksTable)..addColumns([completedExpr]);
    final row = await query.getSingle();
    return row.read(completedExpr) ?? 0;
  }

  Future<int> getCompletedTasksOnTimeCount() async {
    final query =
        select(tasksTable)..where(
          (t) =>
              t.isCompleted.equals(true) &
              t.dueAt.isNotNull() &
              t.updatedAt.isSmallerOrEqual(t.dueAt),
        );
    final rows = await query.get();
    return rows.length;
  }

  Future<void> seedReferenceDataIfMissing() => _seedDefaultsIfMissing();

  Future<void> _seedDefaultsIfMissing() async {
    await insertCatalogItemsIfMissing(_defaultCatalogItems);
    await insertAchievementDefinitionsIfMissing(_defaultAchievementDefinitions);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'pomodoro_focus.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

final List<CatalogItemsTableCompanion> _defaultCatalogItems = [
  CatalogItemsTableCompanion.insert(
    id: 'mood_focused',
    type: 'mood',
    value: 'Focused',
    label: 'Focused',
    emoji: Value('🙂'),
    sortOrder: Value(1),
  ),
  CatalogItemsTableCompanion.insert(
    id: 'mood_calm',
    type: 'mood',
    value: 'Calm',
    label: 'Calm',
    emoji: Value('😌'),
    sortOrder: Value(2),
  ),
  CatalogItemsTableCompanion.insert(
    id: 'mood_neutral',
    type: 'mood',
    value: 'Neutral',
    label: 'Neutral',
    emoji: Value('😐'),
    sortOrder: Value(3),
  ),
  CatalogItemsTableCompanion.insert(
    id: 'mood_distracted',
    type: 'mood',
    value: 'Distracted',
    label: 'Distracted',
    emoji: Value('😫'),
    sortOrder: Value(4),
  ),
  CatalogItemsTableCompanion.insert(
    id: 'mood_tired',
    type: 'mood',
    value: 'Tired',
    label: 'Tired',
    emoji: Value('😴'),
    sortOrder: Value(5),
  ),
  CatalogItemsTableCompanion.insert(
    id: 'atmosphere_silent',
    type: 'atmosphere',
    value: 'Silent',
    label: 'Silent',
    emoji: Value('🤫'),
    description: Value('Pure quiet focus'),
    sortOrder: Value(1),
  ),
  CatalogItemsTableCompanion.insert(
    id: 'atmosphere_rain',
    type: 'atmosphere',
    value: 'Rain',
    label: 'Rain',
    emoji: Value('🌧️'),
    description: Value('Gentle rainfall sounds'),
    sortOrder: Value(2),
  ),
  CatalogItemsTableCompanion.insert(
    id: 'atmosphere_forest',
    type: 'atmosphere',
    value: 'Forest',
    label: 'Forest',
    emoji: Value('🌲'),
    description: Value('Birdsong & rustling leaves'),
    sortOrder: Value(3),
  ),
  CatalogItemsTableCompanion.insert(
    id: 'atmosphere_cafe',
    type: 'atmosphere',
    value: 'Cafe',
    label: 'Cafe',
    emoji: Value('☕'),
    description: Value('Soft ambient chatter'),
    sortOrder: Value(4),
  ),
  CatalogItemsTableCompanion.insert(
    id: 'sound_rain',
    type: 'sound_source',
    value: 'rain',
    label: 'Rain',
    iconToken: Value('water_drop_rounded'),
    sortOrder: Value(1),
  ),
  CatalogItemsTableCompanion.insert(
    id: 'sound_forest',
    type: 'sound_source',
    value: 'forest',
    label: 'Forest',
    iconToken: Value('forest_rounded'),
    sortOrder: Value(2),
  ),
  CatalogItemsTableCompanion.insert(
    id: 'sound_cafe',
    type: 'sound_source',
    value: 'cafe',
    label: 'Cafe',
    iconToken: Value('local_cafe_rounded'),
    sortOrder: Value(3),
  ),
  CatalogItemsTableCompanion.insert(
    id: 'sound_white_noise',
    type: 'sound_source',
    value: 'white_noise',
    label: 'White Noise',
    iconToken: Value('waves_rounded'),
    sortOrder: Value(4),
  ),
  CatalogItemsTableCompanion.insert(
    id: 'sound_birdsong',
    type: 'sound_source',
    value: 'birdsong',
    label: 'Birdsong',
    iconToken: Value('flutter_dash_rounded'),
    sortOrder: Value(5),
  ),
  CatalogItemsTableCompanion.insert(
    id: 'sound_fireplace',
    type: 'sound_source',
    value: 'fireplace',
    label: 'Fireplace',
    iconToken: Value('local_fire_department_rounded'),
    sortOrder: Value(6),
  ),
];

final List<AchievementDefinitionsTableCompanion>
_defaultAchievementDefinitions = [
  AchievementDefinitionsTableCompanion.insert(
    key: 'first_session',
    title: 'First Session',
    description: 'Completed your first Pomodoro!',
    metric: 'session_count',
    threshold: 1,
    iconToken: 'emoji_events',
    colorHex: 0xFFFFD700,
    sortOrder: Value(1),
  ),
  AchievementDefinitionsTableCompanion.insert(
    key: 'streak_7',
    title: '7-Day Streak',
    description: '7 consecutive days of focus',
    metric: 'streak_days',
    threshold: 7,
    iconToken: 'local_fire_department',
    colorHex: 0xFFFF6B35,
    sortOrder: Value(2),
  ),
  AchievementDefinitionsTableCompanion.insert(
    key: 'sessions_100',
    title: '100 Sessions',
    description: 'Completed 100 total sessions',
    metric: 'session_count',
    threshold: 100,
    iconToken: 'military_tech',
    colorHex: 0xFF7A9CC6,
    sortOrder: Value(3),
  ),
  AchievementDefinitionsTableCompanion.insert(
    key: 'streak_30',
    title: '30-Day Streak',
    description: '30 consecutive days of focus',
    metric: 'streak_days',
    threshold: 30,
    iconToken: 'diamond',
    colorHex: 0xFF9B59B6,
    sortOrder: Value(4),
  ),
];

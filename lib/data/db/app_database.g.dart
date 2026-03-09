// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TasksTableTable extends TasksTable
    with TableInfo<$TasksTableTable, TasksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderAtMeta = const VerificationMeta(
    'reminderAt',
  );
  @override
  late final GeneratedColumn<DateTime> reminderAt = GeneratedColumn<DateTime>(
    'reminder_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _estimatedPomodorosMeta =
      const VerificationMeta('estimatedPomodoros');
  @override
  late final GeneratedColumn<int> estimatedPomodoros = GeneratedColumn<int>(
    'estimated_pomodoros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _completedPomodorosMeta =
      const VerificationMeta('completedPomodoros');
  @override
  late final GeneratedColumn<int> completedPomodoros = GeneratedColumn<int>(
    'completed_pomodoros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    notes,
    dueAt,
    reminderAt,
    reminderEnabled,
    estimatedPomodoros,
    completedPomodoros,
    isCompleted,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TasksTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('reminder_at')) {
      context.handle(
        _reminderAtMeta,
        reminderAt.isAcceptableOrUnknown(data['reminder_at']!, _reminderAtMeta),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('estimated_pomodoros')) {
      context.handle(
        _estimatedPomodorosMeta,
        estimatedPomodoros.isAcceptableOrUnknown(
          data['estimated_pomodoros']!,
          _estimatedPomodorosMeta,
        ),
      );
    }
    if (data.containsKey('completed_pomodoros')) {
      context.handle(
        _completedPomodorosMeta,
        completedPomodoros.isAcceptableOrUnknown(
          data['completed_pomodoros']!,
          _completedPomodorosMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TasksTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TasksTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      reminderAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reminder_at'],
      ),
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      estimatedPomodoros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_pomodoros'],
      )!,
      completedPomodoros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_pomodoros'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TasksTableTable createAlias(String alias) {
    return $TasksTableTable(attachedDatabase, alias);
  }
}

class TasksTableData extends DataClass implements Insertable<TasksTableData> {
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
  final DateTime createdAt;
  final DateTime updatedAt;
  const TasksTableData({
    required this.id,
    required this.title,
    required this.notes,
    this.dueAt,
    this.reminderAt,
    required this.reminderEnabled,
    required this.estimatedPomodoros,
    required this.completedPomodoros,
    required this.isCompleted,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    if (!nullToAbsent || reminderAt != null) {
      map['reminder_at'] = Variable<DateTime>(reminderAt);
    }
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    map['estimated_pomodoros'] = Variable<int>(estimatedPomodoros);
    map['completed_pomodoros'] = Variable<int>(completedPomodoros);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TasksTableCompanion toCompanion(bool nullToAbsent) {
    return TasksTableCompanion(
      id: Value(id),
      title: Value(title),
      notes: Value(notes),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      reminderAt: reminderAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderAt),
      reminderEnabled: Value(reminderEnabled),
      estimatedPomodoros: Value(estimatedPomodoros),
      completedPomodoros: Value(completedPomodoros),
      isCompleted: Value(isCompleted),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TasksTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TasksTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String>(json['notes']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      reminderAt: serializer.fromJson<DateTime?>(json['reminderAt']),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      estimatedPomodoros: serializer.fromJson<int>(json['estimatedPomodoros']),
      completedPomodoros: serializer.fromJson<int>(json['completedPomodoros']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String>(notes),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'reminderAt': serializer.toJson<DateTime?>(reminderAt),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'estimatedPomodoros': serializer.toJson<int>(estimatedPomodoros),
      'completedPomodoros': serializer.toJson<int>(completedPomodoros),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TasksTableData copyWith({
    String? id,
    String? title,
    String? notes,
    Value<DateTime?> dueAt = const Value.absent(),
    Value<DateTime?> reminderAt = const Value.absent(),
    bool? reminderEnabled,
    int? estimatedPomodoros,
    int? completedPomodoros,
    bool? isCompleted,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TasksTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    notes: notes ?? this.notes,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    reminderAt: reminderAt.present ? reminderAt.value : this.reminderAt,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
    completedPomodoros: completedPomodoros ?? this.completedPomodoros,
    isCompleted: isCompleted ?? this.isCompleted,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TasksTableData copyWithCompanion(TasksTableCompanion data) {
    return TasksTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      reminderAt: data.reminderAt.present
          ? data.reminderAt.value
          : this.reminderAt,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      estimatedPomodoros: data.estimatedPomodoros.present
          ? data.estimatedPomodoros.value
          : this.estimatedPomodoros,
      completedPomodoros: data.completedPomodoros.present
          ? data.completedPomodoros.value
          : this.completedPomodoros,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TasksTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('dueAt: $dueAt, ')
          ..write('reminderAt: $reminderAt, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('estimatedPomodoros: $estimatedPomodoros, ')
          ..write('completedPomodoros: $completedPomodoros, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    notes,
    dueAt,
    reminderAt,
    reminderEnabled,
    estimatedPomodoros,
    completedPomodoros,
    isCompleted,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TasksTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.dueAt == this.dueAt &&
          other.reminderAt == this.reminderAt &&
          other.reminderEnabled == this.reminderEnabled &&
          other.estimatedPomodoros == this.estimatedPomodoros &&
          other.completedPomodoros == this.completedPomodoros &&
          other.isCompleted == this.isCompleted &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TasksTableCompanion extends UpdateCompanion<TasksTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> notes;
  final Value<DateTime?> dueAt;
  final Value<DateTime?> reminderAt;
  final Value<bool> reminderEnabled;
  final Value<int> estimatedPomodoros;
  final Value<int> completedPomodoros;
  final Value<bool> isCompleted;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TasksTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.reminderAt = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.estimatedPomodoros = const Value.absent(),
    this.completedPomodoros = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksTableCompanion.insert({
    required String id,
    required String title,
    this.notes = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.reminderAt = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.estimatedPomodoros = const Value.absent(),
    this.completedPomodoros = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<TasksTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? reminderAt,
    Expression<bool>? reminderEnabled,
    Expression<int>? estimatedPomodoros,
    Expression<int>? completedPomodoros,
    Expression<bool>? isCompleted,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (dueAt != null) 'due_at': dueAt,
      if (reminderAt != null) 'reminder_at': reminderAt,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (estimatedPomodoros != null) 'estimated_pomodoros': estimatedPomodoros,
      if (completedPomodoros != null) 'completed_pomodoros': completedPomodoros,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? notes,
    Value<DateTime?>? dueAt,
    Value<DateTime?>? reminderAt,
    Value<bool>? reminderEnabled,
    Value<int>? estimatedPomodoros,
    Value<int>? completedPomodoros,
    Value<bool>? isCompleted,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TasksTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueAt: dueAt ?? this.dueAt,
      reminderAt: reminderAt ?? this.reminderAt,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (reminderAt.present) {
      map['reminder_at'] = Variable<DateTime>(reminderAt.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (estimatedPomodoros.present) {
      map['estimated_pomodoros'] = Variable<int>(estimatedPomodoros.value);
    }
    if (completedPomodoros.present) {
      map['completed_pomodoros'] = Variable<int>(completedPomodoros.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('dueAt: $dueAt, ')
          ..write('reminderAt: $reminderAt, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('estimatedPomodoros: $estimatedPomodoros, ')
          ..write('completedPomodoros: $completedPomodoros, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionHistoryTableTable extends SessionHistoryTable
    with TableInfo<$SessionHistoryTableTable, SessionHistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionTypeMeta = const VerificationMeta(
    'sessionType',
  );
  @override
  late final GeneratedColumn<String> sessionType = GeneratedColumn<String>(
    'session_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionType,
    taskId,
    durationSeconds,
    completed,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_history_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionHistoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_type')) {
      context.handle(
        _sessionTypeMeta,
        sessionType.isAcceptableOrUnknown(
          data['session_type']!,
          _sessionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionTypeMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionHistoryTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionHistoryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_type'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SessionHistoryTableTable createAlias(String alias) {
    return $SessionHistoryTableTable(attachedDatabase, alias);
  }
}

class SessionHistoryTableData extends DataClass
    implements Insertable<SessionHistoryTableData> {
  final int id;
  final String sessionType;
  final String? taskId;
  final int durationSeconds;
  final bool completed;
  final DateTime createdAt;
  const SessionHistoryTableData({
    required this.id,
    required this.sessionType,
    this.taskId,
    required this.durationSeconds,
    required this.completed,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_type'] = Variable<String>(sessionType);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['completed'] = Variable<bool>(completed);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SessionHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return SessionHistoryTableCompanion(
      id: Value(id),
      sessionType: Value(sessionType),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
      durationSeconds: Value(durationSeconds),
      completed: Value(completed),
      createdAt: Value(createdAt),
    );
  }

  factory SessionHistoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionHistoryTableData(
      id: serializer.fromJson<int>(json['id']),
      sessionType: serializer.fromJson<String>(json['sessionType']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      completed: serializer.fromJson<bool>(json['completed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionType': serializer.toJson<String>(sessionType),
      'taskId': serializer.toJson<String?>(taskId),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'completed': serializer.toJson<bool>(completed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SessionHistoryTableData copyWith({
    int? id,
    String? sessionType,
    Value<String?> taskId = const Value.absent(),
    int? durationSeconds,
    bool? completed,
    DateTime? createdAt,
  }) => SessionHistoryTableData(
    id: id ?? this.id,
    sessionType: sessionType ?? this.sessionType,
    taskId: taskId.present ? taskId.value : this.taskId,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    completed: completed ?? this.completed,
    createdAt: createdAt ?? this.createdAt,
  );
  SessionHistoryTableData copyWithCompanion(SessionHistoryTableCompanion data) {
    return SessionHistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      sessionType: data.sessionType.present
          ? data.sessionType.value
          : this.sessionType,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      completed: data.completed.present ? data.completed.value : this.completed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionHistoryTableData(')
          ..write('id: $id, ')
          ..write('sessionType: $sessionType, ')
          ..write('taskId: $taskId, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completed: $completed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionType,
    taskId,
    durationSeconds,
    completed,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionHistoryTableData &&
          other.id == this.id &&
          other.sessionType == this.sessionType &&
          other.taskId == this.taskId &&
          other.durationSeconds == this.durationSeconds &&
          other.completed == this.completed &&
          other.createdAt == this.createdAt);
}

class SessionHistoryTableCompanion
    extends UpdateCompanion<SessionHistoryTableData> {
  final Value<int> id;
  final Value<String> sessionType;
  final Value<String?> taskId;
  final Value<int> durationSeconds;
  final Value<bool> completed;
  final Value<DateTime> createdAt;
  const SessionHistoryTableCompanion({
    this.id = const Value.absent(),
    this.sessionType = const Value.absent(),
    this.taskId = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.completed = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SessionHistoryTableCompanion.insert({
    this.id = const Value.absent(),
    required String sessionType,
    this.taskId = const Value.absent(),
    required int durationSeconds,
    this.completed = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : sessionType = Value(sessionType),
       durationSeconds = Value(durationSeconds);
  static Insertable<SessionHistoryTableData> custom({
    Expression<int>? id,
    Expression<String>? sessionType,
    Expression<String>? taskId,
    Expression<int>? durationSeconds,
    Expression<bool>? completed,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionType != null) 'session_type': sessionType,
      if (taskId != null) 'task_id': taskId,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (completed != null) 'completed': completed,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SessionHistoryTableCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionType,
    Value<String?>? taskId,
    Value<int>? durationSeconds,
    Value<bool>? completed,
    Value<DateTime>? createdAt,
  }) {
    return SessionHistoryTableCompanion(
      id: id ?? this.id,
      sessionType: sessionType ?? this.sessionType,
      taskId: taskId ?? this.taskId,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionType.present) {
      map['session_type'] = Variable<String>(sessionType.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('sessionType: $sessionType, ')
          ..write('taskId: $taskId, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completed: $completed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ReflectionsTableTable extends ReflectionsTable
    with TableInfo<$ReflectionsTableTable, ReflectionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReflectionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wentWellMeta = const VerificationMeta(
    'wentWell',
  );
  @override
  late final GeneratedColumn<String> wentWell = GeneratedColumn<String>(
    'went_well',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distractedByMeta = const VerificationMeta(
    'distractedBy',
  );
  @override
  late final GeneratedColumn<String> distractedBy = GeneratedColumn<String>(
    'distracted_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextFocusMeta = const VerificationMeta(
    'nextFocus',
  );
  @override
  late final GeneratedColumn<String> nextFocus = GeneratedColumn<String>(
    'next_focus',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mood,
    wentWell,
    distractedBy,
    nextFocus,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reflections_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReflectionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    if (data.containsKey('went_well')) {
      context.handle(
        _wentWellMeta,
        wentWell.isAcceptableOrUnknown(data['went_well']!, _wentWellMeta),
      );
    }
    if (data.containsKey('distracted_by')) {
      context.handle(
        _distractedByMeta,
        distractedBy.isAcceptableOrUnknown(
          data['distracted_by']!,
          _distractedByMeta,
        ),
      );
    }
    if (data.containsKey('next_focus')) {
      context.handle(
        _nextFocusMeta,
        nextFocus.isAcceptableOrUnknown(data['next_focus']!, _nextFocusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReflectionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReflectionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood'],
      ),
      wentWell: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}went_well'],
      ),
      distractedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}distracted_by'],
      ),
      nextFocus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}next_focus'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReflectionsTableTable createAlias(String alias) {
    return $ReflectionsTableTable(attachedDatabase, alias);
  }
}

class ReflectionsTableData extends DataClass
    implements Insertable<ReflectionsTableData> {
  final int id;
  final String? mood;
  final String? wentWell;
  final String? distractedBy;
  final String? nextFocus;
  final String? notes;
  final DateTime createdAt;
  const ReflectionsTableData({
    required this.id,
    this.mood,
    this.wentWell,
    this.distractedBy,
    this.nextFocus,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(mood);
    }
    if (!nullToAbsent || wentWell != null) {
      map['went_well'] = Variable<String>(wentWell);
    }
    if (!nullToAbsent || distractedBy != null) {
      map['distracted_by'] = Variable<String>(distractedBy);
    }
    if (!nullToAbsent || nextFocus != null) {
      map['next_focus'] = Variable<String>(nextFocus);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReflectionsTableCompanion toCompanion(bool nullToAbsent) {
    return ReflectionsTableCompanion(
      id: Value(id),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      wentWell: wentWell == null && nullToAbsent
          ? const Value.absent()
          : Value(wentWell),
      distractedBy: distractedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(distractedBy),
      nextFocus: nextFocus == null && nullToAbsent
          ? const Value.absent()
          : Value(nextFocus),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory ReflectionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReflectionsTableData(
      id: serializer.fromJson<int>(json['id']),
      mood: serializer.fromJson<String?>(json['mood']),
      wentWell: serializer.fromJson<String?>(json['wentWell']),
      distractedBy: serializer.fromJson<String?>(json['distractedBy']),
      nextFocus: serializer.fromJson<String?>(json['nextFocus']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mood': serializer.toJson<String?>(mood),
      'wentWell': serializer.toJson<String?>(wentWell),
      'distractedBy': serializer.toJson<String?>(distractedBy),
      'nextFocus': serializer.toJson<String?>(nextFocus),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReflectionsTableData copyWith({
    int? id,
    Value<String?> mood = const Value.absent(),
    Value<String?> wentWell = const Value.absent(),
    Value<String?> distractedBy = const Value.absent(),
    Value<String?> nextFocus = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => ReflectionsTableData(
    id: id ?? this.id,
    mood: mood.present ? mood.value : this.mood,
    wentWell: wentWell.present ? wentWell.value : this.wentWell,
    distractedBy: distractedBy.present ? distractedBy.value : this.distractedBy,
    nextFocus: nextFocus.present ? nextFocus.value : this.nextFocus,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  ReflectionsTableData copyWithCompanion(ReflectionsTableCompanion data) {
    return ReflectionsTableData(
      id: data.id.present ? data.id.value : this.id,
      mood: data.mood.present ? data.mood.value : this.mood,
      wentWell: data.wentWell.present ? data.wentWell.value : this.wentWell,
      distractedBy: data.distractedBy.present
          ? data.distractedBy.value
          : this.distractedBy,
      nextFocus: data.nextFocus.present ? data.nextFocus.value : this.nextFocus,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionsTableData(')
          ..write('id: $id, ')
          ..write('mood: $mood, ')
          ..write('wentWell: $wentWell, ')
          ..write('distractedBy: $distractedBy, ')
          ..write('nextFocus: $nextFocus, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mood,
    wentWell,
    distractedBy,
    nextFocus,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReflectionsTableData &&
          other.id == this.id &&
          other.mood == this.mood &&
          other.wentWell == this.wentWell &&
          other.distractedBy == this.distractedBy &&
          other.nextFocus == this.nextFocus &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class ReflectionsTableCompanion extends UpdateCompanion<ReflectionsTableData> {
  final Value<int> id;
  final Value<String?> mood;
  final Value<String?> wentWell;
  final Value<String?> distractedBy;
  final Value<String?> nextFocus;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const ReflectionsTableCompanion({
    this.id = const Value.absent(),
    this.mood = const Value.absent(),
    this.wentWell = const Value.absent(),
    this.distractedBy = const Value.absent(),
    this.nextFocus = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ReflectionsTableCompanion.insert({
    this.id = const Value.absent(),
    this.mood = const Value.absent(),
    this.wentWell = const Value.absent(),
    this.distractedBy = const Value.absent(),
    this.nextFocus = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<ReflectionsTableData> custom({
    Expression<int>? id,
    Expression<String>? mood,
    Expression<String>? wentWell,
    Expression<String>? distractedBy,
    Expression<String>? nextFocus,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mood != null) 'mood': mood,
      if (wentWell != null) 'went_well': wentWell,
      if (distractedBy != null) 'distracted_by': distractedBy,
      if (nextFocus != null) 'next_focus': nextFocus,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ReflectionsTableCompanion copyWith({
    Value<int>? id,
    Value<String?>? mood,
    Value<String?>? wentWell,
    Value<String?>? distractedBy,
    Value<String?>? nextFocus,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return ReflectionsTableCompanion(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      wentWell: wentWell ?? this.wentWell,
      distractedBy: distractedBy ?? this.distractedBy,
      nextFocus: nextFocus ?? this.nextFocus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (wentWell.present) {
      map['went_well'] = Variable<String>(wentWell.value);
    }
    if (distractedBy.present) {
      map['distracted_by'] = Variable<String>(distractedBy.value);
    }
    if (nextFocus.present) {
      map['next_focus'] = Variable<String>(nextFocus.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionsTableCompanion(')
          ..write('id: $id, ')
          ..write('mood: $mood, ')
          ..write('wentWell: $wentWell, ')
          ..write('distractedBy: $distractedBy, ')
          ..write('nextFocus: $nextFocus, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SoundMixesTableTable extends SoundMixesTable
    with TableInfo<$SoundMixesTableTable, SoundMixesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SoundMixesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelsJsonMeta = const VerificationMeta(
    'levelsJson',
  );
  @override
  late final GeneratedColumn<String> levelsJson = GeneratedColumn<String>(
    'levels_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    levelsJson,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sound_mixes_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SoundMixesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('levels_json')) {
      context.handle(
        _levelsJsonMeta,
        levelsJson.isAcceptableOrUnknown(data['levels_json']!, _levelsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_levelsJsonMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SoundMixesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SoundMixesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      levelsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}levels_json'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SoundMixesTableTable createAlias(String alias) {
    return $SoundMixesTableTable(attachedDatabase, alias);
  }
}

class SoundMixesTableData extends DataClass
    implements Insertable<SoundMixesTableData> {
  final String id;
  final String name;
  final String levelsJson;
  final bool isActive;
  final DateTime createdAt;
  const SoundMixesTableData({
    required this.id,
    required this.name,
    required this.levelsJson,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['levels_json'] = Variable<String>(levelsJson);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SoundMixesTableCompanion toCompanion(bool nullToAbsent) {
    return SoundMixesTableCompanion(
      id: Value(id),
      name: Value(name),
      levelsJson: Value(levelsJson),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory SoundMixesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SoundMixesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      levelsJson: serializer.fromJson<String>(json['levelsJson']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'levelsJson': serializer.toJson<String>(levelsJson),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SoundMixesTableData copyWith({
    String? id,
    String? name,
    String? levelsJson,
    bool? isActive,
    DateTime? createdAt,
  }) => SoundMixesTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    levelsJson: levelsJson ?? this.levelsJson,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  SoundMixesTableData copyWithCompanion(SoundMixesTableCompanion data) {
    return SoundMixesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      levelsJson: data.levelsJson.present
          ? data.levelsJson.value
          : this.levelsJson,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SoundMixesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('levelsJson: $levelsJson, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, levelsJson, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SoundMixesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.levelsJson == this.levelsJson &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class SoundMixesTableCompanion extends UpdateCompanion<SoundMixesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> levelsJson;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SoundMixesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.levelsJson = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SoundMixesTableCompanion.insert({
    required String id,
    required String name,
    required String levelsJson,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       levelsJson = Value(levelsJson);
  static Insertable<SoundMixesTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? levelsJson,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (levelsJson != null) 'levels_json': levelsJson,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SoundMixesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? levelsJson,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SoundMixesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      levelsJson: levelsJson ?? this.levelsJson,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (levelsJson.present) {
      map['levels_json'] = Variable<String>(levelsJson.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SoundMixesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('levelsJson: $levelsJson, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogItemsTableTable extends CatalogItemsTable
    with TableInfo<$CatalogItemsTableTable, CatalogItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconTokenMeta = const VerificationMeta(
    'iconToken',
  );
  @override
  late final GeneratedColumn<String> iconToken = GeneratedColumn<String>(
    'icon_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    value,
    label,
    description,
    emoji,
    iconToken,
    sortOrder,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_items_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('icon_token')) {
      context.handle(
        _iconTokenMeta,
        iconToken.isAcceptableOrUnknown(data['icon_token']!, _iconTokenMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogItemsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogItemsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      ),
      iconToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_token'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $CatalogItemsTableTable createAlias(String alias) {
    return $CatalogItemsTableTable(attachedDatabase, alias);
  }
}

class CatalogItemsTableData extends DataClass
    implements Insertable<CatalogItemsTableData> {
  final String id;
  final String type;
  final String value;
  final String label;
  final String? description;
  final String? emoji;
  final String? iconToken;
  final int sortOrder;
  final bool isActive;
  const CatalogItemsTableData({
    required this.id,
    required this.type,
    required this.value,
    required this.label,
    this.description,
    this.emoji,
    this.iconToken,
    required this.sortOrder,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['value'] = Variable<String>(value);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || emoji != null) {
      map['emoji'] = Variable<String>(emoji);
    }
    if (!nullToAbsent || iconToken != null) {
      map['icon_token'] = Variable<String>(iconToken);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CatalogItemsTableCompanion toCompanion(bool nullToAbsent) {
    return CatalogItemsTableCompanion(
      id: Value(id),
      type: Value(type),
      value: Value(value),
      label: Value(label),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      emoji: emoji == null && nullToAbsent
          ? const Value.absent()
          : Value(emoji),
      iconToken: iconToken == null && nullToAbsent
          ? const Value.absent()
          : Value(iconToken),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
    );
  }

  factory CatalogItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogItemsTableData(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      value: serializer.fromJson<String>(json['value']),
      label: serializer.fromJson<String>(json['label']),
      description: serializer.fromJson<String?>(json['description']),
      emoji: serializer.fromJson<String?>(json['emoji']),
      iconToken: serializer.fromJson<String?>(json['iconToken']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'value': serializer.toJson<String>(value),
      'label': serializer.toJson<String>(label),
      'description': serializer.toJson<String?>(description),
      'emoji': serializer.toJson<String?>(emoji),
      'iconToken': serializer.toJson<String?>(iconToken),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  CatalogItemsTableData copyWith({
    String? id,
    String? type,
    String? value,
    String? label,
    Value<String?> description = const Value.absent(),
    Value<String?> emoji = const Value.absent(),
    Value<String?> iconToken = const Value.absent(),
    int? sortOrder,
    bool? isActive,
  }) => CatalogItemsTableData(
    id: id ?? this.id,
    type: type ?? this.type,
    value: value ?? this.value,
    label: label ?? this.label,
    description: description.present ? description.value : this.description,
    emoji: emoji.present ? emoji.value : this.emoji,
    iconToken: iconToken.present ? iconToken.value : this.iconToken,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
  );
  CatalogItemsTableData copyWithCompanion(CatalogItemsTableCompanion data) {
    return CatalogItemsTableData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      value: data.value.present ? data.value.value : this.value,
      label: data.label.present ? data.label.value : this.label,
      description: data.description.present
          ? data.description.value
          : this.description,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      iconToken: data.iconToken.present ? data.iconToken.value : this.iconToken,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItemsTableData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('label: $label, ')
          ..write('description: $description, ')
          ..write('emoji: $emoji, ')
          ..write('iconToken: $iconToken, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    value,
    label,
    description,
    emoji,
    iconToken,
    sortOrder,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogItemsTableData &&
          other.id == this.id &&
          other.type == this.type &&
          other.value == this.value &&
          other.label == this.label &&
          other.description == this.description &&
          other.emoji == this.emoji &&
          other.iconToken == this.iconToken &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive);
}

class CatalogItemsTableCompanion
    extends UpdateCompanion<CatalogItemsTableData> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> value;
  final Value<String> label;
  final Value<String?> description;
  final Value<String?> emoji;
  final Value<String?> iconToken;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  final Value<int> rowid;
  const CatalogItemsTableCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.value = const Value.absent(),
    this.label = const Value.absent(),
    this.description = const Value.absent(),
    this.emoji = const Value.absent(),
    this.iconToken = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogItemsTableCompanion.insert({
    required String id,
    required String type,
    required String value,
    required String label,
    this.description = const Value.absent(),
    this.emoji = const Value.absent(),
    this.iconToken = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       value = Value(value),
       label = Value(label);
  static Insertable<CatalogItemsTableData> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? value,
    Expression<String>? label,
    Expression<String>? description,
    Expression<String>? emoji,
    Expression<String>? iconToken,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (value != null) 'value': value,
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      if (emoji != null) 'emoji': emoji,
      if (iconToken != null) 'icon_token': iconToken,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogItemsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? value,
    Value<String>? label,
    Value<String?>? description,
    Value<String?>? emoji,
    Value<String?>? iconToken,
    Value<int>? sortOrder,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return CatalogItemsTableCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      label: label ?? this.label,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      iconToken: iconToken ?? this.iconToken,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (iconToken.present) {
      map['icon_token'] = Variable<String>(iconToken.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('label: $label, ')
          ..write('description: $description, ')
          ..write('emoji: $emoji, ')
          ..write('iconToken: $iconToken, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AchievementDefinitionsTableTable extends AchievementDefinitionsTable
    with
        TableInfo<
          $AchievementDefinitionsTableTable,
          AchievementDefinitionsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementDefinitionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metricMeta = const VerificationMeta('metric');
  @override
  late final GeneratedColumn<String> metric = GeneratedColumn<String>(
    'metric',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thresholdMeta = const VerificationMeta(
    'threshold',
  );
  @override
  late final GeneratedColumn<int> threshold = GeneratedColumn<int>(
    'threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconTokenMeta = const VerificationMeta(
    'iconToken',
  );
  @override
  late final GeneratedColumn<String> iconToken = GeneratedColumn<String>(
    'icon_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<int> colorHex = GeneratedColumn<int>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    title,
    description,
    metric,
    threshold,
    iconToken,
    colorHex,
    sortOrder,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievement_definitions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AchievementDefinitionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('metric')) {
      context.handle(
        _metricMeta,
        metric.isAcceptableOrUnknown(data['metric']!, _metricMeta),
      );
    } else if (isInserting) {
      context.missing(_metricMeta);
    }
    if (data.containsKey('threshold')) {
      context.handle(
        _thresholdMeta,
        threshold.isAcceptableOrUnknown(data['threshold']!, _thresholdMeta),
      );
    } else if (isInserting) {
      context.missing(_thresholdMeta);
    }
    if (data.containsKey('icon_token')) {
      context.handle(
        _iconTokenMeta,
        iconToken.isAcceptableOrUnknown(data['icon_token']!, _iconTokenMeta),
      );
    } else if (isInserting) {
      context.missing(_iconTokenMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AchievementDefinitionsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AchievementDefinitionsTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      metric: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric'],
      )!,
      threshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}threshold'],
      )!,
      iconToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_token'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_hex'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $AchievementDefinitionsTableTable createAlias(String alias) {
    return $AchievementDefinitionsTableTable(attachedDatabase, alias);
  }
}

class AchievementDefinitionsTableData extends DataClass
    implements Insertable<AchievementDefinitionsTableData> {
  final String key;
  final String title;
  final String description;
  final String metric;
  final int threshold;
  final String iconToken;
  final int colorHex;
  final int sortOrder;
  final bool isActive;
  const AchievementDefinitionsTableData({
    required this.key,
    required this.title,
    required this.description,
    required this.metric,
    required this.threshold,
    required this.iconToken,
    required this.colorHex,
    required this.sortOrder,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['metric'] = Variable<String>(metric);
    map['threshold'] = Variable<int>(threshold);
    map['icon_token'] = Variable<String>(iconToken);
    map['color_hex'] = Variable<int>(colorHex);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  AchievementDefinitionsTableCompanion toCompanion(bool nullToAbsent) {
    return AchievementDefinitionsTableCompanion(
      key: Value(key),
      title: Value(title),
      description: Value(description),
      metric: Value(metric),
      threshold: Value(threshold),
      iconToken: Value(iconToken),
      colorHex: Value(colorHex),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
    );
  }

  factory AchievementDefinitionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AchievementDefinitionsTableData(
      key: serializer.fromJson<String>(json['key']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      metric: serializer.fromJson<String>(json['metric']),
      threshold: serializer.fromJson<int>(json['threshold']),
      iconToken: serializer.fromJson<String>(json['iconToken']),
      colorHex: serializer.fromJson<int>(json['colorHex']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'metric': serializer.toJson<String>(metric),
      'threshold': serializer.toJson<int>(threshold),
      'iconToken': serializer.toJson<String>(iconToken),
      'colorHex': serializer.toJson<int>(colorHex),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  AchievementDefinitionsTableData copyWith({
    String? key,
    String? title,
    String? description,
    String? metric,
    int? threshold,
    String? iconToken,
    int? colorHex,
    int? sortOrder,
    bool? isActive,
  }) => AchievementDefinitionsTableData(
    key: key ?? this.key,
    title: title ?? this.title,
    description: description ?? this.description,
    metric: metric ?? this.metric,
    threshold: threshold ?? this.threshold,
    iconToken: iconToken ?? this.iconToken,
    colorHex: colorHex ?? this.colorHex,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
  );
  AchievementDefinitionsTableData copyWithCompanion(
    AchievementDefinitionsTableCompanion data,
  ) {
    return AchievementDefinitionsTableData(
      key: data.key.present ? data.key.value : this.key,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      metric: data.metric.present ? data.metric.value : this.metric,
      threshold: data.threshold.present ? data.threshold.value : this.threshold,
      iconToken: data.iconToken.present ? data.iconToken.value : this.iconToken,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AchievementDefinitionsTableData(')
          ..write('key: $key, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('metric: $metric, ')
          ..write('threshold: $threshold, ')
          ..write('iconToken: $iconToken, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    key,
    title,
    description,
    metric,
    threshold,
    iconToken,
    colorHex,
    sortOrder,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AchievementDefinitionsTableData &&
          other.key == this.key &&
          other.title == this.title &&
          other.description == this.description &&
          other.metric == this.metric &&
          other.threshold == this.threshold &&
          other.iconToken == this.iconToken &&
          other.colorHex == this.colorHex &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive);
}

class AchievementDefinitionsTableCompanion
    extends UpdateCompanion<AchievementDefinitionsTableData> {
  final Value<String> key;
  final Value<String> title;
  final Value<String> description;
  final Value<String> metric;
  final Value<int> threshold;
  final Value<String> iconToken;
  final Value<int> colorHex;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  final Value<int> rowid;
  const AchievementDefinitionsTableCompanion({
    this.key = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.metric = const Value.absent(),
    this.threshold = const Value.absent(),
    this.iconToken = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementDefinitionsTableCompanion.insert({
    required String key,
    required String title,
    required String description,
    required String metric,
    required int threshold,
    required String iconToken,
    required int colorHex,
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       title = Value(title),
       description = Value(description),
       metric = Value(metric),
       threshold = Value(threshold),
       iconToken = Value(iconToken),
       colorHex = Value(colorHex);
  static Insertable<AchievementDefinitionsTableData> custom({
    Expression<String>? key,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? metric,
    Expression<int>? threshold,
    Expression<String>? iconToken,
    Expression<int>? colorHex,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (metric != null) 'metric': metric,
      if (threshold != null) 'threshold': threshold,
      if (iconToken != null) 'icon_token': iconToken,
      if (colorHex != null) 'color_hex': colorHex,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementDefinitionsTableCompanion copyWith({
    Value<String>? key,
    Value<String>? title,
    Value<String>? description,
    Value<String>? metric,
    Value<int>? threshold,
    Value<String>? iconToken,
    Value<int>? colorHex,
    Value<int>? sortOrder,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return AchievementDefinitionsTableCompanion(
      key: key ?? this.key,
      title: title ?? this.title,
      description: description ?? this.description,
      metric: metric ?? this.metric,
      threshold: threshold ?? this.threshold,
      iconToken: iconToken ?? this.iconToken,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (metric.present) {
      map['metric'] = Variable<String>(metric.value);
    }
    if (threshold.present) {
      map['threshold'] = Variable<int>(threshold.value);
    }
    if (iconToken.present) {
      map['icon_token'] = Variable<String>(iconToken.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<int>(colorHex.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementDefinitionsTableCompanion(')
          ..write('key: $key, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('metric: $metric, ')
          ..write('threshold: $threshold, ')
          ..write('iconToken: $iconToken, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTableTable tasksTable = $TasksTableTable(this);
  late final $SessionHistoryTableTable sessionHistoryTable =
      $SessionHistoryTableTable(this);
  late final $ReflectionsTableTable reflectionsTable = $ReflectionsTableTable(
    this,
  );
  late final $SoundMixesTableTable soundMixesTable = $SoundMixesTableTable(
    this,
  );
  late final $CatalogItemsTableTable catalogItemsTable =
      $CatalogItemsTableTable(this);
  late final $AchievementDefinitionsTableTable achievementDefinitionsTable =
      $AchievementDefinitionsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasksTable,
    sessionHistoryTable,
    reflectionsTable,
    soundMixesTable,
    catalogItemsTable,
    achievementDefinitionsTable,
  ];
}

typedef $$TasksTableTableCreateCompanionBuilder =
    TasksTableCompanion Function({
      required String id,
      required String title,
      Value<String> notes,
      Value<DateTime?> dueAt,
      Value<DateTime?> reminderAt,
      Value<bool> reminderEnabled,
      Value<int> estimatedPomodoros,
      Value<int> completedPomodoros,
      Value<bool> isCompleted,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$TasksTableTableUpdateCompanionBuilder =
    TasksTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> notes,
      Value<DateTime?> dueAt,
      Value<DateTime?> reminderAt,
      Value<bool> reminderEnabled,
      Value<int> estimatedPomodoros,
      Value<int> completedPomodoros,
      Value<bool> isCompleted,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$TasksTableTableFilterComposer
    extends Composer<_$AppDatabase, $TasksTableTable> {
  $$TasksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reminderAt => $composableBuilder(
    column: $table.reminderAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedPomodoros => $composableBuilder(
    column: $table.estimatedPomodoros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedPomodoros => $composableBuilder(
    column: $table.completedPomodoros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTableTable> {
  $$TasksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reminderAt => $composableBuilder(
    column: $table.reminderAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedPomodoros => $composableBuilder(
    column: $table.estimatedPomodoros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedPomodoros => $composableBuilder(
    column: $table.completedPomodoros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTableTable> {
  $$TasksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get reminderAt => $composableBuilder(
    column: $table.reminderAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedPomodoros => $composableBuilder(
    column: $table.estimatedPomodoros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedPomodoros => $composableBuilder(
    column: $table.completedPomodoros,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TasksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTableTable,
          TasksTableData,
          $$TasksTableTableFilterComposer,
          $$TasksTableTableOrderingComposer,
          $$TasksTableTableAnnotationComposer,
          $$TasksTableTableCreateCompanionBuilder,
          $$TasksTableTableUpdateCompanionBuilder,
          (
            TasksTableData,
            BaseReferences<_$AppDatabase, $TasksTableTable, TasksTableData>,
          ),
          TasksTableData,
          PrefetchHooks Function()
        > {
  $$TasksTableTableTableManager(_$AppDatabase db, $TasksTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> reminderAt = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int> estimatedPomodoros = const Value.absent(),
                Value<int> completedPomodoros = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksTableCompanion(
                id: id,
                title: title,
                notes: notes,
                dueAt: dueAt,
                reminderAt: reminderAt,
                reminderEnabled: reminderEnabled,
                estimatedPomodoros: estimatedPomodoros,
                completedPomodoros: completedPomodoros,
                isCompleted: isCompleted,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> notes = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<DateTime?> reminderAt = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int> estimatedPomodoros = const Value.absent(),
                Value<int> completedPomodoros = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksTableCompanion.insert(
                id: id,
                title: title,
                notes: notes,
                dueAt: dueAt,
                reminderAt: reminderAt,
                reminderEnabled: reminderEnabled,
                estimatedPomodoros: estimatedPomodoros,
                completedPomodoros: completedPomodoros,
                isCompleted: isCompleted,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTableTable,
      TasksTableData,
      $$TasksTableTableFilterComposer,
      $$TasksTableTableOrderingComposer,
      $$TasksTableTableAnnotationComposer,
      $$TasksTableTableCreateCompanionBuilder,
      $$TasksTableTableUpdateCompanionBuilder,
      (
        TasksTableData,
        BaseReferences<_$AppDatabase, $TasksTableTable, TasksTableData>,
      ),
      TasksTableData,
      PrefetchHooks Function()
    >;
typedef $$SessionHistoryTableTableCreateCompanionBuilder =
    SessionHistoryTableCompanion Function({
      Value<int> id,
      required String sessionType,
      Value<String?> taskId,
      required int durationSeconds,
      Value<bool> completed,
      Value<DateTime> createdAt,
    });
typedef $$SessionHistoryTableTableUpdateCompanionBuilder =
    SessionHistoryTableCompanion Function({
      Value<int> id,
      Value<String> sessionType,
      Value<String?> taskId,
      Value<int> durationSeconds,
      Value<bool> completed,
      Value<DateTime> createdAt,
    });

class $$SessionHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $SessionHistoryTableTable> {
  $$SessionHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionHistoryTableTable> {
  $$SessionHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionHistoryTableTable> {
  $$SessionHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionType => $composableBuilder(
    column: $table.sessionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SessionHistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionHistoryTableTable,
          SessionHistoryTableData,
          $$SessionHistoryTableTableFilterComposer,
          $$SessionHistoryTableTableOrderingComposer,
          $$SessionHistoryTableTableAnnotationComposer,
          $$SessionHistoryTableTableCreateCompanionBuilder,
          $$SessionHistoryTableTableUpdateCompanionBuilder,
          (
            SessionHistoryTableData,
            BaseReferences<
              _$AppDatabase,
              $SessionHistoryTableTable,
              SessionHistoryTableData
            >,
          ),
          SessionHistoryTableData,
          PrefetchHooks Function()
        > {
  $$SessionHistoryTableTableTableManager(
    _$AppDatabase db,
    $SessionHistoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionHistoryTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SessionHistoryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionType = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SessionHistoryTableCompanion(
                id: id,
                sessionType: sessionType,
                taskId: taskId,
                durationSeconds: durationSeconds,
                completed: completed,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionType,
                Value<String?> taskId = const Value.absent(),
                required int durationSeconds,
                Value<bool> completed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SessionHistoryTableCompanion.insert(
                id: id,
                sessionType: sessionType,
                taskId: taskId,
                durationSeconds: durationSeconds,
                completed: completed,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionHistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionHistoryTableTable,
      SessionHistoryTableData,
      $$SessionHistoryTableTableFilterComposer,
      $$SessionHistoryTableTableOrderingComposer,
      $$SessionHistoryTableTableAnnotationComposer,
      $$SessionHistoryTableTableCreateCompanionBuilder,
      $$SessionHistoryTableTableUpdateCompanionBuilder,
      (
        SessionHistoryTableData,
        BaseReferences<
          _$AppDatabase,
          $SessionHistoryTableTable,
          SessionHistoryTableData
        >,
      ),
      SessionHistoryTableData,
      PrefetchHooks Function()
    >;
typedef $$ReflectionsTableTableCreateCompanionBuilder =
    ReflectionsTableCompanion Function({
      Value<int> id,
      Value<String?> mood,
      Value<String?> wentWell,
      Value<String?> distractedBy,
      Value<String?> nextFocus,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });
typedef $$ReflectionsTableTableUpdateCompanionBuilder =
    ReflectionsTableCompanion Function({
      Value<int> id,
      Value<String?> mood,
      Value<String?> wentWell,
      Value<String?> distractedBy,
      Value<String?> nextFocus,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

class $$ReflectionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReflectionsTableTable> {
  $$ReflectionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wentWell => $composableBuilder(
    column: $table.wentWell,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get distractedBy => $composableBuilder(
    column: $table.distractedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextFocus => $composableBuilder(
    column: $table.nextFocus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReflectionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReflectionsTableTable> {
  $$ReflectionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wentWell => $composableBuilder(
    column: $table.wentWell,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distractedBy => $composableBuilder(
    column: $table.distractedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextFocus => $composableBuilder(
    column: $table.nextFocus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReflectionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReflectionsTableTable> {
  $$ReflectionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get wentWell =>
      $composableBuilder(column: $table.wentWell, builder: (column) => column);

  GeneratedColumn<String> get distractedBy => $composableBuilder(
    column: $table.distractedBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextFocus =>
      $composableBuilder(column: $table.nextFocus, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ReflectionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReflectionsTableTable,
          ReflectionsTableData,
          $$ReflectionsTableTableFilterComposer,
          $$ReflectionsTableTableOrderingComposer,
          $$ReflectionsTableTableAnnotationComposer,
          $$ReflectionsTableTableCreateCompanionBuilder,
          $$ReflectionsTableTableUpdateCompanionBuilder,
          (
            ReflectionsTableData,
            BaseReferences<
              _$AppDatabase,
              $ReflectionsTableTable,
              ReflectionsTableData
            >,
          ),
          ReflectionsTableData,
          PrefetchHooks Function()
        > {
  $$ReflectionsTableTableTableManager(
    _$AppDatabase db,
    $ReflectionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReflectionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReflectionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReflectionsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                Value<String?> wentWell = const Value.absent(),
                Value<String?> distractedBy = const Value.absent(),
                Value<String?> nextFocus = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ReflectionsTableCompanion(
                id: id,
                mood: mood,
                wentWell: wentWell,
                distractedBy: distractedBy,
                nextFocus: nextFocus,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                Value<String?> wentWell = const Value.absent(),
                Value<String?> distractedBy = const Value.absent(),
                Value<String?> nextFocus = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ReflectionsTableCompanion.insert(
                id: id,
                mood: mood,
                wentWell: wentWell,
                distractedBy: distractedBy,
                nextFocus: nextFocus,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReflectionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReflectionsTableTable,
      ReflectionsTableData,
      $$ReflectionsTableTableFilterComposer,
      $$ReflectionsTableTableOrderingComposer,
      $$ReflectionsTableTableAnnotationComposer,
      $$ReflectionsTableTableCreateCompanionBuilder,
      $$ReflectionsTableTableUpdateCompanionBuilder,
      (
        ReflectionsTableData,
        BaseReferences<
          _$AppDatabase,
          $ReflectionsTableTable,
          ReflectionsTableData
        >,
      ),
      ReflectionsTableData,
      PrefetchHooks Function()
    >;
typedef $$SoundMixesTableTableCreateCompanionBuilder =
    SoundMixesTableCompanion Function({
      required String id,
      required String name,
      required String levelsJson,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$SoundMixesTableTableUpdateCompanionBuilder =
    SoundMixesTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> levelsJson,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SoundMixesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SoundMixesTableTable> {
  $$SoundMixesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get levelsJson => $composableBuilder(
    column: $table.levelsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SoundMixesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SoundMixesTableTable> {
  $$SoundMixesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get levelsJson => $composableBuilder(
    column: $table.levelsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SoundMixesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SoundMixesTableTable> {
  $$SoundMixesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get levelsJson => $composableBuilder(
    column: $table.levelsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SoundMixesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SoundMixesTableTable,
          SoundMixesTableData,
          $$SoundMixesTableTableFilterComposer,
          $$SoundMixesTableTableOrderingComposer,
          $$SoundMixesTableTableAnnotationComposer,
          $$SoundMixesTableTableCreateCompanionBuilder,
          $$SoundMixesTableTableUpdateCompanionBuilder,
          (
            SoundMixesTableData,
            BaseReferences<
              _$AppDatabase,
              $SoundMixesTableTable,
              SoundMixesTableData
            >,
          ),
          SoundMixesTableData,
          PrefetchHooks Function()
        > {
  $$SoundMixesTableTableTableManager(
    _$AppDatabase db,
    $SoundMixesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SoundMixesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SoundMixesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SoundMixesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> levelsJson = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SoundMixesTableCompanion(
                id: id,
                name: name,
                levelsJson: levelsJson,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String levelsJson,
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SoundMixesTableCompanion.insert(
                id: id,
                name: name,
                levelsJson: levelsJson,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SoundMixesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SoundMixesTableTable,
      SoundMixesTableData,
      $$SoundMixesTableTableFilterComposer,
      $$SoundMixesTableTableOrderingComposer,
      $$SoundMixesTableTableAnnotationComposer,
      $$SoundMixesTableTableCreateCompanionBuilder,
      $$SoundMixesTableTableUpdateCompanionBuilder,
      (
        SoundMixesTableData,
        BaseReferences<
          _$AppDatabase,
          $SoundMixesTableTable,
          SoundMixesTableData
        >,
      ),
      SoundMixesTableData,
      PrefetchHooks Function()
    >;
typedef $$CatalogItemsTableTableCreateCompanionBuilder =
    CatalogItemsTableCompanion Function({
      required String id,
      required String type,
      required String value,
      required String label,
      Value<String?> description,
      Value<String?> emoji,
      Value<String?> iconToken,
      Value<int> sortOrder,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$CatalogItemsTableTableUpdateCompanionBuilder =
    CatalogItemsTableCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String> value,
      Value<String> label,
      Value<String?> description,
      Value<String?> emoji,
      Value<String?> iconToken,
      Value<int> sortOrder,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$CatalogItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogItemsTableTable> {
  $$CatalogItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconToken => $composableBuilder(
    column: $table.iconToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogItemsTableTable> {
  $$CatalogItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconToken => $composableBuilder(
    column: $table.iconToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogItemsTableTable> {
  $$CatalogItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get iconToken =>
      $composableBuilder(column: $table.iconToken, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$CatalogItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogItemsTableTable,
          CatalogItemsTableData,
          $$CatalogItemsTableTableFilterComposer,
          $$CatalogItemsTableTableOrderingComposer,
          $$CatalogItemsTableTableAnnotationComposer,
          $$CatalogItemsTableTableCreateCompanionBuilder,
          $$CatalogItemsTableTableUpdateCompanionBuilder,
          (
            CatalogItemsTableData,
            BaseReferences<
              _$AppDatabase,
              $CatalogItemsTableTable,
              CatalogItemsTableData
            >,
          ),
          CatalogItemsTableData,
          PrefetchHooks Function()
        > {
  $$CatalogItemsTableTableTableManager(
    _$AppDatabase db,
    $CatalogItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> emoji = const Value.absent(),
                Value<String?> iconToken = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogItemsTableCompanion(
                id: id,
                type: type,
                value: value,
                label: label,
                description: description,
                emoji: emoji,
                iconToken: iconToken,
                sortOrder: sortOrder,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String value,
                required String label,
                Value<String?> description = const Value.absent(),
                Value<String?> emoji = const Value.absent(),
                Value<String?> iconToken = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogItemsTableCompanion.insert(
                id: id,
                type: type,
                value: value,
                label: label,
                description: description,
                emoji: emoji,
                iconToken: iconToken,
                sortOrder: sortOrder,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogItemsTableTable,
      CatalogItemsTableData,
      $$CatalogItemsTableTableFilterComposer,
      $$CatalogItemsTableTableOrderingComposer,
      $$CatalogItemsTableTableAnnotationComposer,
      $$CatalogItemsTableTableCreateCompanionBuilder,
      $$CatalogItemsTableTableUpdateCompanionBuilder,
      (
        CatalogItemsTableData,
        BaseReferences<
          _$AppDatabase,
          $CatalogItemsTableTable,
          CatalogItemsTableData
        >,
      ),
      CatalogItemsTableData,
      PrefetchHooks Function()
    >;
typedef $$AchievementDefinitionsTableTableCreateCompanionBuilder =
    AchievementDefinitionsTableCompanion Function({
      required String key,
      required String title,
      required String description,
      required String metric,
      required int threshold,
      required String iconToken,
      required int colorHex,
      Value<int> sortOrder,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$AchievementDefinitionsTableTableUpdateCompanionBuilder =
    AchievementDefinitionsTableCompanion Function({
      Value<String> key,
      Value<String> title,
      Value<String> description,
      Value<String> metric,
      Value<int> threshold,
      Value<String> iconToken,
      Value<int> colorHex,
      Value<int> sortOrder,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$AchievementDefinitionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementDefinitionsTableTable> {
  $$AchievementDefinitionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metric => $composableBuilder(
    column: $table.metric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get threshold => $composableBuilder(
    column: $table.threshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconToken => $composableBuilder(
    column: $table.iconToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementDefinitionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementDefinitionsTableTable> {
  $$AchievementDefinitionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metric => $composableBuilder(
    column: $table.metric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get threshold => $composableBuilder(
    column: $table.threshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconToken => $composableBuilder(
    column: $table.iconToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementDefinitionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementDefinitionsTableTable> {
  $$AchievementDefinitionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metric =>
      $composableBuilder(column: $table.metric, builder: (column) => column);

  GeneratedColumn<int> get threshold =>
      $composableBuilder(column: $table.threshold, builder: (column) => column);

  GeneratedColumn<String> get iconToken =>
      $composableBuilder(column: $table.iconToken, builder: (column) => column);

  GeneratedColumn<int> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$AchievementDefinitionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AchievementDefinitionsTableTable,
          AchievementDefinitionsTableData,
          $$AchievementDefinitionsTableTableFilterComposer,
          $$AchievementDefinitionsTableTableOrderingComposer,
          $$AchievementDefinitionsTableTableAnnotationComposer,
          $$AchievementDefinitionsTableTableCreateCompanionBuilder,
          $$AchievementDefinitionsTableTableUpdateCompanionBuilder,
          (
            AchievementDefinitionsTableData,
            BaseReferences<
              _$AppDatabase,
              $AchievementDefinitionsTableTable,
              AchievementDefinitionsTableData
            >,
          ),
          AchievementDefinitionsTableData,
          PrefetchHooks Function()
        > {
  $$AchievementDefinitionsTableTableTableManager(
    _$AppDatabase db,
    $AchievementDefinitionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementDefinitionsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AchievementDefinitionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AchievementDefinitionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> metric = const Value.absent(),
                Value<int> threshold = const Value.absent(),
                Value<String> iconToken = const Value.absent(),
                Value<int> colorHex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementDefinitionsTableCompanion(
                key: key,
                title: title,
                description: description,
                metric: metric,
                threshold: threshold,
                iconToken: iconToken,
                colorHex: colorHex,
                sortOrder: sortOrder,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String title,
                required String description,
                required String metric,
                required int threshold,
                required String iconToken,
                required int colorHex,
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementDefinitionsTableCompanion.insert(
                key: key,
                title: title,
                description: description,
                metric: metric,
                threshold: threshold,
                iconToken: iconToken,
                colorHex: colorHex,
                sortOrder: sortOrder,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementDefinitionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AchievementDefinitionsTableTable,
      AchievementDefinitionsTableData,
      $$AchievementDefinitionsTableTableFilterComposer,
      $$AchievementDefinitionsTableTableOrderingComposer,
      $$AchievementDefinitionsTableTableAnnotationComposer,
      $$AchievementDefinitionsTableTableCreateCompanionBuilder,
      $$AchievementDefinitionsTableTableUpdateCompanionBuilder,
      (
        AchievementDefinitionsTableData,
        BaseReferences<
          _$AppDatabase,
          $AchievementDefinitionsTableTable,
          AchievementDefinitionsTableData
        >,
      ),
      AchievementDefinitionsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableTableManager get tasksTable =>
      $$TasksTableTableTableManager(_db, _db.tasksTable);
  $$SessionHistoryTableTableTableManager get sessionHistoryTable =>
      $$SessionHistoryTableTableTableManager(_db, _db.sessionHistoryTable);
  $$ReflectionsTableTableTableManager get reflectionsTable =>
      $$ReflectionsTableTableTableManager(_db, _db.reflectionsTable);
  $$SoundMixesTableTableTableManager get soundMixesTable =>
      $$SoundMixesTableTableTableManager(_db, _db.soundMixesTable);
  $$CatalogItemsTableTableTableManager get catalogItemsTable =>
      $$CatalogItemsTableTableTableManager(_db, _db.catalogItemsTable);
  $$AchievementDefinitionsTableTableTableManager
  get achievementDefinitionsTable =>
      $$AchievementDefinitionsTableTableTableManager(
        _db,
        _db.achievementDefinitionsTable,
      );
}

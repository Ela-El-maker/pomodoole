import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodorofocus/data/models/task_entity.dart';
import 'package:pomodorofocus/state/app/data_providers.dart';

final tasksStreamProvider = StreamProvider<List<TaskEntity>>((ref) {
  return ref
      .watch(tasksRepositoryProvider)
      .watchAll()
      .map((rows) => rows.map(TaskEntity.fromRow).toList());
});

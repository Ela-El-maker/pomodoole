import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodorofocus/data/db/app_database.dart';
import 'package:pomodorofocus/state/app/data_providers.dart';

final tasksStreamProvider = StreamProvider<List<TasksTableData>>((ref) {
  return ref.watch(tasksRepositoryProvider).watchAll();
});

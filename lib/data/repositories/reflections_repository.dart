import 'package:pomodorofocus/data/db/app_database.dart';

class ReflectionsRepository {
  ReflectionsRepository(this._database);

  final AppDatabase _database;

  Future<void> addReflection({
    String? mood,
    String? wentWell,
    String? distractedBy,
    String? nextFocus,
    String? notes,
  }) {
    return _database.saveReflection(
      mood: mood,
      wentWell: wentWell,
      distractedBy: distractedBy,
      nextFocus: nextFocus,
      notes: notes,
    );
  }
}

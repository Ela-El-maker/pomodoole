import 'package:pomodorofocus/data/db/app_database.dart';
import 'package:pomodorofocus/data/models/catalog_item.dart';

class CatalogRepository {
  CatalogRepository(this._database);

  final AppDatabase _database;

  Stream<List<CatalogItem>> watchByType(CatalogType type) {
    return _database
        .watchCatalogItemsByType(type.dbValue)
        .map(
          (rows) => rows
              .map(
                (row) => CatalogItem(
                  id: row.id,
                  type: catalogTypeFromDb(row.type),
                  value: row.value,
                  label: row.label,
                  description: row.description,
                  emoji: row.emoji,
                  iconToken: row.iconToken,
                  sortOrder: row.sortOrder,
                  isActive: row.isActive,
                ),
              )
              .toList(),
        );
  }

  Future<void> seedDefaultsIfMissing() async {
    await _database.seedReferenceDataIfMissing();
  }
}

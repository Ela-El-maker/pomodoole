enum CatalogType { mood, atmosphere, soundSource }

extension CatalogTypeX on CatalogType {
  String get dbValue {
    switch (this) {
      case CatalogType.mood:
        return 'mood';
      case CatalogType.atmosphere:
        return 'atmosphere';
      case CatalogType.soundSource:
        return 'sound_source';
    }
  }
}

CatalogType catalogTypeFromDb(String value) {
  switch (value) {
    case 'mood':
      return CatalogType.mood;
    case 'atmosphere':
      return CatalogType.atmosphere;
    case 'sound_source':
      return CatalogType.soundSource;
    default:
      return CatalogType.atmosphere;
  }
}

class CatalogItem {
  const CatalogItem({
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

  final String id;
  final CatalogType type;
  final String value;
  final String label;
  final String? description;
  final String? emoji;
  final String? iconToken;
  final int sortOrder;
  final bool isActive;
}

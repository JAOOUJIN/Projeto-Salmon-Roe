enum ProductCategory {
  temakis,
  combinados,
  hotrolls,
  sushis,
  sashimis,
  especiais,
  itensaparte,
}

extension ProductCategoryExtension on ProductCategory {
  String get displayName {
    switch (this) {
      case ProductCategory.temakis:
        return 'Temakis';
      case ProductCategory.combinados:
        return 'Combinados';
      case ProductCategory.hotrolls:
        return 'Hot rolls';
      case ProductCategory.sushis:
        return 'Sushis';
      case ProductCategory.sashimis:
        return 'Sashimis';
      case ProductCategory.especiais:
        return 'Especiais';
      case ProductCategory.itensaparte:
        return 'Itens a parte';
    }
  }

  static ProductCategory fromString(String value) {
    return ProductCategory.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => ProductCategory.temakis,
    );
  }
}
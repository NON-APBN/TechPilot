class CatalogProduct {
  final String name;
  final String brand;
  final String type; // 'laptop' or 'smartphone'
  final Map<String, dynamic> rawData;

  CatalogProduct({
    required this.name,
    required this.brand,
    required this.type,
    required this.rawData,
  });
}

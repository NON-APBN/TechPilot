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
    this.benchmarkScore,
  });

  final int? benchmarkScore;

  String get image {
    // Convert to Title Case to match new filename convention
    // e.g. "Asus ROG Strix" -> "Asus Rog Strix.jpg"
    
    // 1. Remove special chars
    String cleanName = name.replaceAll(RegExp(r'[\\/*?:"<>|]'), '');
    
    // 2. Split by space, capitalize first letter of each word, join
    String titleCaseName = cleanName.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
    
    return 'assets/images/$titleCaseName.jpg';
  }
}

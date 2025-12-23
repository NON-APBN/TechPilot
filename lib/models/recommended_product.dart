enum ProductType {
  laptop,
  smartphone,
}

class RecommendedProduct {
  final String productName;
  final int price;
  final int predictedPrice;
  final int predictedPriceMin;
  final int predictedPriceMax;
  final double valueScore;
  final double? cpuScore;
  final double? gpuScore;
  final double? chipsetScore;
  final ProductType type;
  final Map<String, dynamic> rawData;
  final String? imagePath;

  RecommendedProduct({
    required this.productName,
    required this.price,
    required this.predictedPrice,
    required this.predictedPriceMin,
    required this.predictedPriceMax,
    required this.valueScore,
    this.cpuScore,
    this.gpuScore,
    this.chipsetScore,
    required this.type,
    required this.rawData,
    this.imagePath,
  });

  factory RecommendedProduct.fromJson(Map<String, dynamic> json, ProductType type) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      }
      return 0;
    }

    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return RecommendedProduct(
      productName: json['product_name'] ?? 'Unknown Device',
      price: parseInt(json['price']),
      predictedPrice: parseInt(json['predicted_price']),
      predictedPriceMin: parseInt(json['predicted_price_min']),
      predictedPriceMax: parseInt(json['predicted_price_max']),
      valueScore: parseDouble(json['value_score'] ?? json['value_score_rp'] ?? json['worth_it_score']),
      cpuScore: json['cpu_score'] != null ? parseDouble(json['cpu_score']) : null,
      gpuScore: json['gpu_score'] != null ? parseDouble(json['gpu_score']) : null,
      chipsetScore: json['chipset_score'] != null ? parseDouble(json['chipset_score']) : null,
      type: type,
      rawData: json['raw_data'] ?? {},
      imagePath: json['image'],
    );
  }

  String get image {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return imagePath!;
    }
    
    // Fallback: Convert to Title Case to match new filename convention
    // e.g. "Asus ROG Strix" -> "Asus Rog Strix.jpg"
    
    // 1. Remove special chars
    String cleanName = productName.replaceAll(RegExp(r'[\\/*?:"<>|]'), '');
    
    // 2. Split by space, capitalize first letter of each word, join
    String titleCaseName = cleanName.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
    
    return 'assets/images/$titleCaseName.jpg';
  }

  String get specs {
    if (type == ProductType.laptop) {
      final ram = rawData['ram']?.toString() ?? '-';
      final storage = rawData['storage']?.toString() ?? '-';
      // Clean up strings if needed
      return '$ram | $storage'.replaceAll('SSD', '').replaceAll('NVMe', '').trim(); 
    } else {
      final ram = rawData['ram_capacity']?.toString() ?? rawData['ram']?.toString() ?? '-';
      final storage = rawData['internal_memory']?.toString() ?? rawData['storage']?.toString() ?? '-';
      return 'RAM $ram | $storage';
    }
  }
}


enum ProductType {
  laptop,
  smartphone,
}

class RecommendedProduct {
  final String productName;
  final int price;
  final int predictedPrice;
  final int valueScore;
  final double? cpuScore;
  final double? gpuScore;
  final double? chipsetScore;
  final ProductType type;

  RecommendedProduct({
    required this.productName,
    required this.price,
    required this.predictedPrice,
    required this.valueScore,
    this.cpuScore,
    this.gpuScore,
    this.chipsetScore,
    required this.type,
  });

  factory RecommendedProduct.fromJson(Map<String, dynamic> json, ProductType type) {
    return RecommendedProduct(
      productName: json['product_name'] ?? 'Unknown Device',
      price: (json['price'] as num? ?? 0).toInt(),
      predictedPrice: (json['predicted_price'] as num? ?? 0).toInt(),
      valueScore: (json['value_score_rp'] as num? ?? 0).toInt(),
      cpuScore: (json['cpu_score'] as num?)?.toDouble(),
      gpuScore: (json['gpu_score'] as num?)?.toDouble(),
      chipsetScore: (json['chipset_score'] as num?)?.toDouble(),
      type: type,
    );
  }

  // Helper to get the primary score for display
  double get primaryScore {
    if (type == ProductType.laptop) {
      return ((cpuScore ?? 0) + (gpuScore ?? 0));
    } else if (type == ProductType.smartphone) {
      return chipsetScore ?? 0;
    }
    return 0;
  }

  String get image {
    // Placeholder logic for images, you can refine this
    if (type == ProductType.laptop) {
      return 'assets/images/laptop_placeholder.png';
    } else {
      return 'assets/images/smartphone_placeholder.png';
    }
  }
}

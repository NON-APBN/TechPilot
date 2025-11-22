
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

  // Data mentah untuk dikirim ke API perbandingan
  final String? rawCpu;
  final String? rawGpu;
  final String? rawChipset;

  RecommendedProduct({
    required this.productName,
    required this.price,
    required this.predictedPrice,
    required this.valueScore,
    this.cpuScore,
    this.gpuScore,
    this.chipsetScore,
    required this.type,
    this.rawCpu,
    this.rawGpu,
    this.rawChipset,
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
      rawCpu: json['cpu'],
      rawGpu: json['gpu'],
      rawChipset: json['chipset'],
    );
  }

  String get image {
    if (type == ProductType.laptop) {
      return 'assets/images/laptop_placeholder.png';
    } else {
      return 'assets/images/smartphone_placeholder.png';
    }
  }
}

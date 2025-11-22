class ComparisonValue {
  final num value;
  final String status;
  final String reason;

  ComparisonValue({required this.value, required this.status, required this.reason});

  factory ComparisonValue.fromJson(Map<String, dynamic> json) {
    return ComparisonValue(
      value: json['value'] ?? 0,
      status: json['status'] ?? 'neutral',
      reason: json['reason'] ?? '',
    );
  }
}

class ComparedProduct {
  final String name;
  final String type;
  final ComparisonValue price;
  final ComparisonValue? cpuScore;
  final ComparisonValue? gpuScore;
  final ComparisonValue? chipsetScore;

  ComparedProduct({
    required this.name,
    required this.type,
    required this.price,
    this.cpuScore,
    this.gpuScore,
    this.chipsetScore,
  });

  factory ComparedProduct.fromJson(Map<String, dynamic> json) {
    return ComparedProduct(
      name: json['name'],
      type: json['type'],
      price: ComparisonValue.fromJson(json['price']),
      cpuScore: json.containsKey('cpu_score') ? ComparisonValue.fromJson(json['cpu_score']) : null,
      gpuScore: json.containsKey('gpu_score') ? ComparisonValue.fromJson(json['gpu_score']) : null,
      chipsetScore: json.containsKey('chipset_score') ? ComparisonValue.fromJson(json['chipset_score']) : null,
    );
  }
}

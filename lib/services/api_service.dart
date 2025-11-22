import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/compared_product.dart';
import '../models/recommended_product.dart';

class ApiService {
  final String _baseUrl = 'http://127.0.0.1:5000';

  Future<List<RecommendedProduct>> getRecommendations({
    required String type,
    required double minPrice,
    required double maxPrice,
  }) async {
    final url = Uri.parse('$_baseUrl/recommend');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'type': type,
          'min_price': minPrice.toInt(),
          'max_price': maxPrice.toInt(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        final productType = type == 'laptop' ? ProductType.laptop : ProductType.smartphone;
        return results.map((item) => RecommendedProduct.fromJson(item, productType)).toList();
      } else {
        debugPrint('Error from API: ${response.statusCode} - ${response.body}');
        throw Exception('Gagal mendapatkan rekomendasi dari server.');
      }
    } catch (e) {
      debugPrint('Error calling recommendation service: $e');
      throw Exception('Tidak dapat terhubung ke layanan rekomendasi.');
    }
  }

  Future<List<ComparedProduct>> compareProducts(List<RecommendedProduct> products) async {
    final url = Uri.parse('$_baseUrl/compare');
    try {
      final body = json.encode({
        'products': products.map((p) => {
          'name': p.productName,
          'type': p.type == ProductType.laptop ? 'laptop' : 'smartphone',
          'price': p.price,
          'cpu': p.rawCpu,
          'gpu': p.rawGpu,
          'chipset': p.rawChipset,
        }).toList(),
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((item) => ComparedProduct.fromJson(item)).toList();
      } else {
        debugPrint('Error from API: ${response.statusCode} - ${response.body}');
        throw Exception('Gagal mendapatkan perbandingan dari server.');
      }
    } catch (e) {
      debugPrint('Error calling compare service: $e');
      throw Exception('Tidak dapat terhubung ke layanan perbandingan.');
    }
  }
}

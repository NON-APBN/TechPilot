import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/recommended_product.dart';

class RecommendationService {
  Future<List<RecommendedProduct>> getRecommendations({
    required String type,
    required double minPrice,
    required double maxPrice,
  }) async {
    final url = Uri.parse('${AppConfig.apiUrl}/recommend');
    
    try {
      debugPrint('Fetching recommendations from $url with range: $minPrice - $maxPrice');
      
      final response = await http.post(
        url,
        headers: AppConfig.defaultHeaders,
        body: json.encode({
          'type': type,
          'min_price': minPrice.toInt(),
          'max_price': maxPrice.toInt(),
        }),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        final productType = type == 'laptop' ? ProductType.laptop : ProductType.smartphone;
        
        debugPrint('Recommendation success: ${results.length} items found.');
        
        return results.map((item) => RecommendedProduct.fromJson(item, productType)).toList();
      } else {
        debugPrint('Error form API: ${response.statusCode} - ${response.body}');
        throw Exception('Gagal mendapatkan rekomendasi. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception in recommendation service: $e');
      throw Exception('Gagal terhubung ke server: $e');
    }
  }
}

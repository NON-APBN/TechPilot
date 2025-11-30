import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/recommended_product.dart';

class RecommendationService {
  // TODO: Pindahkan URL ke file konfigurasi
  final String _baseUrl = 'https://techpilot-backend.onrender.com/api';

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
        // Log error atau tangani status code yang berbeda
        debugPrint('Error from API: ${response.statusCode} - ${response.body}');
        throw Exception('Gagal mendapatkan rekomendasi dari server.');
      }
    } catch (e) {
      // Tangani error koneksi atau lainnya
      debugPrint('Error calling recommendation service: $e');
      throw Exception('Tidak dapat terhubung ke layanan rekomendasi.');
    }
  }
}

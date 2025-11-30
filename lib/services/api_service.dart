import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/recommended_product.dart';
import '../models/compared_product.dart';
import '../models/catalog_product.dart';


// Kelas wrapper untuk hasil pencarian agar bisa membawa data paginasi
class SearchResult {
  final List<RecommendedProduct> products;
  final int currentPage;
  final int totalPages;

  SearchResult({required this.products, this.currentPage = 1, this.totalPages = 1});
}

class ApiService {
  String get _baseUrl {
    const String productionUrl = 'https://drappy-cat-techpilot-backend.hf.space/api';
    if (kIsWeb) return productionUrl;
    if (defaultTargetPlatform == TargetPlatform.android) return productionUrl;
    return productionUrl;
  }

  Future<SearchResult> searchProducts({
    required String type,
    required String query,
    int page = 1,
  }) async {
    final url = Uri.parse('$_baseUrl/search');
    try {
      final body = {'type': type, 'query': query, 'page': page, 'limit': 20};
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        ProductType determineProductType(item) {
            if (type == 'laptop') return ProductType.laptop;
            if (type == 'smartphone') return ProductType.smartphone;
            return item['chipset_score'] != null ? ProductType.smartphone : ProductType.laptop;
        }

        final products = results.map((item) {
            final productType = determineProductType(item);
            return RecommendedProduct.fromJson(item, productType);
        }).toList();
        
        return SearchResult(
          products: products,
          currentPage: data['page'] ?? 1,
          totalPages: data['total_pages'] ?? 1,
        );
      } else {
        throw Exception('Gagal melakukan pencarian. Status: ${response.statusCode}. Details: ${response.body}');
      }
    } catch (e) {
      debugPrint('Search Error: $e');
      throw Exception('Tidak dapat terhubung ke layanan pencarian: $e');
    }
  }

  Future<List<RecommendedProduct>> getRecommendations({
    required String type,
    double minPrice = 0,
    double maxPrice = 1000000000,
  }) async {
    final url = Uri.parse('$_baseUrl/recommend');
    try {
      final body = {
        'type': type,
        'min_price': minPrice,
        'max_price': maxPrice,
      };
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      
      debugPrint('Recommendation Response: ${response.body}');
      if (response.statusCode == 200) {
        dynamic data = json.decode(response.body);
        // Handle double-encoded JSON if necessary
        if (data is String) {
          debugPrint('Detected double-encoded JSON, decoding again...');
          data = json.decode(data);
        }
        final results = data['results'] as List;
        final productType = type == 'laptop' ? ProductType.laptop : ProductType.smartphone;
        return results.map((item) {
          try {
            return RecommendedProduct.fromJson(item, productType);
          } catch (e) {
            debugPrint('Error parsing item: $item');
            debugPrint('Error details: $e');
            rethrow;
          }
        }).toList();
      } else {
        throw Exception('Gagal mendapatkan rekomendasi. Status: ${response.statusCode}. Details: ${response.body}');
      }
    } catch (e) {
      debugPrint('Recommendation Error: $e');
      throw Exception('Tidak dapat terhubung ke layanan rekomendasi: $e');
    }
  }

  // --- PERBAIKAN: Mengembalikan metode compareProducts yang hilang ---
  Future<List<ComparedProduct>> compareProducts(List<CatalogProduct> products) async {
    final url = Uri.parse('$_baseUrl/compare'); // Asumsikan endpoint ini ada di backend
    try {
      final body = json.encode({
        'products': products.map((p) => p.toJsonForCompare()).toList(),
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
        throw Exception('Gagal mendapatkan perbandingan dari server. Status: ${response.statusCode}. Details: ${response.body}');
      }
    } catch (e) {
      throw Exception('Tidak dapat terhubung ke layanan perbandingan.');
    }
  }
}

// Helper extension untuk membersihkan logika di ApiService
extension CatalogProductExtension on CatalogProduct {
  Map<String, dynamic> toJsonForCompare() {
    // ... (logika ini mungkin perlu disesuaikan dengan model data Anda)
    return {
      'name': name,
      'type': type.toString().split('.').last,
      'price': rawData['price_idr'] ?? rawData['Estimated_Price'] ?? 0,
      'cpu': rawData['cpu'],
      'gpu': rawData['gpu'],
      'chipset': rawData['Platform_Chipset'],
    };
  }
}

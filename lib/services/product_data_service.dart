import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/catalog_product.dart';

class ProductDataService {
  static final ProductDataService _instance = ProductDataService._internal();
  factory ProductDataService() => _instance;
  ProductDataService._internal();

  final Map<String, int> _benchmarkCache = {};
  bool _benchmarksLoaded = false;

  Future<void> _loadBenchmarks() async {
    if (_benchmarksLoaded) return;

    final files = [
      'benchmark_chipset_mediatek.csv',
      'benchmark_chipset_snapdragon.csv',
      'benchmark_chipset_exynos.csv',
      'benchmark_chipset_kirin.csv',
      'benchmark_chipset_unisoc.csv',
      'benchmark_chipset_Apple.csv',
      'benchmark_prosesor_intel.csv',
      'benchmark_prosesor_amd.csv',
      'benchmark_prosesor_Apple_M_series.csv',
      'benchmark_prosesor_snapdragon.csv',
    ];

    for (final file in files) {
      try {
        final data = await rootBundle.loadString('backend/data/$file');
        final List<List<dynamic>> csvTable = const CsvToListConverter().convert(data);

        // Skip header
        for (var i = 1; i < csvTable.length; i++) {
          final row = csvTable[i];
          if (row.isEmpty) continue;

          final name = row[0].toString().trim().toLowerCase();
          int score = 0;

          // Try to find a valid score in subsequent columns
          for (var j = 1; j < row.length; j++) {
            final val = row[j];
            if (val is int) {
              score = val;
              if (score > 1000) break; 
            } else if (val is String) {
               final cleanVal = val.replaceAll(RegExp(r'[^0-9]'), '');
               if (cleanVal.isNotEmpty) {
                 final parsed = int.tryParse(cleanVal);
                 if (parsed != null && parsed > 1000) {
                   score = parsed;
                   break;
                 }
               }
            }
          }

          if (score > 0) {
            _benchmarkCache[name] = score;
          }
        }
      } catch (e) {
        debugPrint('Error loading benchmark file $file: $e');
      }
    }
    _benchmarksLoaded = true;
  }

  Future<List<CatalogProduct>> getAllProducts(String type) async {
    await _loadBenchmarks();
    final String fileName = type == 'laptop' 
        ? 'laptops_all_indonesia_fixed_v7.csv' 
        : 'ALL_SMARTPHONES_MERGED.csv';

    try {
      final String data = await rootBundle.loadString('backend/data/$fileName');
      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(data);

      if (csvTable.isEmpty) return [];

      final headers = csvTable[0].map((e) => e.toString()).toList();
      final products = <CatalogProduct>[];

      for (var i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        if (row.length != headers.length) continue;

        final Map<String, dynamic> rawData = {};
        for (var j = 0; j < headers.length; j++) {
          rawData[headers[j]] = row[j];
        }

        // Extract basic info
        String name = '';
        String brand = '';
        String cpuOrChipset = '';

        if (type == 'laptop') {
          name = rawData['model']?.toString() ?? 'Unknown';
          brand = rawData['brand']?.toString() ?? 'Unknown';
          cpuOrChipset = rawData['cpu']?.toString() ?? '';
        } else {
          name = rawData['Device Name']?.toString() ?? 'Unknown';
          brand = rawData['Brand']?.toString() ?? 'Unknown';
          cpuOrChipset = rawData['Platform_Chipset']?.toString() ?? '';
        }

        // Find benchmark score
        int? score;
        final cpuLower = cpuOrChipset.toLowerCase();
        
        if (_benchmarkCache.containsKey(cpuLower)) {
          score = _benchmarkCache[cpuLower];
        } else {
          String bestMatchKey = '';
          for (final key in _benchmarkCache.keys) {
            if (cpuLower.contains(key)) {
              if (key.length > bestMatchKey.length) {
                bestMatchKey = key;
              }
            }
          }
          if (bestMatchKey.isNotEmpty) {
            score = _benchmarkCache[bestMatchKey];
          }
        }
        
        if (score != null) {
          rawData['benchmark_score'] = score;
        }

        products.add(CatalogProduct(
          name: name,
          brand: brand,
          type: type,
          rawData: rawData,
          benchmarkScore: score,
        ));
      }

      return products;
    } catch (e) {
      debugPrint('Error loading products: $e');
      throw Exception('Failed to load products: $e');
    }
  }
}

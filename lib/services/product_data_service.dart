import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/catalog_product.dart';

class ProductDataService {
  static final ProductDataService _instance = ProductDataService._internal();
  factory ProductDataService() => _instance;
  ProductDataService._internal();

  List<CatalogProduct> _allProducts = [];
  bool _isInitialized = false;

  Future<void> _initialize() async {
    if (_isInitialized) return;

    // Load and parse laptop data
    final laptopData = await rootBundle.loadString('assets/data/laptops_all_indonesia_fixed_v7.csv');
    final laptopRows = const CsvToListConverter().convert(laptopData);
    if (laptopRows.isNotEmpty) {
      final header = laptopRows[0].map((e) => e.toString()).toList();
      final modelIndex = header.indexOf('model');
      if (modelIndex != -1) {
        for (var i = 1; i < laptopRows.length; i++) {
          final name = laptopRows[i][modelIndex].toString();
          if (name.isNotEmpty) {
            final brand = name.split(' ')[0];
            _allProducts.add(CatalogProduct(
              name: name,
              brand: brand,
              type: 'laptop',
              rawData: Map.fromIterables(header, laptopRows[i]),
            ));
          }
        }
      }
    }

    // Load and parse smartphone data
    final smartphoneData = await rootBundle.loadString('assets/data/ALL_SMARTPHONES_MERGED.csv');
    final smartphoneRows = const CsvToListConverter().convert(smartphoneData);
    if (smartphoneRows.isNotEmpty) {
      final header = smartphoneRows[0].map((e) => e.toString()).toList();
      final nameIndex = header.indexOf('Device Name');
      final brandIndex = header.indexOf('Brand');
      if (nameIndex != -1 && brandIndex != -1) {
        for (var i = 1; i < smartphoneRows.length; i++) {
          final name = smartphoneRows[i][nameIndex].toString();
          final brand = smartphoneRows[i][brandIndex].toString();
          if (name.isNotEmpty && brand.isNotEmpty) {
            _allProducts.add(CatalogProduct(
              name: name,
              brand: brand,
              type: 'smartphone',
              rawData: Map.fromIterables(header, smartphoneRows[i]),
            ));
          }
        }
      }
    }
    _isInitialized = true;
  }

  Future<List<String>> getBrands(String type) async {
    await _initialize();
    return _allProducts
        .where((p) => p.type == type)
        .map((p) => p.brand)
        .toSet()
        .toList()
      ..sort();
  }

  Future<List<CatalogProduct>> getProductsByBrand(String type, String brand) async {
    await _initialize();
    return _allProducts
        .where((p) => p.type == type && p.brand == brand)
        .toList();
  }
}

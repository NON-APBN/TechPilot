import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/catalog_product.dart';
import '../services/product_data_service.dart';

import 'compare_state.dart';

class CompareCubit extends Cubit<CompareState> {
  final ProductDataService _productDataService = ProductDataService();

  CompareCubit() : super(const CompareState()) {
    // Secara default, muat data smartphone
    changeProductType('smartphone');
  }

  Future<void> changeProductType(String type) async {
    emit(state.copyWith(
      status: CompareStatus.loading,
      selectedType: type,
      selectedProducts: const [null, null], // Reset pilihan saat ganti tipe
    ));
    
    try {
      final products = await _productDataService.getAllProducts(type);
      emit(state.copyWith(
        status: CompareStatus.loaded,
        availableProducts: products,
      ));
    } catch (e) {
      emit(state.copyWith(status: CompareStatus.error, errorMessage: e.toString()));
    }
  }

  void addProductSlot() {
    if (state.selectedProducts.length < 4) { // Limit 4 produk sesuai request user (3-4)
      final newSelection = List<CatalogProduct?>.from(state.selectedProducts)..add(null);
      emit(state.copyWith(selectedProducts: newSelection));
    }
  }

  void onProductSelected(int index, CatalogProduct? product) {
    // Pastikan index valid
    if (index < 0 || index >= state.selectedProducts.length) return;

    final newSelection = List<CatalogProduct?>.from(state.selectedProducts);
    newSelection[index] = product;
    
    emit(state.copyWith(selectedProducts: newSelection));
  }
}

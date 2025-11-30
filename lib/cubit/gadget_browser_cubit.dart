import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/recommended_product.dart';
import '../services/api_service.dart';

part 'gadget_browser_state.dart';

class GadgetBrowserCubit extends Cubit<GadgetBrowserState> {
  final ApiService _apiService = ApiService();
  Timer? _debounce;

  GadgetBrowserCubit() : super(const GadgetBrowserState()) {
    // Memuat halaman pertama saat cubit dibuat
    _performSearch();
  }

  void setType(String type) {
    // Saat tipe berubah, reset ke halaman 1 dan lakukan pencarian baru
    emit(state.copyWith(type: type, currentPage: 1, totalPages: 1));
    _performSearch();
  }

  void setQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // Reset ke halaman 1 setiap kali query baru diketik
    emit(state.copyWith(q: query, currentPage: 1, totalPages: 1));
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  void goToPage(int page) {
    // Ganti halaman dan lakukan pencarian untuk halaman tersebut
    emit(state.copyWith(currentPage: page));
    _performSearch();
  }

  Future<void> _performSearch() async {
    emit(state.copyWith(status: GadgetBrowserStatus.loading));
    try {
      // Menggunakan searchProducts dari ApiService yang sekarang mendukung paginasi
      final response = await _apiService.searchProducts(
        type: state.type,
        query: state.q,
        page: state.currentPage,
      );
      
      emit(state.copyWith(
        status: GadgetBrowserStatus.success,
        items: response.products,
        totalPages: response.totalPages,
        currentPage: response.currentPage,
      ));
    } catch (e) {
      emit(state.copyWith(status: GadgetBrowserStatus.error, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

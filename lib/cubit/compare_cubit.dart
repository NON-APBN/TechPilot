import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/compared_product.dart';
import '../models/recommended_product.dart';
import '../services/api_service.dart';

part 'compare_state.dart';

class CompareCubit extends Cubit<CompareState> {
  final ApiService _apiService = ApiService();
  final List<RecommendedProduct> productsToCompare;

  CompareCubit({required this.productsToCompare}) : super(const CompareState()) {
    performComparison();
  }

  Future<void> performComparison() async {
    emit(state.copyWith(status: ComparisonStatus.loading));
    try {
      final results = await _apiService.compareProducts(productsToCompare);
      emit(state.copyWith(status: ComparisonStatus.loaded, results: results));
    } catch (e) {
      emit(state.copyWith(status: ComparisonStatus.error, errorMessage: e.toString()));
    }
  }
}

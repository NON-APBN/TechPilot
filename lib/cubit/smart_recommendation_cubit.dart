import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/recommended_product.dart';
import '../services/api_service.dart';

part 'smart_recommendation_state.dart';

class SmartRecommendationCubit extends Cubit<SmartRecommendationState> {
  final ApiService _apiService = ApiService();

  SmartRecommendationCubit() : super(const SmartRecommendationState());

  void setType(String type) {
    emit(state.copyWith(type: type, status: RecommendationStatus.initial, results: [], comparisonSelection: {}));
  }

  void setTargetBudget(double budget) {
    emit(state.copyWith(targetBudget: budget, status: RecommendationStatus.initial));
  }

  Future<void> fetchRecommendations() async {
    emit(state.copyWith(status: RecommendationStatus.loading, errorMessage: null, comparisonSelection: {}));
    
    // Hitung rentang harga secara otomatis di sekitar target
    final targetPrice = state.targetBudget * 1000000;
    final minPrice = targetPrice * 0.8; // -20% dari target
    final maxPrice = targetPrice * 1.2; // +20% dari target

    try {
      final results = await _apiService.getRecommendations(
        type: state.type,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      // Backend sudah mengurutkan berdasarkan value_score, jadi frontend tinggal menampilkan
      emit(state.copyWith(status: RecommendationStatus.success, results: results));
    } catch (e) {
      emit(state.copyWith(status: RecommendationStatus.failure, errorMessage: e.toString()));
    }
  }
  
  void toggleCompareSelection(RecommendedProduct product) {
    final newSelection = Set<RecommendedProduct>.from(state.comparisonSelection);
    if (newSelection.contains(product)) {
      newSelection.remove(product);
    } else {
      newSelection.add(product);
    }
    emit(state.copyWith(comparisonSelection: newSelection));
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/recommended_product.dart';
import '../services/recommendation_service.dart';

part 'smart_recommendation_state.dart';

class SmartRecommendationCubit extends Cubit<SmartRecommendationState> {
  final RecommendationService _recommendationService = RecommendationService();

  SmartRecommendationCubit() : super(const SmartRecommendationState());

  void setType(String type) {
    emit(state.copyWith(type: type, status: RecommendationStatus.initial, results: [], comparisonSelection: {}));
  }

  void setBudgetRange(double min, double max) {
    emit(state.copyWith(minBudget: min, maxBudget: max, status: RecommendationStatus.initial));
  }

  Future<void> fetchRecommendations() async {
    emit(state.copyWith(status: RecommendationStatus.loading, errorMessage: null, comparisonSelection: {}));
    try {
      final results = await _recommendationService.getRecommendations(
        type: state.type,
        minPrice: state.minBudget * 1000000,
        maxPrice: state.maxBudget * 1000000,
      );
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

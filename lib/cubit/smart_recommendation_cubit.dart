import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/recommended_product.dart';
import '../services/api_service.dart';

part 'smart_recommendation_state.dart';

class SmartRecommendationCubit extends Cubit<SmartRecommendationState> {
  final ApiService _apiService = ApiService();

  SmartRecommendationCubit() : super(const SmartRecommendationState());

  void setType(String type) {
    emit(state.copyWith(type: type, status: RecommendationStatus.initial, results: []));
  }

  void setTargetBudget(double budget) {
    emit(state.copyWith(targetBudget: budget, status: RecommendationStatus.initial));
  }

  Future<void> fetchRecommendations() async {
    emit(state.copyWith(status: RecommendationStatus.loading, errorMessage: null));
    
    final targetPrice = state.targetBudget * 1000000;
    final minPrice = targetPrice * 0.8;
    final maxPrice = targetPrice * 1.2;

    try {
      final results = await _apiService.getRecommendations(
        type: state.type,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      emit(state.copyWith(status: RecommendationStatus.success, results: results));
    } catch (e) {
      emit(state.copyWith(status: RecommendationStatus.failure, errorMessage: e.toString()));
    }
  }
}

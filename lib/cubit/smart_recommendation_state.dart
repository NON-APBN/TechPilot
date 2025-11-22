part of 'smart_recommendation_cubit.dart';

enum RecommendationStatus { initial, loading, success, failure }

class SmartRecommendationState extends Equatable {
  final String type;
  final double targetBudget; // Mengganti min/max dengan satu target
  final RecommendationStatus status;
  final List<RecommendedProduct> results;
  final String? errorMessage;
  final Set<RecommendedProduct> comparisonSelection;

  const SmartRecommendationState({
    this.type = 'laptop',
    this.targetBudget = 5.0, // Default target 5 juta
    this.status = RecommendationStatus.initial,
    this.results = const [],
    this.errorMessage,
    this.comparisonSelection = const {},
  });

  SmartRecommendationState copyWith({
    String? type,
    double? targetBudget,
    RecommendationStatus? status,
    List<RecommendedProduct>? results,
    String? errorMessage,
    Set<RecommendedProduct>? comparisonSelection,
  }) {
    return SmartRecommendationState(
      type: type ?? this.type,
      targetBudget: targetBudget ?? this.targetBudget,
      status: status ?? this.status,
      results: results ?? this.results,
      errorMessage: errorMessage ?? this.errorMessage,
      comparisonSelection: comparisonSelection ?? this.comparisonSelection,
    );
  }

  @override
  List<Object?> get props => [type, targetBudget, status, results, errorMessage, comparisonSelection];
}

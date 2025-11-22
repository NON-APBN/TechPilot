part of 'smart_recommendation_cubit.dart';

enum RecommendationStatus { initial, loading, success, failure }

class SmartRecommendationState extends Equatable {
  final String type;
  final double minBudget;
  final double maxBudget;
  final RecommendationStatus status;
  final List<RecommendedProduct> results;
  final String? errorMessage;
  final Set<RecommendedProduct> comparisonSelection;

  const SmartRecommendationState({
    this.type = 'laptop',
    this.minBudget = 1.0,
    this.maxBudget = 10.0,
    this.status = RecommendationStatus.initial,
    this.results = const [],
    this.errorMessage,
    this.comparisonSelection = const {},
  });

  SmartRecommendationState copyWith({
    String? type,
    double? minBudget,
    double? maxBudget,
    RecommendationStatus? status,
    List<RecommendedProduct>? results,
    String? errorMessage,
    Set<RecommendedProduct>? comparisonSelection,
  }) {
    return SmartRecommendationState(
      type: type ?? this.type,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      status: status ?? this.status,
      results: results ?? this.results,
      errorMessage: errorMessage ?? this.errorMessage,
      comparisonSelection: comparisonSelection ?? this.comparisonSelection,
    );
  }

  @override
  List<Object?> get props => [type, minBudget, maxBudget, status, results, errorMessage, comparisonSelection];
}

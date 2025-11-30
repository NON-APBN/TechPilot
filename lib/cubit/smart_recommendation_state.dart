part of 'smart_recommendation_cubit.dart';

enum RecommendationStatus { initial, loading, success, failure }

class SmartRecommendationState extends Equatable {
  final String type;
  final double targetBudget;
  final RecommendationStatus status;
  final List<RecommendedProduct> results;
  final String? errorMessage;

  const SmartRecommendationState({
    this.type = 'laptop',
    this.targetBudget = 5.0,
    this.status = RecommendationStatus.initial,
    this.results = const [],
    this.errorMessage,
  });

  SmartRecommendationState copyWith({
    String? type,
    double? targetBudget,
    RecommendationStatus? status,
    List<RecommendedProduct>? results,
    String? errorMessage,
  }) {
    return SmartRecommendationState(
      type: type ?? this.type,
      targetBudget: targetBudget ?? this.targetBudget,
      status: status ?? this.status,
      results: results ?? this.results,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [type, targetBudget, status, results, errorMessage];
}

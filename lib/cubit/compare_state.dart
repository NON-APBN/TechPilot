part of 'compare_cubit.dart';

enum ComparisonStatus { loading, loaded, error }

class CompareState extends Equatable {
  final ComparisonStatus status;
  final List<ComparedProduct> results;
  final String? errorMessage;

  const CompareState({
    this.status = ComparisonStatus.loading,
    this.results = const [],
    this.errorMessage,
  });

  CompareState copyWith({
    ComparisonStatus? status,
    List<ComparedProduct>? results,
    String? errorMessage,
  }) {
    return CompareState(
      status: status ?? this.status,
      results: results ?? this.results,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, results, errorMessage];
}

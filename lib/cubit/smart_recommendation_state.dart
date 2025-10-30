
part of 'smart_recommendation_cubit.dart';

class SmartRecommendationState extends Equatable {
  final String type;
  final double budget;
  final Set<String> needs;
  final List<Gadget> results;
  // Menyimpan gadget beserta tag-nya agar tidak perlu dihitung ulang
  final List<_WithTags> allGadgetsWithTags;

  const SmartRecommendationState({
    this.type = 'smartphone',
    this.budget = 8.0,
    this.needs = const {'kamera'},
    this.results = const [],
    this.allGadgetsWithTags = const [],
  });

  SmartRecommendationState copyWith({
    String? type,
    double? budget,
    Set<String>? needs,
    List<Gadget>? results,
    List<_WithTags>? allGadgetsWithTags,
  }) {
    return SmartRecommendationState(
      type: type ?? this.type,
      budget: budget ?? this.budget,
      needs: needs ?? this.needs,
      results: results ?? this.results,
      allGadgetsWithTags: allGadgetsWithTags ?? this.allGadgetsWithTags,
    );
  }

  @override
  List<Object> get props => [type, budget, needs, results, allGadgetsWithTags];
}

// Helper class ini kita pindahkan ke sini agar bisa diakses oleh Cubit
class _WithTags {
  final Gadget g;
  final Set<String> tags;
  _WithTags(this.g, this.tags);
}

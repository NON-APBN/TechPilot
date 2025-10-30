
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/dummy_data.dart';
import '../models/gadget.dart';
import '../shared/gadget_suggester.dart';

part 'smart_recommendation_state.dart';

class SmartRecommendationCubit extends Cubit<SmartRecommendationState> {
  SmartRecommendationCubit() : super(const SmartRecommendationState()) {
    // Inisialisasi semua gadget dengan tag-nya sekali saja
    final allGadgetsWithTags = allGadgets.map((g) => _WithTags(g, GadgetSuggester.deriveTags(g))).toList();
    emit(state.copyWith(allGadgetsWithTags: allGadgetsWithTags));
    _filterGadgets();
  }

  void setType(String type) {
    emit(state.copyWith(type: type));
    _filterGadgets();
  }

  void setBudget(double budget) {
    emit(state.copyWith(budget: budget));
    _filterGadgets();
  }

  void toggleNeed(String need) {
    final currentNeeds = Set<String>.from(state.needs);
    if (currentNeeds.contains(need)) {
      currentNeeds.remove(need);
    } else {
      currentNeeds.add(need);
    }
    emit(state.copyWith(needs: currentNeeds));
    _filterGadgets();
  }

  void _filterGadgets() {
    final min = (state.budget - 1).clamp(1, 100) * 1_000_000;
    final max = (state.budget + 1) * 1_000_000;

    final filtered = state.allGadgetsWithTags.where((wt) {
      final g = wt.g;
      final okType = g.type == state.type;
      final okBudget = g.price >= min && g.price <= max;
      final okNeeds = state.needs.isEmpty || state.needs.any((n) => wt.tags.contains(n));
      return okType && okBudget && okNeeds;
    }).map((wt) => wt.g).toList(); // Ambil kembali objek Gadget-nya

    emit(state.copyWith(results: filtered));
  }
}

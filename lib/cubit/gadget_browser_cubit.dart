
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/dummy_data.dart';
import '../models/gadget.dart';
import 'package:equatable/equatable.dart';

part 'gadget_browser_state.dart';

class GadgetBrowserCubit extends Cubit<GadgetBrowserState> {
  GadgetBrowserCubit() : super(const GadgetBrowserState()) {
    _filterItems();
  }

  void setType(String type) {
    _filterItems(type: type, q: '');
  }

  void setQuery(String q) {
    _filterItems(q: q);
  }

  void _filterItems({String? type, String? q}) {
    final newType = type ?? state.type;
    final newQ = (q ?? state.q).toLowerCase();

    final items = allGadgets.where((g) {
      final okType = g.type == newType;
      final okQ = newQ.isEmpty ||
          g.name.toLowerCase().contains(newQ) ||
          g.processor.toLowerCase().contains(newQ) ||
          g.camera.toLowerCase().contains(newQ);
      return okType && okQ;
    }).toList();

    emit(state.copyWith(type: newType, q: q ?? state.q, items: items));
  }
}

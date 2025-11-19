import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/gadget.dart';
import '../services/gadget_services.dart';
import 'package:equatable/equatable.dart';

part 'gadget_browser_state.dart';

class GadgetBrowserCubit extends Cubit<GadgetBrowserState> {
  final GadgetService _gadgetService = GadgetService();
  List<Gadget> _allGadgets = [];

  GadgetBrowserCubit() : super(const GadgetBrowserState()) {
    _loadAndFilterItems();
  }

  Future<void> _loadAndFilterItems({String? type, String? q}) async {
    // Muat data hanya jika belum ada
    if (_allGadgets.isEmpty) {
      _allGadgets = await _gadgetService.loadGadgets();
    }

    final newType = type ?? state.type;
    final newQ = (q ?? state.q).toLowerCase();

    final items = _allGadgets.where((g) {
      final okType = g.type == newType;
      final okQ = newQ.isEmpty ||
          g.name.toLowerCase().contains(newQ) ||
          g.processor.toLowerCase().contains(newQ) ||
          (g.camera != null && g.camera!.toLowerCase().contains(newQ));
      return okType && okQ;
    }).toList();

    emit(state.copyWith(type: newType, q: q ?? state.q, items: items));
  }

  void setType(String type) {
    _loadAndFilterItems(type: type, q: '');
  }

  void setQuery(String q) {
    _loadAndFilterItems(q: q);
  }
}

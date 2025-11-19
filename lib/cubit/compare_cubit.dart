import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/gadget.dart';
import '../services/gadget_services.dart';

part 'compare_state.dart';

class CompareCubit extends Cubit<CompareState> {
  final GadgetService _gadgetService = GadgetService();
  List<Gadget> _allGadgets = [];

  CompareCubit() : super(const CompareState()) {
    _loadAllGadgets();
  }

  Future<void> _loadAllGadgets() async {
    _allGadgets = await _gadgetService.loadGadgets();
    // Setelah data dimuat, kita bisa inisialisasi state awal jika perlu
    // Misalnya, langsung set tipe default
    onTypeSelected('smartphone');
  }

  void onTypeSelected(String? type) {
    if (type == null) return;

    // Dapatkan semua brand unik dari gadget yang sesuai dengan tipe yang dipilih
    final availableBrands = _allGadgets
        .where((gadget) => gadget.type == type)
        .map((gadget) => gadget.name.split(' ')[0]) // Ambil brand dari nama, misal "Samsung" dari "Samsung Galaxy S23"
        .toSet()
        .toList();
    availableBrands.sort();

    emit(state.copyWith(
      selectedType: type,
      forceNullBrand: true,
      forceNullGadgetA: true,
      forceNullGadgetB: true,
      availableBrands: availableBrands,
      filteredItems: [],
    ));
  }

  void onBrandSelected(String? brand) {
    if (brand == null) return;

    // Filter gadget berdasarkan tipe dan brand yang dipilih
    final filteredItems = _allGadgets
        .where((g) => g.type == state.selectedType && g.name.startsWith(brand))
        .toList();

    emit(state.copyWith(
      selectedBrand: brand,
      forceNullGadgetA: true,
      forceNullGadgetB: true,
      filteredItems: filteredItems,
    ));
  }

  void onGadgetASelected(Gadget? gadget) {
    emit(state.copyWith(gadgetA: gadget));
  }

  void onGadgetBSelected(Gadget? gadget) {
    emit(state.copyWith(gadgetB: gadget));
  }
}

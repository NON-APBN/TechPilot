import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../data/data_asus.dart';
import '../data/data_google.dart';
import '../data/data_honor.dart';
import '../data/data_huawei.dart';
import '../data/data_infinix.dart';
import '../data/data_itel.dart';
import '../data/data_motorola.dart';
import '../data/data_oneplus.dart';
import '../data/data_oppo.dart';
import '../data/data_poco.dart';
import '../data/data_realme.dart';
import '../data/data_samsung.dart';
import '../models/gadget.dart';

part 'compare_state.dart';

class CompareCubit extends Cubit<CompareState> {
  CompareCubit() : super(const CompareState());

  final Map<String, List<Gadget>> allBrandGadgets = {
    'Asus': asusGadgets,
    'Google': googleGadgets,
    'Honor': honorGadgets,
    'Huawei': huaweiGadgets,
    'Infinix': infinixGadgets,
    'Itel': itelGadgets,
    'Motorola': motorolaGadgets,
    'OnePlus': oneplusGadgets,
    'Oppo': oppoGadgets,
    'Poco': pocoGadgets,
    'Realme': realmeGadgets,
    'Samsung': samsungGadgets,
  };

  void onTypeSelected(String? type) {
    if (type == null) return;

    final availableBrands = allBrandGadgets.keys.where((brand) {
      return allBrandGadgets[brand]!.any((gadget) => gadget.type == type);
    }).toList();

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

    final filteredItems = (allBrandGadgets[brand] ?? [])
        .where((g) => g.type == state.selectedType)
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

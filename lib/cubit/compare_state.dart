import 'package:flutter/foundation.dart';
part of 'compare_cubit.dart';

@immutable
class CompareState extends Equatable {
  final String? selectedType;
  final String? selectedBrand;
  final Gadget? gadgetA;
  final Gadget? gadgetB;
  final List<String> availableBrands;
  final List<Gadget> filteredItems;

  const CompareState({
    this.selectedType,
    this.selectedBrand,
    this.gadgetA,
    this.gadgetB,
    this.availableBrands = const [],
    this.filteredItems = const [],
  });

  CompareState copyWith({
    String? selectedType,
    String? selectedBrand,
    Gadget? gadgetA,
    Gadget? gadgetB,
    List<String>? availableBrands,
    List<Gadget>? filteredItems,
    bool forceNullBrand = false,
    bool forceNullGadgetA = false,
    bool forceNullGadgetB = false,
  }) {
    return CompareState(
      selectedType: selectedType ?? this.selectedType,
      selectedBrand: forceNullBrand ? null : selectedBrand ?? this.selectedBrand,
      gadgetA: forceNullGadgetA ? null : gadgetA ?? this.gadgetA,
      gadgetB: forceNullGadgetB ? null : gadgetB ?? this.gadgetB,
      availableBrands: availableBrands ?? this.availableBrands,
      filteredItems: filteredItems ?? this.filteredItems,
    );
  }

  @override
  List<Object?> get props => [selectedType, selectedBrand, gadgetA, gadgetB, availableBrands, filteredItems];
}

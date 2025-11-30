import 'package:equatable/equatable.dart';
import '../models/catalog_product.dart';

enum CompareStatus { initial, loading, loaded, error }

class CompareState extends Equatable {
  final CompareStatus status;
  final List<CatalogProduct> availableProducts;
  final List<CatalogProduct?> selectedProducts; // Selalu ada 2 slot
  final String? errorMessage;
  final String selectedType;

  const CompareState({
    this.status = CompareStatus.initial,
    this.availableProducts = const [],
    this.selectedProducts = const [null, null],
    this.errorMessage,
    this.selectedType = 'smartphone',
  });

  CompareState copyWith({
    CompareStatus? status,
    List<CatalogProduct>? availableProducts,
    List<CatalogProduct?>? selectedProducts,
    String? errorMessage,
    String? selectedType,
  }) {
    return CompareState(
      status: status ?? this.status,
      availableProducts: availableProducts ?? this.availableProducts,
      selectedProducts: selectedProducts ?? this.selectedProducts,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedType: selectedType ?? this.selectedType,
    );
  }

  @override
  List<Object?> get props => [
        status,
        availableProducts,
        selectedProducts,
        errorMessage,
        selectedType,
      ];
}

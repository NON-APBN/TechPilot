part of 'gadget_browser_cubit.dart';

enum GadgetBrowserStatus { initial, loading, success, error }

class GadgetBrowserState extends Equatable {
  const GadgetBrowserState({
    this.status = GadgetBrowserStatus.initial,
    this.items = const [],
    this.type = 'semua',
    this.q = '',
    this.currentPage = 1,
    this.totalPages = 1,
    this.errorMessage,
  });

  final GadgetBrowserStatus status;
  final List<RecommendedProduct> items;
  final String type;
  final String q;
  final int currentPage;
  final int totalPages;
  final String? errorMessage;

  GadgetBrowserState copyWith({
    GadgetBrowserStatus? status,
    List<RecommendedProduct>? items,
    String? type,
    String? q,
    int? currentPage,
    int? totalPages,
    String? errorMessage,
  }) {
    return GadgetBrowserState(
      status: status ?? this.status,
      items: items ?? this.items,
      type: type ?? this.type,
      q: q ?? this.q,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, type, q, currentPage, totalPages, errorMessage];
}

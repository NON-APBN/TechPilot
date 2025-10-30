
part of 'gadget_browser_cubit.dart';

class GadgetBrowserState extends Equatable {
  final String type;
  final String q;
  final List<Gadget> items;

  const GadgetBrowserState({
    this.type = 'smartphone',
    this.q = '',
    this.items = const [],
  });

  GadgetBrowserState copyWith({
    String? type,
    String? q,
    List<Gadget>? items,
  }) {
    return GadgetBrowserState(
      type: type ?? this.type,
      q: q ?? this.q,
      items: items ?? this.items,
    );
  }

  @override
  List<Object> get props => [type, q, items];
}

import 'recommended_product.dart';

class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String text;
  final List<RecommendedProduct> products;

  ChatMessage({
    required this.role,
    required this.text,
    this.products = const [],
  });
}

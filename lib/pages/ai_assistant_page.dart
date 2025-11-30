import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../cubit/ai_assistant_cubit.dart';
import '../models/chat_message.dart';
import '../models/recommended_product.dart';
import '../models/recommended_product.dart';
import 'product_detail_page.dart';
import '../shared/app_localizations.dart';

class AIAssistantPage extends StatelessWidget {
  const AIAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AIAssistantCubit(),
      child: const AIAssistantView(),
    );
  }
}

class AIAssistantView extends StatefulWidget {
  const AIAssistantView({super.key});

  @override
  State<AIAssistantView> createState() => _AIAssistantViewState();
}

class _AIAssistantViewState extends State<AIAssistantView> {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<AIAssistantCubit>().sendMessage(text);
    _controller.clear();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(AppLocalizations.of(context).get('ai_title'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textColor)),
              ).animate().fade().slideY(begin: 0.2, end: 0),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor, borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 3))],
                  ),
                  child: BlocConsumer<AIAssistantCubit, AIAssistantState>(
                    listener: (context, state) {
                      if (state is AIAssistantLoaded) {
                        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                      }
                    },
                    builder: (context, state) {
                      if (state is! AIAssistantLoaded) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == state.messages.length) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(AppLocalizations.of(context).get('ai_typing'), style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                              ),
                            ).animate().fade();
                          }
                          
                          final m = state.messages[i];
                          return _ChatBubble(message: m);
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).get('ai_input_hint'),
                        hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        filled: true, fillColor: cardColor,
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _send, 
                    icon: const Icon(Icons.send), 
                    label: Text(AppLocalizations.of(context).get('ai_btn_send'))
                  ),
                ],
              ).animate(delay: 300.ms).fade().slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userBubbleColor = isDark ? Theme.of(context).primaryColor.withOpacity(0.5) : const Color(0xFFEEF1FF);
    final assistantBubbleColor = isDark ? const Color(0xFF27272A) : const Color(0xFFF0F0F0);
    final textColor = isDark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 700),
          decoration: BoxDecoration(
            color: isUser ? userBubbleColor : assistantBubbleColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(message.text, style: TextStyle(color: textColor)),
        ).animate().fade().slideX(begin: isUser ? 0.1 : -0.1, end: 0),
        if (message.products.isNotEmpty)
          Container(
            height: 220,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: message.products.length,
              itemBuilder: (context, index) {
                final product = message.products[index];
                return GestureDetector(
                  onTap: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(product: product),
                      ),
                    );
                  },
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            alignment: Alignment.center,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.asset(
                                product.image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      product.type == ProductType.laptop ? Icons.laptop : Icons.smartphone,
                                      size: 48, color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.productName,
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${(product.price) ~/ 1000000} Juta',
                                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

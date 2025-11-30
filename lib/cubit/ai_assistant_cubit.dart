import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/recommended_product.dart';

abstract class AIAssistantState {}

class AIAssistantInitial extends AIAssistantState {}

class AIAssistantLoaded extends AIAssistantState {
  final List<ChatMessage> messages;
  final bool isTyping;

  AIAssistantLoaded({required this.messages, this.isTyping = false});
}

class AIAssistantCubit extends Cubit<AIAssistantState> {
  AIAssistantCubit() : super(AIAssistantLoaded(messages: [
    ChatMessage(role: 'assistant', text: 'Halo! Saya TechPilot AI. Tanyakan rekomendasi gadget impianmu, misalnya "Cari laptop gaming 15 jutaan" atau "HP Samsung kamera bagus".')
  ]));

  final String _baseUrl = 'https://drappy-cat-techpilot-backend.hf.space/api';

  Future<void> sendMessage(String text) async {
    final currentState = state;
    if (currentState is! AIAssistantLoaded) return;

    final currentMessages = List<ChatMessage>.from(currentState.messages);
    
    // 1. Add User Message
    currentMessages.add(ChatMessage(role: 'user', text: text));
    emit(AIAssistantLoaded(messages: currentMessages, isTyping: true));

    try {
      // 2. Call API
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseText = data['response'] as String;
        final productsData = data['products'] as List<dynamic>;
        
        List<RecommendedProduct> products = [];
        for (var p in productsData) {
           final typeStr = p['type'] ?? 'laptop';
           final type = typeStr == 'laptop' ? ProductType.laptop : ProductType.smartphone;
           
           // Use RecommendedProduct.fromJson for consistency
           products.add(RecommendedProduct.fromJson(p, type));
        }

        // 3. Add Assistant Message
        currentMessages.add(ChatMessage(role: 'assistant', text: responseText, products: products));
        emit(AIAssistantLoaded(messages: currentMessages, isTyping: false));
      } else {
        currentMessages.add(ChatMessage(role: 'assistant', text: 'Maaf, terjadi kesalahan koneksi ke server AI.'));
        emit(AIAssistantLoaded(messages: currentMessages, isTyping: false));
      }
    } catch (e) {
      currentMessages.add(ChatMessage(role: 'assistant', text: 'Error: $e'));
      emit(AIAssistantLoaded(messages: currentMessages, isTyping: false));
    }
  }
}

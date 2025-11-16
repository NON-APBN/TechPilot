// lib/pages/ai_assistant_page.dart (Update: Integrasi fetchChat)
import 'package:flutter/material.dart';
import '../shared/http_helper.dart';  // Import HTTP helper

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  final _controller = TextEditingController();
  final List<_Msg> _messages = [
    _Msg('assistant', 'Halo! Tulis kebutuhanmu, contoh: "budget 6-8 jt buat gaming & kamera".'),
  ];
  String _currentType = 'smartphone';  // Default, bisa tambah switch untuk smartphone/laptop

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg('user', text));
      _controller.clear();
    });

    try {
      final reply = await fetchChat(text, _currentType);
      setState(() => _messages.add(_Msg('assistant', reply)));
    } catch (e) {
      setState(() => _messages.add(_Msg('assistant', 'Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('AI Assistant', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 3))],
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final isUser = m.role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 700),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFFEEF1FF) : const Color(0xFFF6F6F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m.text),
                  ),
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
                decoration: const InputDecoration(
                  hintText: 'Ceritakan kebutuhanmu…',
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(onPressed: _send, icon: const Icon(Icons.send), label: const Text('Kirim')),
          ],
        ),
      ],
    );
  }
}

class _Msg {
  final String role; // 'user' | 'assistant'
  final String text;
  _Msg(this.role, this.text);
}
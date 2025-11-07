import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../data/dummy_data.dart';
import '../shared/gadget_suggester.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  final _controller = TextEditingController();
  final List<_Msg> _messages = [
    _Msg('assistant',
        'Halo! Tulis kebutuhanmu, contoh: "budget 6-8 jt buat gaming & kamera".'),
  ];

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg('user', text));
      _controller.clear();
    });

    final reply = GadgetSuggester.replyFor(text, allGadgets);
    setState(() => _messages.add(_Msg('assistant', reply)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('AI Assistant',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800)),
        ),
        SizedBox(height: 1.5.h),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.sp),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 8,
                    offset: Offset(0, 3))
              ],
            ),
            child: ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final isUser = m.role == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 0.8.h),
                    padding: EdgeInsets.all(3.w),
                    constraints: BoxConstraints(maxWidth: 70.w),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFFEEF1FF)
                          : const Color(0xFFF6F6F9),
                      borderRadius: BorderRadius.circular(10.sp),
                    ),
                    child: Text(m.text),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 1.2.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Ceritakan kebutuhanmu…',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.sp))),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            FilledButton.icon(
                onPressed: _send,
                icon: const Icon(Icons.send),
                label: const Text('Kirim')),
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

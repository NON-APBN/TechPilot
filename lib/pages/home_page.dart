import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isNarrow = MediaQuery.of(context).size.width < 760;

    Widget featureCard(IconData icon, String title, String desc, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 32, color: cs.primary),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(desc, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // PERUBAHAN: Banner diubah warnanya
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Temukan Gadget Impian Anda',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('Platform terlengkap untuk mencari, membandingkan, dan mendapat rekomendasi gadget terbaik dengan bantuan AI.',
                    style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.pushNamed(context, '/rekomendasi'),
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: cs.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20)),
                  child: const Text('Mulai Jelajahi'),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: isNarrow ? 2 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              featureCard(Icons.storage, 'Database Lengkap', 'Ribuan smartphone & laptop.', () => Navigator.pushNamed(context, '/jelajah')),
              featureCard(Icons.lightbulb, 'Rekomendasi Pintar', 'Filter cerdas sesuai kebutuhan.', () => Navigator.pushNamed(context, '/rekomendasi')),
              featureCard(Icons.chat_bubble_outline, 'AI Assistant', 'Chat untuk saran personal.', () => Navigator.pushNamed(context, '/ai')),
              featureCard(Icons.compare_arrows_rounded, 'Perbandingan Detail', 'Bandingkan side-by-side.', () => Navigator.pushNamed(context, '/bandingkan')),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

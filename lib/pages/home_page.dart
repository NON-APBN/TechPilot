
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Ukuran font adaptif yang lebih halus dan terkontrol
    double headlineSize = screenWidth < 600 ? 24 : 32;
    double bodySize = screenWidth < 600 ? 14 : 16;

    Widget featureCard(IconData icon, String title, String desc, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // Menggunakan mainAxisAlignment untuk menyebarkan konten secara vertikal
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 32, color: cs.primary),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(desc, style: const TextStyle(color: Colors.black54, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Daftar kartu fitur untuk digunakan di GridView.builder
    final List<Widget> featureCards = [
      featureCard(Icons.storage, 'Database Lengkap', 'Ribuan smartphone & laptop.', () => Navigator.pushNamed(context, '/jelajah')),
      featureCard(Icons.lightbulb, 'Rekomendasi Pintar', 'Filter cerdas sesuai kebutuhan.', () => Navigator.pushNamed(context, '/rekomendasi')),
      featureCard(Icons.chat_bubble_outline, 'AI Assistant', 'Chat untuk saran personal.', () => Navigator.pushNamed(context, '/ai')),
      featureCard(Icons.compare_arrows_rounded, 'Perbandingan Detail', 'Bandingkan side-by-side.', () => Navigator.pushNamed(context, '/bandingkan')),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 600 ? 20 : 40,
              vertical: screenWidth < 600 ? 25 : 30,
            ),
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
                Text('Temukan Gadget Impian Anda',
                    style: TextStyle(color: Colors.white, fontSize: headlineSize, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Platform terlengkap untuk mencari, membandingkan, dan mendapat rekomendasi gadget terbaik dengan bantuan AI.',
                    style: TextStyle(color: Colors.white70, fontSize: bodySize, height: 1.5)),
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
          // THE FIX: Menggunakan GridView.builder dengan SliverGridDelegateWithMaxCrossAxisExtent
          GridView.builder(
            padding: EdgeInsets.zero, // Padding sudah diatur oleh parent
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              // Setiap item akan memiliki lebar maksimal 350px. Flutter akan secara otomatis
              // menghitung berapa banyak kolom yang bisa muat. Ini adalah kunci presisi.
              maxCrossAxisExtent: 350,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              // Rasio ini membuat kartu lebih lebar dari tingginya, memperbaiki masalah "kebesaran".
              childAspectRatio: 1.4,
            ),
            itemCount: featureCards.length,
            itemBuilder: (context, index) {
              return featureCards[index];
            },
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

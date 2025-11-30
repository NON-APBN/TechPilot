
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  // Helper widget untuk membangun setiap baris fitur
  Widget _buildFeatureRow(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // Sedikit lebih banyak padding vertikal
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 32), // Ikon lebih besar
          const SizedBox(width: 20), // Spasi lebih lebar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), // Judul fitur lebih menonjol
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0), // Padding keseluruhan yang lebih besar
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ikon pembuka yang lebih besar dan menonjol
                Icon(
                  Icons.rocket_launch_outlined, // Ikon yang lebih dinamis dan modern
                  size: 100,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Selamat Datang di TechPilot!',
                  style: theme.textTheme.displaySmall?.copyWith( // Menggunakan displaySmall untuk judul yang sangat besar
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700), // Batasi lebar deskripsi agar tidak terlalu panjang
                  child: Text(
                    'Platform cerdas Anda untuk menemukan gadget impian. Jelajahi rekomendasi personal, manfaatkan asisten AI, dan bandingkan spesifikasi dengan mudah.',
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.black87), // Deskripsi lebih menonjol
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 48), // Spasi lebih besar sebelum fitur
                
                // Membungkus fitur dalam ConstrainedBox agar tidak terlalu lebar di layar besar
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700), // Batasi lebar fitur agar tetap mudah dibaca
                  child: Column(
                    children: [
                      _buildFeatureRow(
                        context,
                        icon: Icons.lightbulb_outline,
                        title: 'Rekomendasi Pintar',
                        subtitle: 'Dapatkan saran gadget yang paling sesuai dengan budget dan kebutuhan Anda.',
                      ),
                      _buildFeatureRow(
                        context,
                        icon: Icons.chat_bubble_outline,
                        title: 'AI Assistant',
                        subtitle: 'Tanya apa saja tentang gadget dan dapatkan jawaban personal dari asisten AI kami.',
                      ),
                      _buildFeatureRow(
                        context,
                        icon: Icons.compare_arrows_outlined,
                        title: 'Bandingkan Detail',
                        subtitle: 'Lihat perbandingan spesifikasi gadget secara berdampingan untuk keputusan terbaik.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48), // Spasi lebih besar sebelum tombol
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400), // Batasi lebar tombol agar tidak terlalu lebar
                  child: SizedBox(
                    width: double.infinity, // Tombol mengisi lebar yang tersedia dalam ConstrainedBox
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 40), // Tombol lebih besar
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Sudut tombol lebih bulat
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: const Text('Ayo Mulai Petualangan Gadget Anda!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), // Teks tombol lebih menarik
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

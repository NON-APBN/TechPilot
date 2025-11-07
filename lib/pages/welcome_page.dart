
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  // Helper widget untuk membangun setiap baris fitur
  Widget _buildFeatureRow(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5.h), // Sedikit lebih banyak padding vertikal
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24.sp), // Ikon lebih besar
          SizedBox(width: 5.w), // Spasi lebih lebar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), // Judul fitur lebih menonjol
                SizedBox(height: 0.5.h),
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
            padding: EdgeInsets.all(8.w), // Padding keseluruhan yang lebih besar
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ikon pembuka yang lebih besar dan menonjol
                Icon(
                  Icons.rocket_launch_outlined, // Ikon yang lebih dinamis dan modern
                  size: 12.h,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(height: 3.h),
                Text(
                  'Selamat Datang di GadgetHub!',
                  style: theme.textTheme.displaySmall?.copyWith( // Menggunakan displaySmall untuk judul yang sangat besar
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 80.w), // Batasi lebar deskripsi agar tidak terlalu panjang
                  child: Text(
                    'Platform cerdas Anda untuk menemukan gadget impian. Jelajahi rekomendasi personal, manfaatkan asisten AI, dan bandingkan spesifikasi dengan mudah.',
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.black87), // Deskripsi lebih menonjol
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 6.h), // Spasi lebih besar sebelum fitur
                
                // Membungkus fitur dalam ConstrainedBox agar tidak terlalu lebar di layar besar
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 80.w), // Batasi lebar fitur agar tetap mudah dibaca
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
                SizedBox(height: 6.h), // Spasi lebih besar sebelum tombol
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 50.w), // Batasi lebar tombol agar tidak terlalu lebar
                  child: SizedBox(
                    width: double.infinity, // Tombol mengisi lebar yang tersedia dalam ConstrainedBox
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 10.w), // Tombol lebih besar
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)), // Sudut tombol lebih bulat
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: Text('Ayo Mulai Petualangan Gadget Anda!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)), // Teks tombol lebih menarik
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

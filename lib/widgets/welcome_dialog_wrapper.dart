
import 'package:flutter/material.dart';

class WelcomeDialogWrapper extends StatefulWidget {
  final Widget child;
  const WelcomeDialogWrapper({super.key, required this.child});

  @override
  State<WelcomeDialogWrapper> createState() => _WelcomeDialogWrapperState();
}

class _WelcomeDialogWrapperState extends State<WelcomeDialogWrapper> {
  bool _showWelcomeScreen = true;

  Widget _buildFeatureRow(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

    if (_showWelcomeScreen) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Selamat Datang di GadgetHub!',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Platform cerdas Anda untuk menemukan gadget impian. Berikut beberapa hal yang bisa Anda lakukan:',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Menghapus ConstrainedBox di sini agar daftar fitur mengisi lebar yang tersedia
                  Column(
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
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity, // Membuat tombol mengisi lebar penuh yang tersedia
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                      ),
                      onPressed: () {
                        setState(() {
                          _showWelcomeScreen = false;
                        });
                      },
                      child: const Text('Ayo Mulai!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}

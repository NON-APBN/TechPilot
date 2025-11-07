
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isNarrow = 100.w < 760;

    Widget featureCard(IconData icon, String title, String desc, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.sp),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(18.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 24.sp, color: cs.primary),
                SizedBox(height: 2.h),
                Text(title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 0.8.h),
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
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.sp),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Temukan Gadget Impian Anda',
                    style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 1.5.h),
                Text('Platform terlengkap untuk mencari, membandingkan, dan mendapat rekomendasi gadget terbaik dengan bantuan AI.',
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp, height: 1.5)),
                SizedBox(height: 3.h),
                FilledButton(
                  onPressed: () => Navigator.pushNamed(context, '/rekomendasi'),
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: cs.primary,
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h)),
                  child: const Text('Mulai Jelajahi'),
                )
              ],
            ),
          ),
          SizedBox(height: 3.h),
          GridView.count(
            crossAxisCount: isNarrow ? 2 : 4,
            crossAxisSpacing: 2.w,
            mainAxisSpacing: 2.h,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              featureCard(Icons.storage, 'Database Lengkap', 'Ribuan smartphone & laptop.', () => Navigator.pushNamed(context, '/jelajah')),
              featureCard(Icons.lightbulb, 'Rekomendasi Pintar', 'Filter cerdas sesuai kebutuhan.', () => Navigator.pushNamed(context, '/rekomendasi')),
              featureCard(Icons.chat_bubble_outline, 'AI Assistant', 'Chat untuk saran personal.', () => Navigator.pushNamed(context, '/ai')),
              featureCard(Icons.compare_arrows_rounded, 'Perbandingan Detail', 'Bandingkan side-by-side.', () => Navigator.pushNamed(context, '/bandingkan')),
            ],
          ),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }
}

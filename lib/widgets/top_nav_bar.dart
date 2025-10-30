import 'package:flutter/material.dart';

class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? '/';
    final cs = Theme.of(context).colorScheme;

    Widget item(String label, String path) {
      final isActive = route == path;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () => Navigator.pushNamedAndRemoveUntil(context, path, (r) => false),
          borderRadius: BorderRadius.circular(10),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.black54,
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    // PERUBAHAN: Material diubah menjadi putih
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Icon(Icons.memory, color: cs.primary, size: 28),
            const SizedBox(width: 8),
            Text('TechPilot',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                )),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                item('Home', '/'),
                const SizedBox(width: 8),
                item('Jelajahi', '/jelajah'),
                const SizedBox(width: 8),
                item('Bandingkan', '/bandingkan'),
                const SizedBox(width: 8),
                item('Rekomendasi', '/rekomendasi'),
                const SizedBox(width: 8),
                item('AI Assistant', '/ai'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

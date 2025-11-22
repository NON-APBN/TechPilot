import 'package:flutter/material.dart';

class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? '/';
    final cs = Theme.of(context).colorScheme;

    // Widget untuk setiap item navigasi
    Widget navItem(String label, String path, {bool isPopup = false}) {
      final isActive = route == path;
      return InkWell(
        onTap: () => Navigator.pushNamedAndRemoveUntil(context, path, (r) => false),
        borderRadius: BorderRadius.circular(10),
        child: isPopup
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                width: double.infinity,
                color: isActive ? cs.primary.withAlpha(25) : Colors.transparent, // 0.1 opacity
                child: Text(label, style: TextStyle(color: isActive ? cs.primary : Colors.black87)),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? cs.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
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

    // Daftar item navigasi
    final navItems = [
      navItem('Home', '/'),
      navItem('Jelajahi', '/jelajah'),
      navItem('Bandingkan', '/bandingkan'),
      navItem('Rekomendasi', '/rekomendasi'),
      navItem('AI Assistant', '/ai'),
    ];

    // Daftar item untuk PopupMenu
    final popupNavItems = [
      PopupMenuItem(value: '/', child: navItem('Home', '/', isPopup: true)),
      PopupMenuItem(value: '/jelajah', child: navItem('Jelajahi', '/jelajah', isPopup: true)),
      PopupMenuItem(value: '/bandingkan', child: navItem('Bandingkan', '/bandingkan', isPopup: true)),
      PopupMenuItem(value: '/rekomendasi', child: navItem('Rekomendasi', '/rekomendasi', isPopup: true)),
      PopupMenuItem(value: '/ai', child: navItem('AI Assistant', '/ai', isPopup: true)),
    ];

    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withAlpha(25), // 0.1 opacity
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
            // Menggunakan LayoutBuilder untuk membuat navigasi adaptif
            LayoutBuilder(
              builder: (context, constraints) {
                // Tentukan breakpoint, misalnya 800px
                if (constraints.maxWidth < 800) {
                  // Tampilan untuk layar sempit (mobile)
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.menu), // Ikon hamburger
                    onSelected: (path) {
                      Navigator.pushNamedAndRemoveUntil(context, path, (r) => false);
                    },
                    itemBuilder: (BuildContext context) => popupNavItems,
                  );
                } else {
                  // Tampilan untuk layar lebar (desktop)
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: navItems.expand((item) => [item, const SizedBox(width: 8)]).toList()..removeLast(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

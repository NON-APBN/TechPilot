import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/theme_cubit.dart';
import '../cubit/language_cubit.dart';
import '../shared/app_localizations.dart';

class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? '/';
    final cs = Theme.of(context).colorScheme;

    Widget navItem(String label, String path, {bool isPopup = false}) {
      final isActive = route == path;
      return InkWell(
        onTap: () => Navigator.pushNamedAndRemoveUntil(context, path, (r) => false),
        borderRadius: BorderRadius.circular(10),
        child: isPopup
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                width: double.infinity,
                color: isActive ? cs.primary.withAlpha(25) : Colors.transparent,
                child: Text(label, style: TextStyle(color: isActive ? cs.primary : Theme.of(context).textTheme.bodyMedium?.color)),
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
                    color: isActive 
                        ? Colors.white 
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 15,
                  ),
                ),
              ),
      );
    }

    // --- MENAMBAHKAN KEMBALI TOMBOL BANDINGKAN ---
    final navItems = [
      navItem(AppLocalizations.of(context).get('nav_home'), '/home'),
      navItem(AppLocalizations.of(context).get('nav_browse'), '/jelajah'),
      navItem(AppLocalizations.of(context).get('nav_recommend'), '/rekomendasi'),
      navItem(AppLocalizations.of(context).get('nav_compare'), '/bandingkan'),
      navItem(AppLocalizations.of(context).get('nav_ai'), '/ai'),
    ];

    final popupNavItems = [
      PopupMenuItem(value: '/home', child: navItem(AppLocalizations.of(context).get('nav_home'), '/home', isPopup: true)),
      PopupMenuItem(value: '/jelajah', child: navItem(AppLocalizations.of(context).get('nav_browse'), '/jelajah', isPopup: true)),
      PopupMenuItem(value: '/rekomendasi', child: navItem(AppLocalizations.of(context).get('nav_recommend'), '/rekomendasi', isPopup: true)),
      PopupMenuItem(value: '/bandingkan', child: navItem(AppLocalizations.of(context).get('nav_compare'), '/bandingkan', isPopup: true)),
      PopupMenuItem(value: '/ai', child: navItem(AppLocalizations.of(context).get('nav_ai'), '/ai', isPopup: true)),
    ];
    // ---------------------------------------------

    return Material(
      color: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 2,
      shadowColor: Colors.black.withAlpha(25),
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
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Theme.of(context).brightness == Brightness.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color: cs.primary,
                        ),
                        onPressed: () {
                          context.read<ThemeCubit>().toggleTheme();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.language),
                        color: cs.primary,
                        onPressed: () {
                          context.read<LanguageCubit>().toggleLanguage();
                        },
                        tooltip: 'Switch Language',
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.menu),
                        onSelected: (path) {
                          Navigator.pushNamedAndRemoveUntil(context, path, (r) => false);
                        },
                        itemBuilder: (BuildContext context) => popupNavItems,
                      ),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...navItems.expand((item) => [item, const SizedBox(width: 8)]).toList(),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Theme.of(context).brightness == Brightness.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color: cs.primary,
                        ),
                        onPressed: () {
                          context.read<ThemeCubit>().toggleTheme();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.language),
                        color: cs.primary,
                        onPressed: () {
                          context.read<LanguageCubit>().toggleLanguage();
                        },
                        tooltip: 'Switch Language',
                      ),
                    ],
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

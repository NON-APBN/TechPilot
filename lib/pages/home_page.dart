import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/footer.dart';
import '../shared/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing
    double headlineSize = screenWidth < 600 ? 28 : 48;
    double bodySize = screenWidth < 600 ? 16 : 20;

    // Theme-aware banner color
    final bannerColor = theme.brightness == Brightness.dark
        ? const Color(0xFF1E1E2C) // Darker purple/blue for dark mode
        : const Color(0xFF6C5CE7); // Original purple for light mode

    final List<Widget> featureCards = [
      _FeatureCard(
        icon: Icons.auto_awesome,
        title: AppLocalizations.of(context).get('home_feature_ai_title'),
        desc: AppLocalizations.of(context).get('home_feature_ai_desc'),
        color: Colors.amber,
        onTap: () => Navigator.pushNamed(context, '/rekomendasi'),
      ),
      _FeatureCard(
        icon: Icons.compare_arrows,
        title: AppLocalizations.of(context).get('home_feature_compare_title'),
        desc: AppLocalizations.of(context).get('home_feature_compare_desc'),
        color: Colors.blue,
        onTap: () => Navigator.pushNamed(context, '/bandingkan'),
      ),
      _FeatureCard(
        icon: Icons.search,
        title: AppLocalizations.of(context).get('home_feature_search_title'),
        desc: AppLocalizations.of(context).get('home_feature_search_desc'),
        color: Colors.green,
        onTap: () => Navigator.pushNamed(context, '/jelajah'),
      ),
    ];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth < 600 ? 20 : 40,
                        vertical: screenWidth < 600 ? 25 : 30,
                      ),
                      decoration: BoxDecoration(
                        color: bannerColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context).get('home_headline'),
                              style: TextStyle(color: Colors.white, fontSize: headlineSize, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(AppLocalizations.of(context).get('home_subheadline'),
                              style: TextStyle(color: Colors.white70, fontSize: bodySize, height: 1.5)),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: () => Navigator.pushNamed(context, '/rekomendasi'),
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: cs.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20)),
                            child: Text(AppLocalizations.of(context).get('home_cta')),
                          )
                        ],
                      ),
                    ).animate().fade(duration: 600.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
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
                        return featureCards[index]
                            .animate(delay: (100 * index).ms)
                            .fade(duration: 500.ms)
                            .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
                      },
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: [
              const Spacer(),
              const Footer().animate(delay: 400.ms).fade(duration: 600.ms),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  desc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

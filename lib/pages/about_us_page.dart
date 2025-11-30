import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/footer.dart';
import '../shared/app_localizations.dart';

import 'package:flutter_animate/flutter_animate.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  final List<Map<String, String>> teamMembers = const [
    {
      'name': 'Rizma Indra Pramudya',
      'nim': '24111814117',
      'role': 'FullStack Developer & ML Engineer (Leader)',
      'image': 'assets/images/Profile/RizmaIndraPramudya.jpg',
    },
    {
      'name': 'Izora Elverda Narulita Putri',
      'nim': '24111814012',
      'role': 'Data Analyst',
      'image': 'assets/images/Profile/IzoraElverdaNarulitaPutri.jpg',
    },
    {
      'name': 'Muhammad Abdullah Ro’in',
      'nim': '24111814054',
      'role': 'Machine Learning Engineer',
      'image': 'assets/images/Profile/MuhammadAbdullahRo’in.jpg',
    },
    {
      'name': 'Putera Al Khalidi',
      'nim': '24111814077',
      'role': 'Frontend Engineer',
      'image': 'assets/images/Profile/PuteraAlKhalidi.jpg',
    },
    {
      'name': 'Durrotun Nashihin, M.Sc.',
      'nim': '199604042024061002', // NIP
      'role': 'Advisor',
      'image': 'assets/images/Profile/DurrotunNashihin,M.Sc..jpg',
      'isLecturer': 'true',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).get('about_title')),
        backgroundColor: theme.cardColor,
        foregroundColor: theme.textTheme.bodyLarge?.color,
        elevation: 1,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Section
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark 
                                ? [Colors.deepPurple.shade900, Colors.black]
                                : [Colors.blue.shade800, Colors.blue.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          children: [
                             Icon(Icons.rocket_launch, size: 80, color: Colors.white.withOpacity(0.9)),
                             const SizedBox(height: 16),
                             const Text(
                              "TechPilot",
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context).get('about_subtitle'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    textAlign: TextAlign.justify,
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 18, color: Colors.white, height: 1.6),
                                      children: [
                                        TextSpan(text: AppLocalizations.of(context).get('about_desc_p1')),
                                        TextSpan(text: AppLocalizations.of(context).get('about_desc_p2_1')),
                                        TextSpan(text: AppLocalizations.of(context).get('about_desc_p2_ai'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                                        TextSpan(text: AppLocalizations.of(context).get('about_desc_p2_and')),
                                        TextSpan(text: AppLocalizations.of(context).get('about_desc_p2_ml'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                                        TextSpan(text: AppLocalizations.of(context).get('about_desc_p2_2')),
                                        TextSpan(text: AppLocalizations.of(context).get('about_features_title')),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const SizedBox(height: 16),
                                  _buildBulletPoint(AppLocalizations.of(context).get('about_feature_1')),
                                  _buildBulletPoint(AppLocalizations.of(context).get('about_feature_2')),
                                  _buildBulletPoint(AppLocalizations.of(context).get('about_feature_3')),
                                  _buildBulletPoint(AppLocalizations.of(context).get('about_feature_4')),
                                  const SizedBox(height: 24),
                                  Text(
                                    AppLocalizations.of(context).get('about_closing'),
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(fontSize: 18, color: Colors.white, height: 1.6),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fade(duration: 800.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

                      const SizedBox(height: 40),

                      // Team Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).get('about_team_title'),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : theme.primaryColor, // White in dark mode
                              ),
                            ).animate(delay: 400.ms).fade().slideX(),
                            const SizedBox(height: 24),
                            
                            LayoutBuilder(
                              builder: (context, constraints) {
                                // Responsive Grid: 1 column on mobile, 2 on tablet, 3 on desktop
                                int crossAxisCount = 1;
                                if (constraints.maxWidth > 600) crossAxisCount = 2;
                                if (constraints.maxWidth > 900) crossAxisCount = 3;

                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    childAspectRatio: 0.85, // Adjust card height
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: teamMembers.length,
                                  itemBuilder: (context, index) {
                                    final member = teamMembers[index];
                                    return _TeamMemberCard(member: member)
                                        .animate(delay: (200 * index + 600).ms)
                                        .fade(duration: 600.ms)
                                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 60),

                      // GitHub Section
                      Container(
                        padding: const EdgeInsets.all(32),
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.code, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context).get('about_opensource_title'),
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context).get('about_opensource_desc'),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ).animate(delay: 1000.ms).fade().slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 40),
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
                const Footer().animate(delay: 1200.ms).fade(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.amberAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final Map<String, String> member;

  const _TeamMemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLecturer = member['isLecturer'] == 'true';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              backgroundImage: AssetImage(member['image']!),
            ),
            const SizedBox(height: 16),
            Text(
              member['name']!,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18, // Increased size
              ),
            ),
            const SizedBox(height: 4),
            Text(
              member['role']!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14, // Explicit size
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: theme.dividerColor.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              "Universitas Negeri Surabaya",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 14, // Increased size
                color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87, // White in dark mode
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isLecturer ? "NIP: ${member['nim']}" : "NIM: ${member['nim']}",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54, // White/Grey in dark mode
                fontFamily: 'Monospace',
                fontSize: 13, // Increased size
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'widgets/top_nav_bar.dart';
import 'widgets/footer.dart';
import 'pages/home_page.dart';
import 'pages/ai_assistant_page.dart';
import 'pages/smart_recommendation_page.dart';
import 'pages/browser_page.dart';
import 'pages/compare_page.dart';
import 'pages/welcome_page.dart';
import 'pages/about_us_page.dart';
import 'pages/coming_soon_page.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/theme_cubit.dart';
import 'cubit/language_cubit.dart';
import 'shared/app_theme.dart';
import 'shared/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();
  runApp(const TechPilotApp());
}

class TechPilotApp extends StatelessWidget {
  const TechPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => LanguageCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LanguageCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp(
                title: 'TechPilot',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeMode,
                locale: locale,
                localizationsDelegates: const [
                  AppLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('id', ''),
                  Locale('en', ''),
                ],
                initialRoute: '/',
                routes: {
                  '/': (_) => const WelcomePage(),
                  '/home': (_) => const Shell(child: HomePage()),
                  '/ai': (_) => const Shell(child: AIAssistantPage()),
                  '/rekomendasi': (_) => const Shell(child: SmartRecommendationPage()),
                  '/jelajah': (_) => const Shell(child: BrowsePage()),
                  '/bandingkan': (_) => const Shell(child: ComparePage()),
                  '/about': (_) => const Shell(child: AboutUsPage()),
                  '/suggestion': (_) => const Shell(child: ComingSoonPage(titleKey: 'footer_suggest')),
                  '/partnership': (_) => const Shell(child: ComingSoonPage(titleKey: 'footer_partner')),
                  '/contact': (_) => const Shell(child: ComingSoonPage(titleKey: 'footer_contact')),
                },
                onUnknownRoute: (_) => MaterialPageRoute(builder: (_) => const Shell(child: HomePage())),
              );
            },
          );
        },
      ),
    );
  }
}

class Shell extends StatelessWidget {
  final Widget child;
  const Shell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: TopNavBar(),
      ),
      body: child,
    );
  }
}

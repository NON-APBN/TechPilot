import 'package:flutter/material.dart';
import 'models/gadget.dart';
import 'widgets/top_nav_bar.dart';
import 'pages/home_page.dart';
import 'pages/ai_assistant_page.dart';
import 'pages/smart_recommendation_page.dart';
import 'pages/browser_page.dart';
import 'pages/compare_page.dart';
import 'pages/product_detail_page.dart';

void main() {
  runApp(const GadgetHubApp());
}

class GadgetHubApp extends StatelessWidget {
  const GadgetHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GadgetHub',
      debugShowCheckedModeBanner: false,
      // ### PERUBAHAN UTAMA ADA DI SINI ###
      theme: ThemeData(
        // Warna utama diubah menjadi ungu/biru sesuai gambar
        primaryColor: const Color(0xFF6A5AE0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A5AE0),
          primary: const Color(0xFF6A5AE0), // Warna utama untuk tombol, ikon, dll.
          secondary: const Color(0xFF9461F8), // Warna sekunder untuk gradasi
          surface: Colors.white, // Warna untuk Card
          background: const Color(0xFFF7F7FB), // Warna latar belakang halaman
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7FB),
        // AppBar diubah menjadi putih
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF333333),
          elevation: 1,
          surfaceTintColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF333333), fontSize: 24),
          titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF333333), fontSize: 20),
          bodyMedium: TextStyle(color: Color(0xFF555555), height: 1.6, fontSize: 16),
        ),
        // Tombol diubah menjadi warna ungu/biru
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF6A5AE0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6A5AE0),
            side: const BorderSide(color: Color(0xFF6A5AE0)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const Shell(child: HomePage()),
        '/ai': (_) => const Shell(child: AIAssistantPage()),
        '/rekomendasi': (_) => const Shell(child: SmartRecommendationPage()),
        '/jelajah': (_) => const Shell(child: BrowsePage()),
        '/bandingkan': (_) => const Shell(child: ComparePage()),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final g = settings.arguments;
          if (g is Gadget) {
            return MaterialPageRoute(
              builder: (_) => ProductDetailPage(gadget: g),
              settings: settings,
            );
          }
          return MaterialPageRoute(
              builder: (_) => const Scaffold(
                  body: Center(child: Text("Error: Data produk tidak valid."))));
        }
        return null;
      },
      onUnknownRoute: (_) => MaterialPageRoute(builder: (_) => const Shell(child: HomePage())),
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0), // Jarak atas sudah diperkecil
            child: child,
          ),
        ),
      ),
    );
  }
}


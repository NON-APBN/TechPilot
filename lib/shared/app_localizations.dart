import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('id'));
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'id': {
      // Navbar
      'nav_home': 'Beranda',
      'nav_browse': 'Jelajahi',
      'nav_recommend': 'Rekomendasi',
      'nav_compare': 'Bandingkan',
      'nav_ai': 'Asisten AI',
      
      // Footer
      'footer_about': 'Tentang Kami',
      'footer_suggest': 'Saran Produk',
      'footer_partner': 'Kemitraan',
      'footer_contact': 'Hubungi Kami',
      'coming_soon_title': 'Segera Hadir',
      'coming_soon_message': 'Fitur ini sedang dalam pengembangan.\nNantikan pembaruan selanjutnya!',
      
      // Home Page
      'home_headline': 'Temukan Gadget Impian Anda',
      'home_subheadline': 'Platform terlengkap untuk mencari, membandingkan, dan mendapat rekomendasi gadget terbaik dengan bantuan AI.',
      'home_cta': 'Mulai Jelajahi',
      'home_feature_ai_title': 'Rekomendasi AI',
      'home_feature_ai_desc': 'Dapatkan saran personal berdasarkan kebutuhan dan budget Anda.',
      'home_feature_compare_title': 'Bandingkan Spesifikasi',
      'home_feature_compare_desc': 'Komparasi head-to-head detail untuk keputusan terbaik.',
      'home_feature_search_title': 'Pencarian Pintar',
      'home_feature_search_desc': 'Cari gadget dengan filter spesifik dan harga akurat.',
      
      // Smart Recommendation Page
      'rec_title': 'Rekomendasi Cerdas',
      'rec_subtitle': 'Pilih target harga, dan biarkan AI kami menemukan produk dengan nilai terbaik untuk Anda.',
      'rec_label_budget': 'Budget (IDR)',
      'rec_label_type': 'Tipe Gadget',
      'rec_label_priority': 'Prioritas Utama',
      'rec_btn_get': 'Dapatkan Rekomendasi',
      'rec_result_title': 'Rekomendasi Terbaik Untuk Anda',
      'rec_score_value': 'Skor Value',
      'rec_score_spec': 'Skor Spesifikasi',
      'rec_pred_price': 'Harga Prediksi',
      'rec_act_price': 'Harga Aktual',
      'rec_diff': 'Selisih',
      'rec_good_deal': 'Good Deal!',
      'rec_fair_deal': 'Fair Price',
      'rec_bad_deal': 'Overpriced',
      'rec_initial_msg': 'Geser slider target harga untuk mendapatkan rekomendasi.',
      'rec_empty_msg': 'Tidak ada produk yang ditemukan di sekitar target harga ini.',
      
      // Browse Page
      'browse_title': 'Jelajahi Gadget',
      'browse_type_label': 'Tipe:',
      'browse_type_all': 'Semua',
      'browse_type_laptop': 'Laptop',
      'browse_type_smartphone': 'Smartphone',
      'browse_search_hint': 'Cari berdasarkan nama...',
      'browse_no_result': 'Tidak ada produk yang cocok.',
      'browse_error': 'Gagal memuat produk',
      
      // Compare Page
      'compare_title': 'Bandingkan Produk',
      'compare_subtitle': 'Pilih hingga 4 produk untuk melihat perbandingan spesifikasi secara detail.',
      'compare_search_hint': 'Cari produk untuk dibandingkan...',
      'compare_vs': 'VS',
      'compare_winner': 'Pemenang Spesifikasi',
      'compare_winner_desc': 'Berdasarkan analisis skor performa dan fitur.',
      'compare_spec_proc': 'Prosesor',
      'compare_spec_ram': 'RAM',
      'compare_spec_storage': 'Penyimpanan',
      'compare_spec_screen': 'Layar',
      'compare_spec_battery': 'Baterai',
      'compare_spec_cam': 'Kamera',
      'compare_add_product': 'Tambah Produk',
      'compare_select_product': 'Pilih Produk',
      'compare_select_brand': 'Pilih Brand',
      'compare_select_model': 'Pilih Model',
      'compare_instruction': 'Silakan pilih brand dan model produk untuk melihat spesifikasi detail.',
      
      // About Us Page
      'about_title': 'Tentang Kami',
      'about_subtitle': 'TechPilot adalah platform berbasis AI yang dirancang untuk membantu Anda menemukan laptop dan smartphone terbaik sesuai kebutuhan dan anggaran.',
      'about_desc_p1': 'Di era digital ini, memilih gadget yang tepat bisa menjadi membingungkan karena banyaknya pilihan yang tersedia. ',
      'about_desc_p2_1': 'Dengan menggunakan teknologi ',
      'about_desc_p2_ai': 'Artificial Intelligence (AI)',
      'about_desc_p2_and': ' dan ',
      'about_desc_p2_ml': 'Machine Learning',
      'about_desc_p2_2': ', TechPilot menganalisis ribuan spesifikasi produk, ulasan pengguna, dan tren pasar untuk memberikan rekomendasi yang tidak hanya akurat tetapi juga personal dan objektif.\n\n',
      'about_features_title': 'Fitur utama kami meliputi:',
      'about_feature_1': 'Rekomendasi Cerdas Berbasis AI',
      'about_feature_2': 'Perbandingan Produk Head-to-Head',
      'about_feature_3': 'Analisis Nilai Harga-ke-Performa',
      'about_feature_4': 'Pencarian Spesifikasi Mendalam',
      'about_closing': 'Kami berkomitmen untuk menyederhanakan proses pengambilan keputusan Anda dalam memilih gadget teknologi.',
      'about_team_title': 'Tim Pengembang',
      'about_opensource_title': 'Proyek Open Source',
      'about_opensource_desc': 'Kode sumber proyek ini tersedia untuk umum di GitHub.',
      'about_copy_link': 'Link GitHub disalin ke clipboard!',

      // AI Assistant Page
      'ai_title': 'Asisten AI',
      'ai_typing': 'Mengetik...',
      'ai_input_hint': 'Tanya rekomendasi (misal: "Laptop gaming 15jt")...',
      'ai_btn_send': 'Kirim',
    },
    'en': {
      // Navbar
      'nav_home': 'Home',
      'nav_browse': 'Browse',
      'nav_recommend': 'Recommendations',
      'nav_compare': 'Compare',
      'nav_ai': 'AI Assistant',
      
      // Footer
      'footer_about': 'About Us',
      'footer_suggest': 'Product Suggestion',
      'footer_partner': 'Partnership',
      'footer_contact': 'Contact Us',
      'coming_soon_title': 'Coming Soon',
      'coming_soon_message': 'This feature is under development.\nStay tuned for updates!',
      
      // Home Page
      'home_headline': 'Find Your Dream Gadget',
      'home_subheadline': 'The most comprehensive platform to search, compare, and get the best gadget recommendations with AI assistance.',
      'home_cta': 'Start Exploring',
      'home_feature_ai_title': 'AI Recommendations',
      'home_feature_ai_desc': 'Get personalized suggestions based on your needs and budget.',
      'home_feature_compare_title': 'Compare Specs',
      'home_feature_compare_desc': 'Detailed head-to-head comparison for the best decision.',
      'home_feature_search_title': 'Smart Search',
      'home_feature_search_desc': 'Search gadgets with specific filters and accurate pricing.',
      
      // Smart Recommendation Page
      'rec_title': 'Smart Recommendations',
      'rec_subtitle': 'Select your price target, and let our AI find the best value products for you.',
      'rec_label_budget': 'Budget (IDR)',
      'rec_label_type': 'Gadget Type',
      'rec_label_priority': 'Main Priority',
      'rec_btn_get': 'Get Recommendations',
      'rec_result_title': 'Best Recommendations For You',
      'rec_score_value': 'Value Score',
      'rec_score_spec': 'Spec Score',
      'rec_pred_price': 'Predicted Price',
      'rec_act_price': 'Actual Price',
      'rec_diff': 'Difference',
      'rec_good_deal': 'Good Deal!',
      'rec_fair_deal': 'Fair Price',
      'rec_bad_deal': 'Overpriced',
      'rec_initial_msg': 'Slide the price target to get recommendations.',
      'rec_empty_msg': 'No products found around this price target.',
      
      // Browse Page
      'browse_title': 'Browse Gadgets',
      'browse_type_label': 'Type:',
      'browse_type_all': 'All',
      'browse_type_laptop': 'Laptop',
      'browse_type_smartphone': 'Smartphone',
      'browse_search_hint': 'Search by name...',
      'browse_no_result': 'No matching products found.',
      'browse_error': 'Failed to load products',
      
      // Compare Page
      'compare_title': 'Compare Products',
      'compare_subtitle': 'Select up to 4 products to view detailed specification comparisons.',
      'compare_search_hint': 'Search products to compare...',
      'compare_vs': 'VS',
      'compare_winner': 'Spec Winner',
      'compare_winner_desc': 'Based on performance score and feature analysis.',
      'compare_spec_proc': 'Processor',
      'compare_spec_ram': 'RAM',
      'compare_spec_storage': 'Storage',
      'compare_spec_screen': 'Screen',
      'compare_spec_battery': 'Battery',
      'compare_spec_cam': 'Camera',
      'compare_add_product': 'Add Product',
      'compare_select_product': 'Select Product',
      'compare_select_brand': 'Select Brand',
      'compare_select_model': 'Select Model',
      'compare_instruction': 'Please select a brand and model to view detailed specifications.',
      
      // About Us Page
      'about_title': 'About Us',
      'about_subtitle': 'TechPilot is an AI-based platform designed to help you find the best laptop and smartphone according to your needs and budget.',
      'about_desc_p1': 'In this digital era, choosing the right gadget can be overwhelming due to the sheer number of options available. ',
      'about_desc_p2_1': 'Using ',
      'about_desc_p2_ai': 'Artificial Intelligence (AI)',
      'about_desc_p2_and': ' and ',
      'about_desc_p2_ml': 'Machine Learning',
      'about_desc_p2_2': ' technology, TechPilot analyzes thousands of product specifications, user reviews, and market trends to provide recommendations that are not only accurate but also personal and objective.\n\n',
      'about_features_title': 'Our key features include:',
      'about_feature_1': 'AI-based Smart Recommendations',
      'about_feature_2': 'Head-to-Head Product Comparison',
      'about_feature_3': 'Price-to-Performance Value Analysis',
      'about_feature_4': 'In-depth Specification Search',
      'about_closing': 'We are committed to simplifying your decision-making process in choosing technology gadgets.',
      'about_team_title': 'Development Team',
      'about_opensource_title': 'Open Source Project',
      'about_opensource_desc': 'The source code for this project is publicly available on GitHub.',
      'about_copy_link': 'GitHub link copied to clipboard!',

      // AI Assistant Page
      'ai_title': 'AI Assistant',
      'ai_typing': 'Typing...',
      'ai_input_hint': 'Ask for recommendation (e.g., "Gaming laptop 15m")...',
      'ai_btn_send': 'Send',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['id', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

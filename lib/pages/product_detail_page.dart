import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/recommended_product.dart';

class ProductDetailPage extends StatelessWidget {
  final RecommendedProduct product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(product.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 1,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return _buildWideLayout(context);
          } else {
            return _buildNarrowLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    final priceFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final scoreFormatter = NumberFormat.decimalPattern('id_ID');
    final hiddenSpecs = {'product_name', 'price', 'predicted_price', 'value_score_rp', 'cpu_score', 'gpu_score', 'chipset_score', 'clean_price', 'gpu_benchmark_match', 'raw_data', 'image'};

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _buildProductImageCard(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, "Skor Benchmark"),
                  _buildScoreCards(context, scoreFormatter),
                ],
              ),
            ),
            const SizedBox(width: 32),
            // Right Column
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.productName, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, "Analisis Harga & Performa"),
                  _buildAnalysisCards(context, priceFormatter),
                  const SizedBox(height: 12),
                  _buildValueScoreExplanation(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, "Spesifikasi Teknis"),
                  _buildSpecsTable(context, hiddenSpecs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    final priceFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final scoreFormatter = NumberFormat.decimalPattern('id_ID');
    final hiddenSpecs = {'product_name', 'price', 'predicted_price', 'value_score_rp', 'cpu_score', 'gpu_score', 'chipset_score', 'clean_price', 'gpu_benchmark_match', 'raw_data', 'image'};

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImageCard(context),
            const SizedBox(height: 16),
            Text(product.productName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
            const SizedBox(height: 24),
            _buildSectionTitle(context, "Analisis Harga & Performa"),
            _buildAnalysisCards(context, priceFormatter),
            const SizedBox(height: 12),
            _buildValueScoreExplanation(context),
            const SizedBox(height: 24),
            _buildSectionTitle(context, "Skor Benchmark"),
            _buildScoreCards(context, scoreFormatter),
            const SizedBox(height: 24),
            _buildSectionTitle(context, "Spesifikasi Teknis"),
            _buildSpecsTable(context, hiddenSpecs),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImageCard(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(24),
        color: Theme.of(context).cardColor,
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.asset(
            product.image,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              product.type == ProductType.laptop ? Icons.laptop_mac : Icons.phone_android,
              size: 100,
              color: Colors.grey[300],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color),
      ),
    );
  }

  Widget _buildAnalysisCards(BuildContext context, NumberFormat formatter) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0, // Changed from 1.2 to 1.0 for more vertical space
      ),
      children: [
        _buildInfoCard(context, "Harga Aktual", formatter.format(product.price), Icons.monetization_on_outlined, const Color(0xFFDC3545)),
        _buildInfoCard(context, "Prediksi Wajar", formatter.format(product.predictedPrice), Icons.online_prediction, const Color(0xFF28A745)),
        _buildInfoCard(context, "Value Score", formatter.format(product.valueScore), Icons.star_border, product.valueScore > 0 ? const Color(0xFF007BFF) : const Color(0xFF6C757D)),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Use min size
          children: [
            Icon(icon, color: color, size: 28), // Slightly smaller icon
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Expanded( // Allow text to take remaining space
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueScoreExplanation(BuildContext context) {
    bool isGoodValue = product.valueScore > 0;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isGoodValue 
            ? (isDarkMode ? const Color(0xFF1B4D2E) : const Color(0xFFE9F7EC)) 
            : (isDarkMode ? const Color(0xFF4C1D1D) : const Color(0xFFFDEEEE)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isGoodValue ? Icons.check_circle_outline : Icons.error_outline,
            color: isGoodValue ? const Color(0xFF28A745) : const Color(0xFFDC3545),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isGoodValue
                  ? "Harga lebih baik dari prediksi wajar."
                  : "Harga lebih mahal dari prediksi wajar.",
              style: TextStyle(
                fontSize: 14,
                color: isGoodValue 
                    ? (isDarkMode ? const Color(0xFFD4EDDA) : const Color(0xFF155724)) 
                    : (isDarkMode ? const Color(0xFFF8D7DA) : const Color(0xFF721C24)),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCards(BuildContext context, NumberFormat formatter) {
    List<Widget> cards = [];
    if (product.type == ProductType.laptop) {
      cards.add(_buildScoreGauge(context, "Skor CPU", product.cpuScore, 25000, const Color(0xFF007BFF)));
      cards.add(_buildScoreGauge(context, "Skor GPU", product.gpuScore, 25000, const Color(0xFF6F42C1)));
    } else if (product.type == ProductType.smartphone) {
      cards.add(_buildScoreGauge(context, "Skor Chipset", product.chipsetScore, 1500000, const Color(0xFFFD7E14)));
    }
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cards.length == 1 ? 1 : 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85, // Changed from 1 to 0.85 for more vertical space
      ),
      children: cards,
    );
  }

  Widget _buildScoreGauge(BuildContext context, String title, double? score, double maxScore, Color color) {
    final double normalizedScore = (score ?? 0) / maxScore;
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded( // Allow gauge to scale
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: normalizedScore),
                        duration: const Duration(milliseconds: 1200),
                        builder: (context, value, child) => CircularProgressIndicator(
                          value: value,
                          strokeWidth: 10,
                          backgroundColor: color.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                      Center(
                        child: Text(
                          score != null ? NumberFormat.compact().format(score) : 'N/A',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecsTable(BuildContext context, Set<String> hiddenSpecs) {
    final entries = product.rawData.entries
        .where((entry) => !hiddenSpecs.contains(entry.key) && entry.value != null && entry.value.toString().isNotEmpty)
        .toList();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).cardColor,
      child: Column(
        children: List.generate(entries.length, (index) {
          final entry = entries[index];
          final bgColor = index % 2 == 0 
              ? Theme.of(context).cardColor 
              : (isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FA));
              
          return Container(
            color: bgColor,
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.key.replaceAll('_', ' ').split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() + e.substring(1) : '').join(' '),
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(entry.value.toString(), style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/recommended_product.dart';

class ProductDetailPage extends StatelessWidget {
  final RecommendedProduct product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final scoreFormatter = NumberFormat.decimalPattern('id_ID');

    Widget buildSectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
        ),
      );
    }

    Widget buildProductHeader() {
      return SliverAppBar(
        expandedHeight: 250.0,
        pinned: true,
        backgroundColor: const Color(0xFF2c1810),
        foregroundColor: Colors.white,
        flexibleSpace: FlexibleSpaceBar(
          title: Text(product.productName, style: const TextStyle(fontSize: 16, color: Colors.white)),
          background: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Image.asset(
              product.image,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                product.type == ProductType.laptop ? Icons.laptop_mac : Icons.phone_android,
                size: 120,
                color: Colors.white70,
              ),
            ),
          ),
        ),
      );
    }

    Widget buildInfoCard(String title, String value, {Color valueColor = const Color(0xFFe74c3c)}) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: valueColor),
              ),
            ],
          ),
        ),
      );
    }
    
    Widget buildScoreCard(String title, double? score, String description) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Text(
                score != null ? scoreFormatter.format(score) : 'N/A',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3498db)),
              ),
              const SizedBox(height: 10),
              Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    List<Widget> buildScoreCards() {
      if (product.type == ProductType.laptop) {
        return [
          buildScoreCard("CPU Score", product.cpuScore, "Measures processor performance."),
          buildScoreCard("GPU Score", product.gpuScore, "Measures graphics performance."),
        ];
      } else if (product.type == ProductType.smartphone) {
        return [
          buildScoreCard("Chipset Score", product.chipsetScore, "Measures overall chipset performance (AnTuTu)."),
        ];
      }
      return [];
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          buildProductHeader(),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildSectionTitle("Analisis Harga & Performa"),
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 350,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 2.5,
                        ),
                        children: [
                          buildInfoCard("Harga Aktual", priceFormatter.format(product.price)),
                          buildInfoCard("Prediksi Harga Wajar", priceFormatter.format(product.predictedPrice), valueColor: const Color(0xFF27ae60)),
                          buildInfoCard(
                            "Value Score",
                            priceFormatter.format(product.valueScore),
                            valueColor: product.valueScore > 0 ? const Color(0xFF2980b9) : const Color(0xFFc0392b),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        product.valueScore > 0
                            ? "Produk ini memiliki harga lebih baik dari harga wajar yang diprediksi berdasarkan performanya."
                            : "Produk ini memiliki harga lebih mahal dari harga wajar yang diprediksi berdasarkan performanya.",
                        style: TextStyle(fontSize: 14, color: Colors.grey[700], fontStyle: FontStyle.italic),
                      ),
                      
                      buildSectionTitle("Skor Benchmark"),
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 2,
                        ),
                        children: buildScoreCards(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

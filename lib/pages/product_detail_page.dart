// lib/pages/product_detail_page.dart (Update: Gambar dari assets)
import 'package:flutter/material.dart';
import '../models/gadget.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatelessWidget {
  final Gadget gadget;

  const ProductDetailPage({super.key, required this.gadget});

  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final scoreFormatter = NumberFormat.decimalPattern('id_ID');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildProductHeader(context),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductOverview(context, priceFormatter),
                      const SizedBox(height: 40),
                      _buildSectionTitle("Spesifikasi Detail"),
                      const SizedBox(height: 20),
                      _buildSpecsGrid(context),
                      const SizedBox(height: 40),
                      _buildSectionTitle("🏆 Benchmark"),
                      const SizedBox(height: 20),
                      _buildBenchmarkGrid(context, scoreFormatter),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
      ),
    );
  }

  // Header with image from assets
  Widget _buildProductHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140.0,
      pinned: true,
      backgroundColor: const Color(0xFF2c1810),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Center(
          child: Image.asset(
            gadget.image,
            height: 120,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.phone_android, size: 120),
          ),
        ),
        title: Text(gadget.name, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

// ... (rest of the code remains the same)
}
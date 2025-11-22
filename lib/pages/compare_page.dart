import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/recommended_product.dart';

class ComparePage extends StatelessWidget {
  final List<RecommendedProduct> products;

  const ComparePage({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perbandingan Produk'),
        backgroundColor: const Color(0xFF2c1810),
        foregroundColor: Colors.white,
      ),
      body: products.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.compare_arrows_rounded, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Pilih Produk untuk Dibandingkan',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Buka halaman "Rekomendasi Cerdas", cari produk, lalu pilih beberapa item untuk dibandingkan di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, '/rekomendasi', (route) => false);
                      },
                      child: const Text('Buka Rekomendasi'),
                    )
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildCompareTable(context),
              ),
            ),
    );
  }

  Widget _buildCompareTable(BuildContext context) {
    final priceFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final scoreFormatter = NumberFormat.decimalPattern('id_ID');

    // Define the rows for the comparison table
    final rows = [
      _buildSpecRow('Harga', (p) => priceFormatter.format(p.price)),
      _buildSpecRow('Prediksi Harga', (p) => priceFormatter.format(p.predictedPrice)),
      _buildSpecRow('Value Score', (p) => priceFormatter.format(p.valueScore)),
      if (products.any((p) => p.type == ProductType.laptop))
        _buildSpecRow('CPU Score', (p) => p.cpuScore != null ? scoreFormatter.format(p.cpuScore) : '-'),
      if (products.any((p) => p.type == ProductType.laptop))
        _buildSpecRow('GPU Score', (p) => p.gpuScore != null ? scoreFormatter.format(p.gpuScore) : '-'),
      if (products.any((p) => p.type == ProductType.smartphone))
        _buildSpecRow('Chipset Score', (p) => p.chipsetScore != null ? scoreFormatter.format(p.chipsetScore) : '-'),
    ];

    return DataTable(
      columnSpacing: 24,
      columns: [
        const DataColumn(label: Text('Spesifikasi', style: TextStyle(fontWeight: FontWeight.bold))),
        ...products.map((p) => DataColumn(
          label: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.productName, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                Image.asset(p.image, height: 60, errorBuilder: (_,__,___) => const SizedBox(height: 60)),
              ],
            ),
          ),
        )).toList(),
      ],
      rows: rows,
    );
  }

  DataRow _buildSpecRow(String title, String Function(RecommendedProduct) getValue) {
    return DataRow(
      cells: [
        DataCell(Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
        ...products.map((p) => DataCell(Text(getValue(p)))).toList(),
      ],
    );
  }
}

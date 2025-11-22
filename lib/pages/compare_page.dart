import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/compare_cubit.dart';
import '../models/compared_product.dart';
import '../models/recommended_product.dart';

class ComparePage extends StatelessWidget {
  final List<RecommendedProduct> products;

  const ComparePage({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    // Membuat Cubit dan langsung memberikan produk yang akan dibandingkan
    return BlocProvider(
      create: (context) => CompareCubit(productsToCompare: products),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hasil Perbandingan Cerdas'),
          backgroundColor: const Color(0xFF2c1810),
          foregroundColor: Colors.white,
        ),
        body: const ComparisonResultView(),
      ),
    );
  }
}

class ComparisonResultView extends StatelessWidget {
  const ComparisonResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompareCubit, CompareState>(
      builder: (context, state) {
        switch (state.status) {
          case ComparisonStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case ComparisonStatus.error:
            return Center(child: Text('Gagal memuat perbandingan: ${state.errorMessage}'));
          case ComparisonStatus.loaded:
            if (state.results.isEmpty) {
              return const Center(child: Text('Tidak ada data untuk ditampilkan.'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildComparisonTable(state.results),
              ),
            );
        }
      },
    );
  }

  Widget _buildComparisonTable(List<ComparedProduct> results) {
    final isLaptop = results.any((p) => p.type == 'laptop');
    
    final rows = [
      _buildResultRow('Harga', results.map((r) => r.price).toList()),
      if (isLaptop) _buildResultRow('Skor CPU', results.map((r) => r.cpuScore).toList()),
      if (isLaptop) _buildResultRow('Skor GPU', results.map((r) => r.gpuScore).toList()),
      if (!isLaptop) _buildResultRow('Skor Chipset', results.map((r) => r.chipsetScore).toList()),
    ];

    return DataTable(
      columns: [
        const DataColumn(label: Text('Metrik', style: TextStyle(fontWeight: FontWeight.bold))),
        ...results.map((r) => DataColumn(label: Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis))),
      ],
      rows: rows,
    );
  }

  DataRow _buildResultRow(String title, List<ComparisonValue?> values) {
    final formatter = NumberFormat.decimalPattern('id_ID');
    return DataRow(
      cells: [
        DataCell(Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
        ...values.map((v) {
          if (v == null) return const DataCell(Text('-'));
          
          Color color = Colors.transparent;
          IconData? icon;
          if (v.status == 'best') {
            color = Colors.green.withOpacity(0.1);
            icon = Icons.check_circle;
          } else if (v.status == 'worst') {
            color = Colors.red.withOpacity(0.1);
            icon = Icons.cancel;
          }

          return DataCell(
            Container(
              color: color,
              child: Tooltip(
                message: v.reason,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) Icon(icon, color: color.withOpacity(1), size: 16),
                      if (icon != null) const SizedBox(width: 4),
                      Text(formatter.format(v.value)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

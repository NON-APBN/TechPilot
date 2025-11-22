import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/smart_recommendation_cubit.dart';
import '../widgets/recommended_product_list_item.dart';
import 'compare_page.dart';

class SmartRecommendationPage extends StatelessWidget {
  const SmartRecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SmartRecommendationCubit(),
      child: const SmartRecommendationView(),
    );
  }
}

class SmartRecommendationView extends StatelessWidget {
  const SmartRecommendationView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const [
        Text('Rekomendasi Cerdas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Dapatkan rekomendasi produk terbaik berdasarkan performa dan harga dari model AI kami.', style: TextStyle(fontSize: 14, color: Colors.grey)),
        SizedBox(height: 20),
        FilterControls(),
        SizedBox(height: 24),
        RecommendationResults(),
      ],
    );
  }
}

class FilterControls extends StatelessWidget {
  const FilterControls({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmartRecommendationCubit, SmartRecommendationState>(
      buildWhen: (p, c) => p.type != c.type || p.minBudget != c.minBudget || p.maxBudget != c.maxBudget,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(25), // 0.1 opacity
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Selection
              const Text('Tipe Produk', style: TextStyle(fontWeight: FontWeight.w600)),
              DropdownButton<String>(
                value: state.type,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'laptop', child: Text('Laptop')),
                  DropdownMenuItem(value: 'smartphone', child: Text('Smartphone')),
                ],
                onChanged: (v) => context.read<SmartRecommendationCubit>().setType(v!),
              ),
              const SizedBox(height: 16),

              // Budget Range Selection
              const Text('Rentang Budget', style: TextStyle(fontWeight: FontWeight.w600)),
              RangeSlider(
                values: RangeValues(state.minBudget, state.maxBudget),
                min: 1,
                max: 50,
                divisions: 49,
                labels: RangeLabels(
                  '${state.minBudget.toStringAsFixed(0)} jt',
                  '${state.maxBudget.toStringAsFixed(0)} jt',
                ),
                onChanged: (values) {
                  context.read<SmartRecommendationCubit>().setBudgetRange(values.start, values.end);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rp ${state.minBudget.toStringAsFixed(0)} jt'),
                  Text('Rp ${state.maxBudget.toStringAsFixed(0)} jt'),
                ],
              ),
              const SizedBox(height: 24),

              // Action Button
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Cari Rekomendasi'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    context.read<SmartRecommendationCubit>().fetchRecommendations();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RecommendationResults extends StatelessWidget {
  const RecommendationResults({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmartRecommendationCubit, SmartRecommendationState>(
      builder: (context, state) {
        final selection = state.comparisonSelection;

        return Column(
          children: [
            if (selection.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ComparePage(products: selection.toList()),
                      ),
                    );
                  },
                  icon: const Icon(Icons.compare_arrows),
                  label: Text('Bandingkan (${selection.length} item)'),
                ),
              ),
            _buildResults(context, state),
          ],
        );
      },
    );
  }

  Widget _buildResults(BuildContext context, SmartRecommendationState state) {
    switch (state.status) {
      case RecommendationStatus.initial:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('Atur filter dan klik "Cari Rekomendasi" untuk memulai.', textAlign: TextAlign.center),
          ),
        );
      case RecommendationStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case RecommendationStatus.failure:
        return Center(
          child: Text(
            'Gagal memuat rekomendasi:\n${state.errorMessage}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        );
      case RecommendationStatus.success:
        if (state.results.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Tidak ada produk yang ditemukan untuk kriteria Anda. Coba ubah rentang budget.', textAlign: TextAlign.center),
            ),
          );
        }
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: state.results.length,
          itemBuilder: (_, i) {
            final product = state.results[i];
            final isSelected = state.comparisonSelection.contains(product);
            return RecommendedProductListItem(
              product: product,
              isSelected: isSelected,
              onSelected: () => context.read<SmartRecommendationCubit>().toggleCompareSelection(product),
            );
          },
        );
    }
  }
}

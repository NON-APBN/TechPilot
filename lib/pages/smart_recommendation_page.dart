// lib/pages/smart_recommendation_page.dart (Update: Integrasi fetchRank)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/smart_recommendation_cubit.dart';
import '../shared/http_helper.dart';
import '../widgets/gadget_list_item.dart';

class SmartRecommendationPage extends StatelessWidget {
  final bool showCompareHint;
  const SmartRecommendationPage({super.key, this.showCompareHint = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SmartRecommendationCubit(),
      child: SmartRecommendationView(showCompareHint: showCompareHint),
    );
  }
}

class SmartRecommendationView extends StatelessWidget {
  final bool showCompareHint;
  const SmartRecommendationView({super.key, required this.showCompareHint});

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 760;

    return ListView(
      children: [
        const Text('Rekomendasi Pintar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        if (showCompareHint)
          const Padding(
            padding: EdgeInsets.only(top: 6.0, bottom: 8),
            child: Text('Tips: pilih 2–3 item dari hasil untuk dibandingkan side-by-side.'),
          ),
        const SizedBox(height: 12),
        const FilterControls(),
        const SizedBox(height: 16),
        const FilterResults(),
        const SizedBox(height: 24),
      ],
    );
  }
}

class FilterControls extends StatelessWidget {
  const FilterControls({super.key});

  Widget _chip(BuildContext context, String label, Set<String> currentNeeds) {
    final selected = currentNeeds.contains(label);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => context.read<SmartRecommendationCubit>().toggleNeed(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmartRecommendationCubit, SmartRecommendationState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Jenis Gadget:'),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: state.type,
              items: const [
                DropdownMenuItem(value: 'smartphone', child: Text('Smartphone')),
                DropdownMenuItem(value: 'laptop', child: Text('Laptop')),
              ],
              onChanged: (v) => context.read<SmartRecommendationCubit>().setType(v!),
            ),
            const SizedBox(height: 12),
            const Text('Budget Maksimal (juta Rp):'),
            Slider(
              value: state.budget,
              min: 2, max: 40, divisions: 38,
              label: '${state.budget.toStringAsFixed(0)} jt',
              onChanged: (v) => context.read<SmartRecommendationCubit>().setBudget(v),
            ),
            Text('${state.budget.toStringAsFixed(0)} jt'),
          ],
        );
      },
    );
  }
}

class FilterResults extends StatelessWidget {
  const FilterResults({super.key});

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 760;
    return BlocBuilder<SmartRecommendationCubit, SmartRecommendationState>(
      builder: (context, state) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchRank(state.type, 0, (state.budget * 1000000).toInt()),  // Min 0, max budget
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final items = snapshot.data ?? [];
            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isNarrow ? 1 : 2,
                crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: 180,
              ),
              itemBuilder: (_, i) {
                final g = items[i];
                return GadgetListItem(
                  gadget: Gadget(
                    id: g['rank'],
                    name: g['device_name'],
                    type: state.type,
                    price: g['harga_rp'].toDouble(),
                    processor: '',  // Tambah jika backend kirim
                    storage: '',
                    screen: '',
                    battery: '',
                    camera: '',
                    weight: '',
                    rating: 0.0,
                    image: 'assets/images/${g['device_name'].toLowerCase().replaceAll(' ', '_')}.jpg',
                    isPopular: false,
                    isNewest: false,
                    ramDetails: const RamDetails(capacity: '', type: ''),
                    cpuDetails: const CpuDetails(),
                    benchmarks: const BenchmarkScores(),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
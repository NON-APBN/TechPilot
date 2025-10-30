
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/smart_recommendation_cubit.dart';
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
        const FilterControls(), // Widget untuk semua kontrol filter
        const SizedBox(height: 16),
        const FilterResults(), // Widget untuk menampilkan hasil filter
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
      // Hanya build ulang jika filter berubah, bukan hasil
      buildWhen: (p, c) => p.type != c.type || p.budget != c.budget || p.needs != c.needs,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Tipe: '),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: state.type,
                      items: const [
                        DropdownMenuItem(value: 'smartphone', child: Text('Smartphone')),
                        DropdownMenuItem(value: 'laptop', child: Text('Laptop')),
                      ],
                      onChanged: (v) => context.read<SmartRecommendationCubit>().setType(v!),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Budget: '),
                    Slider(
                      value: state.budget,
                      min: 2, max: 40, divisions: 38,
                      label: '${state.budget.toStringAsFixed(0)} jt',
                      onChanged: (v) => context.read<SmartRecommendationCubit>().setBudget(v),
                    ),
                    Text('${state.budget.toStringAsFixed(0)} jt'),
                  ]),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Kebutuhan:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _chip(context, 'gaming', state.needs),
                  _chip(context, 'kamera', state.needs),
                  _chip(context, 'baterai', state.needs),
                  _chip(context, 'ringan', state.needs),
                  _chip(context, 'layar', state.needs),
                  _chip(context, 'render', state.needs),
                  _chip(context, 'ai', state.needs),
                ],
              ),
            ],
          ),
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
      // Hanya build ulang jika hasil berubah
      buildWhen: (p, c) => p.results != c.results,
      builder: (context, state) {
        if (state.results.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('Tidak ada hasil. Coba naikkan budget atau ubah kebutuhan.'),
          );
        }
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: state.results.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isNarrow ? 1 : 2,
            crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: 180,
          ),
          itemBuilder: (_, i) {
            final g = state.results[i];
            return GadgetListItem(gadget: g);
          },
        );
      },
    );
  }
}

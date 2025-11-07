
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
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
    return ListView(
      children: [
        Text('Rekomendasi Pintar', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800)),
        if (showCompareHint)
          Padding(
            padding: EdgeInsets.only(top: 1.h, bottom: 1.h),
            child: const Text('Tips: pilih 2–3 item dari hasil untuk dibandingkan side-by-side.'),
          ),
        SizedBox(height: 1.5.h),
        const FilterControls(), // Widget untuk semua kontrol filter
        SizedBox(height: 2.h),
        const FilterResults(), // Widget untuk menampilkan hasil filter
        SizedBox(height: 3.h),
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
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.sp)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 4.w, runSpacing: 1.5.h, crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Tipe: '),
                    SizedBox(width: 2.w),
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
              SizedBox(height: 1.5.h),
              const Text('Kebutuhan:'),
              SizedBox(height: 1.h),
              Wrap(
                spacing: 2.w,
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
    final isNarrow = 100.w < 760;
    return BlocBuilder<SmartRecommendationCubit, SmartRecommendationState>(
      // Hanya build ulang jika hasil berubah
      buildWhen: (p, c) => p.results != c.results,
      builder: (context, state) {
        if (state.results.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: const Text('Tidak ada hasil. Coba naikkan budget atau ubah kebutuhan.'),
          );
        }
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: state.results.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isNarrow ? 1 : 2,
            crossAxisSpacing: 3.w, mainAxisSpacing: 1.5.h, mainAxisExtent: 22.h,
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

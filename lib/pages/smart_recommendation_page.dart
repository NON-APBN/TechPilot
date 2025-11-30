import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../cubit/smart_recommendation_cubit.dart';
import '../widgets/recommended_product_list_item.dart';
import '../widgets/footer.dart';
import '../shared/app_localizations.dart';

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
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).get('rec_title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)).animate().fade().slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 8),
                    Text(AppLocalizations.of(context).get('rec_subtitle'), style: const TextStyle(fontSize: 14, color: Colors.grey)).animate(delay: 100.ms).fade(),
                    const SizedBox(height: 20),
                    const FilterControls().animate(delay: 200.ms).fade().slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 24),
                    const RecommendationResults(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: [
              const Spacer(),
              const Footer().animate(delay: 400.ms).fade(),
            ],
          ),
        ),
      ],
    );
  }
}

class FilterControls extends StatelessWidget {
  const FilterControls({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return BlocBuilder<SmartRecommendationCubit, SmartRecommendationState>(
      buildWhen: (p, c) => p.type != c.type || p.targetBudget != c.targetBudget,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).get('rec_label_type'), style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
              DropdownButton<String>(
                value: state.type,
                isExpanded: true,
                dropdownColor: cardColor,
                style: TextStyle(color: textColor),
                items: [
                  DropdownMenuItem(value: 'laptop', child: Text('Laptop', style: TextStyle(color: textColor))),
                  DropdownMenuItem(value: 'smartphone', child: Text('Smartphone', style: TextStyle(color: textColor))),
                ],
                onChanged: (v) => context.read<SmartRecommendationCubit>().setType(v!),
              ),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context).get('rec_label_budget'), style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
              Slider(
                value: state.targetBudget,
                min: 1,
                max: 50,
                divisions: 49,
                label: 'Rp ${state.targetBudget.toStringAsFixed(0)} jt',
                onChanged: (value) {
                  context.read<SmartRecommendationCubit>().setTargetBudget(value);
                },
                onChangeEnd: (value) {
                  context.read<SmartRecommendationCubit>().fetchRecommendations();
                },
              ),
              Center(child: Text('Sekitar Rp ${state.targetBudget.toStringAsFixed(0)} jutaan', style: TextStyle(fontSize: 16, color: textColor))),
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
        switch (state.status) {
          case RecommendationStatus.initial:
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(AppLocalizations.of(context).get('rec_initial_msg'), textAlign: TextAlign.center),
              ),
            );
          case RecommendationStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case RecommendationStatus.failure:
            return Center(
              child: Text(
                '${AppLocalizations.of(context).get('browse_error')}:\n${state.errorMessage}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          case RecommendationStatus.success:
            if (state.results.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(AppLocalizations.of(context).get('rec_empty_msg'), textAlign: TextAlign.center),
                ),
              );
            }
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: state.results.length,
              itemBuilder: (_, i) {
                final product = state.results[i];
                return RecommendedProductListItem(
                  product: product,
                  rank: i + 1,
                ).animate(delay: (100 * i).ms).fade().slideX(begin: 0.1, end: 0);
              },
            );
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../cubit/gadget_browser_cubit.dart';
import '../cubit/gadget_browser_cubit.dart';
import '../widgets/product_card.dart';
import '../widgets/footer.dart';
import '../shared/app_localizations.dart';

class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GadgetBrowserCubit(),
      child: const BrowseView(),
    );
  }
}

class BrowseView extends StatefulWidget {
  const BrowseView({super.key});

  @override
  State<BrowseView> createState() => _BrowseViewState();
}

class _BrowseViewState extends State<BrowseView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).get('browse_title')),
        backgroundColor: theme.cardColor,
        foregroundColor: theme.textTheme.bodyLarge?.color,
        elevation: 1,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    children: [
                      // Filter & Search Bar
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Type Filter
                            Row(
                              children: [
                                Text(AppLocalizations.of(context).get('browse_type_label'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 12),
                                BlocBuilder<GadgetBrowserCubit, GadgetBrowserState>(
                                  buildWhen: (previous, current) => previous.type != current.type,
                                  builder: (context, state) {
                                    return Wrap(
                                      spacing: 8,
                                      children: [
                                        _FilterChip(
                                          label: AppLocalizations.of(context).get('browse_type_all'),
                                          selected: state.type == 'semua',
                                          onSelected: (b) {
                                            if (b) context.read<GadgetBrowserCubit>().setType('semua');
                                          },
                                        ),
                                        _FilterChip(
                                          label: AppLocalizations.of(context).get('browse_type_laptop'),
                                          selected: state.type == 'laptop',
                                          onSelected: (b) {
                                            if (b) context.read<GadgetBrowserCubit>().setType('laptop');
                                          },
                                        ),
                                        _FilterChip(
                                          label: AppLocalizations.of(context).get('browse_type_smartphone'),
                                          selected: state.type == 'smartphone',
                                          onSelected: (b) {
                                            if (b) context.read<GadgetBrowserCubit>().setType('smartphone');
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Search Field
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context).get('browse_search_hint'),
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onChanged: (value) {
                                context.read<GadgetBrowserCubit>().setQuery(value);
                              },
                            ),
                          ],
                        ),
                      ).animate().fade().slideY(begin: -0.2, end: 0),
                      
                      const SizedBox(height: 24),

                      // Product Grid
                      BlocBuilder<GadgetBrowserCubit, GadgetBrowserState>(
                        builder: (context, state) {
                          if (state.status == GadgetBrowserStatus.loading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (state.errorMessage != null) {
                            return Center(child: Text(state.errorMessage!));
                          }

                          if (state.items.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                                  const SizedBox(height: 16),
                                  Text(AppLocalizations.of(context).get('browse_no_result'), style: const TextStyle(fontSize: 18, color: Colors.grey)),
                                ],
                              ),
                            );
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 300,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: state.items.length,
                            itemBuilder: (context, index) {
                              final product = state.items[index];
                              return ProductCard(product: product)
                                .animate(delay: (50 * index).ms).fade().slideX(begin: 0.1, end: 0);
                            },
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Pagination
                      const PaginationControls(),
                      
                      const SizedBox(height: 24),
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
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }
}

// --- WIDGET BARU UNTUK PAGINASI ---
class PaginationControls extends StatelessWidget {
  const PaginationControls({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GadgetBrowserCubit, GadgetBrowserState>(
      builder: (context, state) {
        if (state.totalPages <= 1) {
          return const SizedBox.shrink(); // Sembunyikan jika hanya ada 1 halaman atau kurang
        }

        // Fungsi untuk membuat tombol halaman
        Widget pageButton(int page, {bool isCurrent = false}) {
          return SizedBox(
            width: 40,
            height: 40,
            child: TextButton(
              onPressed: isCurrent ? null : () => context.read<GadgetBrowserCubit>().goToPage(page),
              style: TextButton.styleFrom(
                backgroundColor: isCurrent ? Theme.of(context).colorScheme.primary : Colors.white,
                foregroundColor: isCurrent ? Colors.white : Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('$page'),
            ),
          );
        }

        List<Widget> generatePageButtons() {
          final List<Widget> buttons = [];
          final int currentPage = state.currentPage;
          final int totalPages = state.totalPages;

          // Tombol 'Sebelumnya'
          if (currentPage > 1) {
            buttons.add(
              TextButton(
                onPressed: () => context.read<GadgetBrowserCubit>().goToPage(currentPage - 1),
                child: const Text('‹ Prev'),
              ),
            );
          }

          // Logika untuk menampilkan tombol halaman (misal: 1 ... 4 5 6 ... 10)
          if (totalPages <= 7) {
            for (int i = 1; i <= totalPages; i++) {
              buttons.add(pageButton(i, isCurrent: i == currentPage));
            }
          } else {
            buttons.add(pageButton(1, isCurrent: 1 == currentPage));
            if (currentPage > 3) buttons.add(const Text('...'));

            if (currentPage > 2) buttons.add(pageButton(currentPage - 1));
            if (currentPage != 1 && currentPage != totalPages) buttons.add(pageButton(currentPage, isCurrent: true));
            if (currentPage < totalPages - 1) buttons.add(pageButton(currentPage + 1));

            if (currentPage < totalPages - 2) buttons.add(const Text('...'));
            buttons.add(pageButton(totalPages, isCurrent: totalPages == currentPage));
          }

          // Tombol 'Berikutnya'
          if (currentPage < totalPages) {
            buttons.add(
              TextButton(
                onPressed: () => context.read<GadgetBrowserCubit>().goToPage(currentPage + 1),
                child: const Text('Next ›'),
              ),
            );
          }
          return buttons;
        }

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: generatePageButtons(),
        );
      },
    );
  }
}

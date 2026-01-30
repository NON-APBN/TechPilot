import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../cubit/compare_cubit.dart';
import '../cubit/compare_state.dart';
import '../models/catalog_product.dart';
import '../widgets/footer.dart';
import '../shared/app_localizations.dart';

class ComparePage extends StatelessWidget {
  const ComparePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompareCubit(),
      child: const CompareView(),
    );
  }
}

class CompareView extends StatelessWidget {
  const CompareView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<CompareCubit, CompareState>(
          builder: (context, state) {
            return Row(
              children: [
                Text(AppLocalizations.of(context).get('compare_title')),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: state.selectedType,
                      icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).iconTheme.color),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      dropdownColor: Theme.of(context).cardColor,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          context.read<CompareCubit>().changeProductType(newValue);
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: 'smartphone', 
                          child: Text(AppLocalizations.of(context).get('browse_type_smartphone'), style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        DropdownMenuItem(
                          value: 'laptop', 
                          child: Text(AppLocalizations.of(context).get('browse_type_laptop'), style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: BlocBuilder<CompareCubit, CompareState>(
        builder: (context, state) {
          if (state.status == CompareStatus.loading && state.availableProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == CompareStatus.error) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...List.generate(state.selectedProducts.length, (index) {
                                  return Container(
                                    width: 300, // Lebar tetap untuk setiap kartu
                                    margin: const EdgeInsets.only(right: 8),
                                    child: _ProductComparisonCard(
                                      index: index,
                                      selectedProduct: state.selectedProducts[index],
                                      availableProducts: state.availableProducts,
                                      onProductChanged: (product) {
                                        context.read<CompareCubit>().onProductSelected(index, product);
                                      },
                                    ),
                                  ).animate(delay: (200 * index).ms).fade().slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
                                }),
                                if (state.selectedProducts.length < 4)
                                  Container(
                                    width: 100,
                                    height: 300, // Sesuaikan tinggi kira-kira
                                    alignment: Alignment.center,
                                    child: FloatingActionButton(
                                      onPressed: () => context.read<CompareCubit>().addProductSlot(),
                                      child: const Icon(Icons.add),
                                      tooltip: AppLocalizations.of(context).get('compare_add_product'),
                                    ),
                                  ).animate(delay: 600.ms).scale(curve: Curves.elasticOut),
                              ],
                            ),
                          ),
                          // Comparison Result (Winner)
                          if (state.selectedProducts.where((p) => p != null).length >= 2)
                            _ComparisonResult(
                              p1: state.selectedProducts.where((p) => p != null).toList()[0]!,
                              p2: state.selectedProducts.where((p) => p != null).toList()[1]!,
                            ).animate(delay: 800.ms).fade().slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
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
                    const Footer().animate(delay: 1000.ms).fade(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductComparisonCard extends StatefulWidget {
  final int index;
  final CatalogProduct? selectedProduct;
  final List<CatalogProduct> availableProducts;
  final ValueChanged<CatalogProduct?> onProductChanged;

  const _ProductComparisonCard({
    required this.index,
    required this.selectedProduct,
    required this.availableProducts,
    required this.onProductChanged,
  });

  @override
  State<_ProductComparisonCard> createState() => _ProductComparisonCardState();
}

class _ProductComparisonCardState extends State<_ProductComparisonCard> {
  String? _selectedBrand;

  @override
  void initState() {
    super.initState();
    _updateSelectedBrand();
  }

  @override
  void didUpdateWidget(covariant _ProductComparisonCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedProduct != oldWidget.selectedProduct || 
        widget.availableProducts != oldWidget.availableProducts) {
      _updateSelectedBrand();
    }
  }

  void _updateSelectedBrand() {
    if (widget.selectedProduct != null) {
      _selectedBrand = widget.selectedProduct!.brand;
    } else if (_selectedBrand != null && 
               !widget.availableProducts.any((p) => p.brand == _selectedBrand)) {
       // Reset brand if it no longer exists in available products (e.g. switched type)
       _selectedBrand = null;
    }
  }

  List<String> get _brands {
    final brands = widget.availableProducts.map((p) => p.brand).toSet().toList();
    brands.sort();
    return brands;
  }

  List<CatalogProduct> get _filteredProducts {
    if (_selectedBrand == null) return [];
    return widget.availableProducts
        .where((p) => p.brand == _selectedBrand)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: theme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Image and Dropdowns
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Column(
              children: [
                if (widget.selectedProduct != null)
                  Container(
                    height: 140,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Image.asset(
                      widget.selectedProduct!.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          widget.selectedProduct!.type == 'laptop' 
                              ? Icons.laptop_mac 
                              : Icons.phone_android,
                          size: 80,
                          color: Colors.grey[300],
                        );
                      },
                    ),
                  ).animate(key: ValueKey(widget.selectedProduct!.name)).fade().scale()
                else
                  Container(
                    height: 140,
                    margin: const EdgeInsets.only(bottom: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, size: 40, color: theme.brightness == Brightness.dark ? Colors.white : Colors.black54),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context).get('compare_select_product'),
                          style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                
                // Brand Dropdown
                _buildModernDropdown(
                  value: _selectedBrand,
                  hint: AppLocalizations.of(context).get('compare_select_brand'),
                  items: _brands,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBrand = newValue;
                    });
                    widget.onProductChanged(null);
                  },
                ),
                const SizedBox(height: 12),
                // Product Dropdown
                _buildModernDropdown(
                  value: widget.selectedProduct,
                  hint: AppLocalizations.of(context).get('compare_select_model'),
                  items: _filteredProducts,
                  onChanged: _selectedBrand == null ? null : widget.onProductChanged,
                  isProduct: true,
                ),
              ],
            ),
          ),
          // Konten Produk
          widget.selectedProduct != null
              ? _ProductDetails(product: widget.selectedProduct!)
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      AppLocalizations.of(context).get('compare_instruction'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildModernDropdown<T>({
    required T? value,
    required String hint,
    required List<dynamic> items,
    required ValueChanged<T?>? onChanged,
    bool isProduct = false,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: onChanged == null 
            ? (theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey.shade50) 
            : theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: TextStyle(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black, fontSize: 14)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
          dropdownColor: theme.cardColor,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item as T,
              child: Text(
                isProduct ? (item as CatalogProduct).name : item.toString(),
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ComparisonResult extends StatelessWidget {
  final CatalogProduct p1;
  final CatalogProduct p2;

  const _ComparisonResult({required this.p1, required this.p2});

  @override
  Widget build(BuildContext context) {
    // Simple Logic: Higher Benchmark / Price Ratio is better
    // Price needs to be parsed safely
    double getPrice(CatalogProduct p) {
      final priceVal = p.type == 'laptop' ? p.rawData['price_idr'] : p.rawData['Estimated_Price'];
      if (priceVal == null) return 1.0;
      final priceStr = priceVal.toString().replaceAll(RegExp(r'[^0-9]'), '');
      return double.tryParse(priceStr) ?? 1.0;
    }

    final price1 = getPrice(p1);
    final price2 = getPrice(p2);
    final score1 = (p1.benchmarkScore ?? 0).toDouble();
    final score2 = (p2.benchmarkScore ?? 0).toDouble();

    // Avoid division by zero
    final ratio1 = price1 > 0 ? score1 / price1 : 0;
    final ratio2 = price2 > 0 ? score2 / price2 : 0;

    CatalogProduct? winner;
    String reason = "";

    if (score1 == 0 && score2 == 0) {
      winner = null;
      reason = AppLocalizations.of(context).get('compare_no_benchmark');
    } else if (price1 <= 1.0 && price2 <= 1.0) {
      // Both prices invalid
      winner = null; 
      reason = AppLocalizations.of(context).get('compare_no_price_data'); // Ensure this key exists or add fallback
    } else if (price1 <= 1.0) {
      // P1 price invalid -> P2 wins if it has score
      if (score2 > 0) {
         winner = p2;
         reason = AppLocalizations.of(context).get('compare_better_value_vs_unknown'); // "Better value (vs Unknown Price)"
      } else {
         winner = null;
          reason = AppLocalizations.of(context).get('compare_insufficient_data');
      }
    } else if (price2 <= 1.0) {
      // P2 price invalid -> P1 wins if it has score
      if (score1 > 0) {
         winner = p1;
         reason = AppLocalizations.of(context).get('compare_better_value_vs_unknown');
      } else {
         winner = null;
         reason = AppLocalizations.of(context).get('compare_insufficient_data');
      }
    } else if (ratio1 > ratio2) {
      winner = p1;
      reason = "${AppLocalizations.of(context).get('compare_better_value')} (${(ratio1 * 1000000).toStringAsFixed(1)} vs ${(ratio2 * 1000000).toStringAsFixed(1)}).";
    } else {
      winner = p2;
      reason = "${AppLocalizations.of(context).get('compare_better_value')} (${(ratio2 * 1000000).toStringAsFixed(1)} vs ${(ratio1 * 1000000).toStringAsFixed(1)}).";
    }

    if (winner == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context).get('compare_ai_recommendation'),
            style: const TextStyle(color: Colors.white70, letterSpacing: 1.2, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).get('compare_winner'),
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(winner.image, errorBuilder: (_,__,___) => const Icon(Icons.emoji_events, size: 40, color: Colors.amber)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            winner.name,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              reason,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductDetails extends StatelessWidget {
  final CatalogProduct product;

  const _ProductDetails({required this.product});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> displaySpecs = {};

    if (product.type == 'smartphone') {
      displaySpecs['Brand'] = product.rawData['Brand']?.toString() ?? '-';
      displaySpecs['Model'] = product.rawData['Device Name']?.toString() ?? '-';
      displaySpecs['Harga'] = product.rawData['Estimated_Price']?.toString() ?? '-';
      displaySpecs['Baterai'] = product.rawData['Battery_Type']?.toString() ?? '-';
      displaySpecs['Dimensi'] = product.rawData['Body_Dimensions']?.toString() ?? '-';
      displaySpecs['Layar'] = product.rawData['Display_Type']?.toString() ?? '-';
      displaySpecs['Rilis'] = product.rawData['Launch_Announced']?.toString() ?? '-';
      
      String mainCam = product.rawData['MainCamera_Spec']?.toString() ?? '';
      String selfieCam = product.rawData['SelfieCamera_Spec']?.toString() ?? '';
      displaySpecs['Kamera'] = 'Main: $mainCam\nSelfie: $selfieCam';
      
      displaySpecs['Memori'] = product.rawData['Memory_Internal']?.toString() ?? '-';
      
      String chipset = product.rawData['Platform_Chipset']?.toString() ?? '';
      String cpu = product.rawData['Platform_CPU']?.toString() ?? '';
      displaySpecs['Platform'] = '$chipset\n$cpu';

    } else if (product.type == 'laptop') {
      displaySpecs['Brand'] = product.rawData['brand']?.toString() ?? '-';
      displaySpecs['Model'] = product.rawData['model']?.toString() ?? '-';
      displaySpecs['Harga'] = product.rawData['price_idr']?.toString() ?? '-';
      displaySpecs['Baterai'] = '-'; // Data not available in CSV
      displaySpecs['Dimensi'] = '-'; // Data not available in CSV
      
      String panel = product.rawData['panel_type']?.toString() ?? '';
      String size = product.rawData['display']?.toString() ?? '';
      String refresh = product.rawData['refresh_rate_hz']?.toString() ?? '';
      displaySpecs['Layar'] = '$size $panel ${refresh}Hz';
      
      displaySpecs['Rilis'] = product.rawData['year']?.toString() ?? '-';
      displaySpecs['Kamera'] = '-'; // Data not available
      
      String ram = product.rawData['ram']?.toString() ?? '';
      String storage = product.rawData['storage']?.toString() ?? '';
      displaySpecs['Memori'] = 'RAM: $ram\nStorage: $storage';
      
      String cpu = product.rawData['cpu']?.toString() ?? '';
      String gpu = product.rawData['gpu']?.toString() ?? '';
      displaySpecs['Platform'] = 'CPU: $cpu\nGPU: $gpu';
    }

    final entries = displaySpecs.entries.toList();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        // Header Info (Price & Score)
        Container(
          padding: const EdgeInsets.all(16),
          color: cs.primary.withOpacity(0.1),
          child: Column(
            children: [
               Text(
                product.brand,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product.name,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (product.benchmarkScore != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100, // Keep orange for benchmark badge
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.speed, size: 16, color: Colors.orange.shade800),
                      const SizedBox(width: 6),
                      Text(
                        "Benchmark: ${product.benchmarkScore}",
                        style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        // Specs List
        ...List.generate(entries.length, (index) {
          final entry = entries[index];
          final isEven = index % 2 == 0;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: isEven ? cs.surface : cs.onSurface.withOpacity(0.04),
              border: Border(bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.2))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    entry.key,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600, 
                      fontSize: 13, 
                      color: cs.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.end,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

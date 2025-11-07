import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/compare_cubit.dart';
import '../models/gadget.dart';
import 'package:intl/intl.dart';

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
    final priceFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final textTheme = Theme.of(context).textTheme;

    Widget buildImagePlaceholder(Gadget? gadget) {
      if (gadget == null) {
        return Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Icon(Icons.photo_size_select_actual_outlined, color: Colors.grey[400], size: 40)),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          gadget.image,
          height: 120,
          width: 120,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => buildImagePlaceholder(null),
        ),
      );
    }

    final specs = [
      {'label': 'Nama', 'pick': (Gadget g) => g.name},
      {'label': 'Harga', 'pick': (Gadget g) => priceFormatter.format(g.price)},
      {'label': 'Tipe', 'pick': (Gadget g) => g.type},
      {'label': 'Processor', 'pick': (Gadget g) => g.processor},
      {'label': 'RAM', 'pick': (Gadget g) => '${g.ramDetails.capacity} ${g.ramDetails.type}${g.ramDetails.speed != null ? ' ${g.ramDetails.speed}' : ''}'},
      {'label': 'Storage', 'pick': (Gadget g) => g.storage},
      {'label': 'Layar', 'pick': (Gadget g) => g.screen},
      {'label': 'Baterai', 'pick': (Gadget g) => g.battery},
      {'label': 'Kamera', 'pick': (Gadget g) => g.camera},
      {'label': 'Bobot', 'pick': (Gadget g) => g.weight},
      {'label': 'Geekbench Single', 'pick': (Gadget g) => g.benchmarks.geekbenchSingle?.toString() ?? '-'},
      {'label': 'Geekbench Multi', 'pick': (Gadget g) => g.benchmarks.geekbenchMulti?.toString() ?? '-'},
      {'label': 'GPU', 'pick': (Gadget g) => g.benchmarks.gpuName ?? '-'},
      {'label': 'VRAM', 'pick': (Gadget g) => g.vram ?? '-'},
    ];

    return BlocBuilder<CompareCubit, CompareState>(
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Bandingkan Gadget', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Kategori',
                        border: OutlineInputBorder(),
                      ),
                      value: state.selectedType,
                      items: const [
                        DropdownMenuItem(value: 'smartphone', child: Text('Smartphone')),
                        DropdownMenuItem(value: 'laptop', child: Text('Laptop')),
                      ],
                      onChanged: (v) => context.read<CompareCubit>().onTypeSelected(v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Brand',
                        border: OutlineInputBorder(),
                      ),
                      value: state.selectedBrand,
                      items: state.availableBrands.map((String brand) {
                        return DropdownMenuItem<String>(
                          value: brand,
                          child: Text(brand),
                        );
                      }).toList(),
                      onChanged: state.selectedType == null
                          ? null
                          : (v) => context.read<CompareCubit>().onBrandSelected(v),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Gadget>(
                            decoration: const InputDecoration(
                              labelText: 'Pilih Gadget A',
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            value: state.gadgetA,
                            items: state.filteredItems.map((g) => DropdownMenuItem(value: g, child: Text(g.name, overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: state.selectedBrand == null ? null : (v) => context.read<CompareCubit>().onGadgetASelected(v),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<Gadget>(
                            decoration: const InputDecoration(
                              labelText: 'Pilih Gadget B',
                              border: OutlineInputBorder(),
                            ),
                            isExpanded: true,
                            value: state.gadgetB,
                            items: state.filteredItems.map((g) => DropdownMenuItem(value: g, child: Text(g.name, overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: state.selectedBrand == null ? null : (v) => context.read<CompareCubit>().onGadgetBSelected(v),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (state.gadgetA != null && state.gadgetB != null)
              Card(
                clipBehavior: Clip.antiAlias,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Table(
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(1.0),
                    2: FlexColumnWidth(1.0),
                  },
                  border: TableBorder(horizontalInside: BorderSide(color: Colors.grey[200]!)),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[100]),
                      children: [
                        const TableCell(child: SizedBox()), // Empty cell for label column
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                            child: Column(
                              children: [
                                Text('Gadget A', style: textTheme.titleMedium),
                                const SizedBox(height: 8),
                                buildImagePlaceholder(state.gadgetA),
                              ],
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                            child: Column(
                              children: [
                                Text('Gadget B', style: textTheme.titleMedium),
                                const SizedBox(height: 8),
                                buildImagePlaceholder(state.gadgetB),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...specs.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var specData = entry.value;
                      final va = state.gadgetA != null ? (specData['pick'] as String Function(Gadget))(state.gadgetA!) : '-';
                      final vb = state.gadgetB != null ? (specData['pick'] as String Function(Gadget))(state.gadgetB!) : '-';

                      final bool areSame = va == vb;
                      final style = areSame
                          ? textTheme.bodyMedium?.copyWith(color: Colors.grey[600])
                          : textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);

                      return TableRow(
                        decoration: BoxDecoration(color: idx.isOdd ? Colors.grey[50] : Colors.white),
                        children: [
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.top,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              child: Text(specData['label'] as String, style: textTheme.bodyMedium?.copyWith(color: Colors.black54, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.top,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              child: Text(va, style: style),
                            ),
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.top,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              child: Text(vb, style: style),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

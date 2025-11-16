// lib/pages/compare_page.dart (Update: Integrasi fetchCompare)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/compare_cubit.dart';
import '../models/gadget.dart';
import '../shared/http_helper.dart';
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Perbandingan Gadget', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            // Tambah UI untuk pilih gadget A & B (e.g., dropdown/search)
            FilledButton(
              onPressed: () async {
                // Example devices; ganti dengan state.gadgetA/gadgetB
                final devices = [
                  {'brand': 'apple', 'device_name': 'iPhone 11'},
                  {'brand': 'asus', 'device_name': 'Zenbook S 14 OLED'},
                ];
                try {
                  final result = await fetchCompare('smartphone', devices);  // Ganti type jika laptop
                  // Update cubit with result if needed
                } catch (e) {
                  // Handle error
                }
              },
              child: const Text('Bandingkan'),
            ),
            const SizedBox(height: 20),
            // ... (rest of the table code remains the same)
          ],
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import '../data/data_asus.dart';
import '../data/data_google.dart';
import '../data/data_honor.dart';
import '../data/data_huawei.dart';
import '../data/data_infinix.dart';
import '../data/data_itel.dart';
import '../data/data_motorola.dart';
import '../data/data_oneplus.dart';
import '../data/data_oppo.dart';
import '../data/data_poco.dart';
import '../data/data_realme.dart';
import '../data/data_samsung.dart';
import '../models/gadget.dart';
import 'package:intl/intl.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  Gadget? a;
  Gadget? b;
  // State baru untuk menyimpan KATEGORI TUNGGAL yang dipilih
  String? selectedType;

  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final textTheme = Theme.of(context).textTheme;

    // Menggabungkan semua list gadget menjadi satu
    final allGadgets = [
      ...asusGadgets,
      ...googleGadgets,
      ...honorGadgets,
      ...huaweiGadgets,
      ...infinixGadgets,
      ...itelGadgets,
      ...motorolaGadgets,
      ...oneplusGadgets,
      ...oppoGadgets,
      ...pocoGadgets,
      ...realmeGadgets,
      ...samsungGadgets,
    ];

    // Memisahkan list gadget berdasarkan tipe
    final allSmartphones = allGadgets.where((g) => g.type == 'smartphone').toList();
    final allLaptops = allGadgets.where((g) => g.type == 'laptop').toList();

    // List dinamis untuk dropdown gadget berdasarkan kategori TUNGGAL yang dipilih
    List<Gadget> filteredItems = [];
    if (selectedType == 'smartphone') {
      filteredItems = allSmartphones;
    } else if (selectedType == 'laptop') {
      filteredItems = allLaptops;
    }

    DropdownMenuItem<Gadget> opt(Gadget g) =>
        DropdownMenuItem(value: g, child: SizedBox(width: 260, child: Text(g.name, overflow: TextOverflow.ellipsis)));

    Widget spec(String label, String Function(Gadget) pick) {
      final va = a != null ? pick(a!) : '-';
      final vb = b != null ? pick(b!) : '-';
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 180, child: Text(label, style: textTheme.bodyMedium?.copyWith(color: Colors.black54, fontWeight: FontWeight.w600))),
            Expanded(child: Text(va, style: textTheme.bodyMedium)),
            Expanded(child: Text(vb, style: textTheme.bodyMedium)),
          ],
        ),
      );
    }

    Widget buildImagePlaceholder(Gadget? gadget) {
      if (gadget == null) {
        return Container(
          height: 120,
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
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => buildImagePlaceholder(null),
        ),
      );
    }

    return ListView(
      children: [
        Text('Bandingkan Gadget', style: textTheme.headlineMedium),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // ### PERUBAHAN UTAMA DI SINI: Satu Dropdown untuk Kategori ###
                DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Pilih Kategori Gadget'),
                  value: selectedType,
                  items: const [
                    DropdownMenuItem(value: 'smartphone', child: Text('Smartphone')),
                    DropdownMenuItem(value: 'laptop', child: Text('Laptop')),
                  ],
                  onChanged: (v) => setState(() {
                    selectedType = v;
                    // Reset pilihan gadget A dan B saat kategori berubah
                    a = null;
                    b = null;
                  }),
                  underline: const SizedBox.shrink(),
                ),
                const Divider(height: 24, thickness: 1),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<Gadget>(
                        isExpanded: true,
                        hint: const Text('Pilih Gadget A'),
                        value: a,
                        // Gunakan list yang sudah difilter
                        items: filteredItems.map(opt).toList(),
                        // Nonaktifkan jika belum ada kategori yang dipilih
                        onChanged: selectedType == null ? null : (v) => setState(() => a = v),
                        underline: const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: DropdownButton<Gadget>(
                        isExpanded: true,
                        hint: const Text('Pilih Gadget B'),
                        value: b,
                        // Gunakan list yang sudah difilter
                        items: filteredItems.map(opt).toList(),
                        onChanged: selectedType == null ? null : (v) => setState(() => b = v),
                        underline: const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    const SizedBox(width: 180),
                    Expanded(child: buildImagePlaceholder(a)),
                    const SizedBox(width: 12),
                    Expanded(child: buildImagePlaceholder(b)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(color: Colors.grey[200]),
                child: Row(
                  children: [
                    const SizedBox(width: 180),
                    Expanded(child: Text('Gadget A', textAlign: TextAlign.center, style: textTheme.titleLarge?.copyWith(fontSize: 16))),
                    Expanded(child: Text('Gadget B', textAlign: TextAlign.center, style: textTheme.titleLarge?.copyWith(fontSize: 16))),
                  ],
                ),
              ),
              spec('Nama', (g) => g.name),
              spec('Harga', (g) => priceFormatter.format(g.price)),
              spec('Tipe', (g) => g.type),
              spec('Processor', (g) => g.processor),
              spec('RAM', (g) => '${g.ramDetails.capacity} ${g.ramDetails.type}${g.ramDetails.speed != null ? ' ${g.ramDetails.speed}' : ''}'),
              spec('Storage', (g) => g.storage),
              spec('Layar', (g) => g.screen),
              spec('Baterai', (g) => g.battery),
              spec('Kamera', (g) => g.camera),
              spec('Bobot', (g) => g.weight),
              spec('Geekbench Single', (g) => g.benchmarks.geekbenchSingle?.toString() ?? '-'),
              spec('Geekbench Multi', (g) => g.benchmarks.geekbenchMulti?.toString() ?? '-'),
              spec('GPU', (g) => g.benchmarks.gpuName ?? '-'),
              spec('VRAM', (g) => g.vram ?? '-'),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

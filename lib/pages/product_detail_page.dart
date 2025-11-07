
import 'package:flutter/material.dart';
import '../models/gadget.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatelessWidget {
  final Gadget gadget;

  const ProductDetailPage({super.key, required this.gadget});

  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final scoreFormatter = NumberFormat.decimalPattern('id_ID');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildProductHeader(context),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductOverview(context, priceFormatter),
                      const SizedBox(height: 40),
                      _buildSectionTitle("Spesifikasi Detail"),
                      const SizedBox(height: 20),
                      _buildSpecsGrid(context),
                      const SizedBox(height: 40),
                      _buildSectionTitle("🏆 Benchmark"),
                      const SizedBox(height: 20),
                      _buildBenchmarkGrid(context, scoreFormatter),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
      ),
    );
  }

  // WIDGET UNTUK BAGIAN HEADER
  Widget _buildProductHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140.0,
      pinned: true,
      backgroundColor: const Color(0xFF2c1810),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(color: Color(0xFFf39c12), shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        gadget.rating.toInt().toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          gadget.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
                          softWrap: true,
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "ulasan, spesifikasi dan harga",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET UNTUK BAGIAN OVERVIEW PRODUK
  Widget _buildProductOverview(BuildContext context, NumberFormat priceFormatter) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Card(
            elevation: 5,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Image.asset(
                gadget.image,
                height: 300,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.laptop_mac, size: 120, color: Colors.grey)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 4,
          child: Card(
            elevation: 5,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gadget.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF333333)),
                    softWrap: true,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Mengapa produk ini lebih baik daripada rata-rata?",
                    style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF555555)),
                  ),
                  const SizedBox(height: 10),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(3),
                    },
                    children: [
                      _buildTableRow("RAM", "${gadget.ramDetails.capacity} vs 16GB"),
                      _buildTableRow("Resolusi", "${gadget.screen.split('"').first}\" vs 2.07MP"),
                      _buildTableRow("Berat", "${gadget.weight} vs 2.04kg"),
                      _buildTableRow("Penyimpanan", "${gadget.storage} vs 512GB"),
                      _buildTableRow("VRAM", "${gadget.vram ?? '-'} vs 8GB"),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15, bottom: 15),
                    height: 2,
                    color: const Color(0xFFe0e0e0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Harga", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF555555))),
                      Text(
                        priceFormatter.format(gadget.price),
                        style: const TextStyle(color: Color(0xFFe74c3c), fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF555555)),
            softWrap: true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Color(0xFF333333)),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  // WIDGET UNTUK BAGIAN SPESIFIKASI
  Widget _buildSpecsGrid(BuildContext context) {
    final List<Widget> specCards = [
      _buildSpecCard("RAM", { "Kapasitas": gadget.ramDetails.capacity, "Tipe": gadget.ramDetails.type }),
      _buildSpecCard("KECEPATAN RAM", { "Speed": gadget.ramDetails.speed ?? 'N/A' }),
      _buildSpecCard("PENYIMPANAN INTERNAL", { "Kapasitas": gadget.storage }),
      _buildSpecCard("MENGGUNAKAN PENYIMPANAN FLASH", { "Storage": gadget.storage.contains("SSD") ? "Ya" : "Tidak" }),
      _buildSpecCard("KECEPATAN CPU", { "Base Clock": gadget.cpuDetails.baseClock ?? 'N/A', "Boost Clock": gadget.cpuDetails.boostClock ?? 'N/A' }),
      _buildSpecCard("THREAD CPU", { "Threads": gadget.cpuDetails.threads ?? 'N/A', "Processor": gadget.processor }),
      _buildSpecCard("TINGKAT TEKSTUR", { "Performance": "Lebih baik dalam game" }),
      _buildEcoFriendlySpecCard(context),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1, 
      ),
      itemCount: specCards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return specCards[index];
      },
    );
  }

  Widget _buildSpecCard(String title, Map<String, String> specs) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333)), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 15),
            ...specs.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(child: Text(e.key, style: const TextStyle(color: Color(0xFF666666), fontSize: 14), softWrap: true)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e.value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF333333), fontSize: 14),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoFriendlySpecCard(BuildContext context) {
    bool hasFeatures = gadget.ecoInfo.features.isNotEmpty;
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("♻️ BAHAN DAUR ULANG", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333)), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 15),
            if (hasFeatures)
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: gadget.ecoInfo.features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(feature.icon, size: 16, color: const Color(0xFF666666)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${feature.component}: ${feature.detail}",
                            style: const TextStyle(color: Color(0xFF666666), fontSize: 14),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Text(
                    "Data tidak tersedia",
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // WIDGET UNTUK BAGIAN BENCHMARK
  Widget _buildBenchmarkGrid(BuildContext context, NumberFormat scoreFormatter) {
    final benchmarks = gadget.benchmarks;
    final List<Widget> benchmarkCards = [
      _buildBenchmarkCard("HASIL GEEKBENCH 5 (INTI BANYAK)", benchmarks.geekbenchMulti, gadget.processor, scoreFormatter, 0.85, "Geekbench 5 adalah perhitungan lintas platform yang mengukur kinerja CPU"),
      _buildBenchmarkCard("HASIL GEEKBENCH 5 (TUNGGAL)", benchmarks.geekbenchSingle, gadget.processor, scoreFormatter, 0.90, "Geekbench 5 adalah perhitungan lintas platform yang mengukur kinerja single-core CPU"),
      _buildBenchmarkCard("HASIL GEEKBENCH 5 (INTI BANYAK)", null, "Tidak diketahui, tetapi hasil dengan prosesor yang lebih lambat", scoreFormatter, 0.70, "Geekbench 5 adalah perhitungan lintas platform"),
      _buildBenchmarkCard("HASIL PASSMARK", benchmarks.passmarkGpu, benchmarks.gpuName ?? '', scoreFormatter, 0.95, "PassMark GPU merupakan kinerja grafik dan sesuatu untuk kinerja GPU"),
      _buildBenchmarkCard("HASIL PASSMARK (TUNGGAL)", benchmarks.passmarkCpu, gadget.processor, scoreFormatter, 0.80, "PassMark adalah perhitungan kinerja CPU"),
      _buildBenchmarkCard("HASIL CINEBENCH R20 (MULTI)", null, gadget.processor, scoreFormatter, 0.88, "Cinebench R20 adalah test perhitungan yang menguji kinerja CPU"),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 25,
        crossAxisSpacing: 25,
        childAspectRatio: 1.6,
      ),
      itemCount: benchmarkCards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return benchmarkCards[index];
      },
    );
  }

  // ### PERBAIKAN UTAMA DI SINI ###
  Widget _buildBenchmarkCard(String title, int? score, String scoreSuffix, NumberFormat formatter, double percentage, String description) {
    final double progressValue = score != null ? percentage : 0.0;

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF333333)), maxLines: 2, overflow: TextOverflow.ellipsis),
            // Memisahkan Skor dan Suffix (Brand) untuk mencegah overflow
            if (score != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatter.format(score),
                    style: const TextStyle(color: Color(0xFF3498db), fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    scoreSuffix,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            else
              Text(
                scoreSuffix.startsWith("Tidak diketahui") ? scoreSuffix : "Data Tidak Tersedia",
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(score != null ? const Color(0xFF3498db) : Colors.grey[300]!),
              ),
            ),
            Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
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
                constraints: BoxConstraints(maxWidth: 90.w),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductOverview(context, priceFormatter),
                      SizedBox(height: 5.h),
                      _buildSectionTitle("Spesifikasi Detail"),
                      SizedBox(height: 2.5.h),
                      _buildSpecsGrid(context),
                      SizedBox(height: 5.h),
                      _buildSectionTitle("🏆 Benchmark"),
                      SizedBox(height: 2.5.h),
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
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(
        title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFF333333)),
      ),
    );
  }

  // WIDGET UNTUK BAGIAN HEADER
  Widget _buildProductHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 18.h,
      pinned: true,
      backgroundColor: const Color(0xFF2c1810),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 90.w),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 8.h,
                    height: 8.h,
                    decoration: const BoxDecoration(color: Color(0xFFf39c12), shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        gadget.rating.toInt().toString(),
                        style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          gadget.name,
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                          softWrap: true,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          "ulasan, spesifikasi dan harga",
                          style: TextStyle(color: Colors.white70, fontSize: 11.sp),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
            child: Padding(
              padding: EdgeInsets.all(5.w),
              child: Image.asset(
                gadget.image,
                height: 30.h,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Center(child: Icon(Icons.laptop_mac, size: 15.h, color: Colors.grey)),
              ),
            ),
          ),
        ),
        SizedBox(width: 5.w),
        Expanded(
          flex: 4,
          child: Card(
            elevation: 5,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gadget.name,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp, color: const Color(0xFF333333)),
                    softWrap: true,
                  ),
                  SizedBox(height: 2.5.h),
                  const Text(
                    "Mengapa produk ini lebih baik daripada rata-rata?",
                    style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF555555)),
                  ),
                  SizedBox(height: 1.2.h),
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
                    margin: EdgeInsets.symmetric(vertical: 2.h),
                    height: 2,
                    color: const Color(0xFFe0e0e0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Harga", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF555555))),
                      Text(
                        priceFormatter.format(gadget.price),
                        style: TextStyle(color: const Color(0xFFe74c3c), fontWeight: FontWeight.bold, fontSize: 14.sp),
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
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF555555)),
            softWrap: true,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h),
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 2.5.w,
        crossAxisSpacing: 2.5.w,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.sp)),
      child: Padding(
        padding: EdgeInsets.all(2.5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF333333)), maxLines: 2, overflow: TextOverflow.ellipsis),
            SizedBox(height: 2.h),
            ...specs.entries.map((e) => Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(child: Text(e.key, style: TextStyle(color: const Color(0xFF666666), fontSize: 11.sp), softWrap: true)),
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Text(
                      e.value,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.w500, color: const Color(0xFF333333), fontSize: 11.sp),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.sp)),
      child: Padding(
        padding: EdgeInsets.all(2.5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("♻️ BAHAN DAUR ULANG", style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: const Color(0xFF333333)), maxLines: 2, overflow: TextOverflow.ellipsis),
            SizedBox(height: 2.h),
            if (hasFeatures)
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: gadget.ecoInfo.features.map((feature) => Padding(
                    padding: EdgeInsets.only(bottom: 1.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(feature.icon, size: 12.sp, color: const Color(0xFF666666)),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            "${feature.component}: ${feature.detail}",
                            style: TextStyle(color: const Color(0xFF666666), fontSize: 11.sp),
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
                    style: TextStyle(color: Colors.grey[500], fontSize: 11.sp),
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 3.w,
        crossAxisSpacing: 3.w,
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
        borderRadius: BorderRadius.circular(10.sp),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(2.5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: const Color(0xFF333333)), maxLines: 2, overflow: TextOverflow.ellipsis),
            // Memisahkan Skor dan Suffix (Brand) untuk mencegah overflow
            if (score != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatter.format(score),
                    style: TextStyle(color: const Color(0xFF3498db), fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    scoreSuffix,
                    style: TextStyle(color: Colors.grey[700], fontSize: 10.sp),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            else
              Text(
                scoreSuffix.startsWith("Tidak diketahui") ? scoreSuffix : "Data Tidak Tersedia",
                style: TextStyle(color: Colors.grey[500], fontSize: 11.sp),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.sp),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 1.h,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(score != null ? const Color(0xFF3498db) : Colors.grey[300]!),
              ),
            ),
            Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 10.sp, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

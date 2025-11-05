import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/gadget.dart';

class GadgetService {
  Future<List<Gadget>> loadGadgets() async {
    // 1. Baca file CSV dari assets
    final rawData = await rootBundle.loadString('assets/data/gadgets.csv');

    // 2. Parse string CSV menjadi List<List<dynamic>>
    // skipHeader: true agar baris pertama (header) tidak ikut di-parse
    final List<List<dynamic>> listData = 
    const CsvToListConverter().convert(rawData, eol: '\n', shouldParseNumbers: false);

    // 3. Ubah List<List<dynamic>> menjadi List<Gadget>
    final List<Gadget> gadgets = [];
    for (var row in listData.skip(1)) { // Skip header row
      try {
        final gadget = Gadget(
          id: int.parse(row[0].toString()),
          name: row[1].toString(),
          type: row[2].toString(),
          price: double.parse(row[3].toString()),
          processor: row[4].toString(),
          storage: row[5].toString(),
          screen: row[6].toString(),
          battery: row[7].toString(),
          camera: row[8].toString(),
          weight: row[9].toString(),
          rating: double.parse(row[10].toString()),
          image: row[11].toString(),
          isPopular: row[12].toString().toLowerCase() == 'true',
          isNewest: row[13].toString().toLowerCase() == 'true',
          ramDetails: RamDetails(
            capacity: row[14].toString(),
            type: row[15].toString(),
          ),
          // Inisialisasi data lain dengan nilai default karena tidak ada di CSV
          cpuDetails: const CpuDetails(),
          benchmarks: const BenchmarkScores(),
          ecoInfo: const EcoInfo(),
        );
        gadgets.add(gadget);
      } catch (e) {
        // Menangani error parsing jika ada baris yang formatnya salah
      }
    }

    return gadgets;
  }
}

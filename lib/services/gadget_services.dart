import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/gadget.dart';

class GadgetService {
  Future<List<Gadget>> loadGadgets() async {
    final List<Gadget> allGadgets = [];

    // 1. Load Laptops
    try {
      final laptopData = await rootBundle.loadString('backend/data/laptops_all_indonesia_fixed_v7.csv');
      final List<List<dynamic>> laptopRows = const CsvToListConverter().convert(laptopData);

      if (laptopRows.isNotEmpty) {
        final header = laptopRows[0].map((e) => e.toString().toLowerCase()).toList();
        final nameIndex = header.indexOf('model');
        final cpuIndex = header.indexOf('cpu');

        if (nameIndex != -1 && cpuIndex != -1) {
          for (var row in laptopRows.skip(1)) {
            // Sanitize name for image path
            String sanitizedName = row[nameIndex].toString().replaceAll(RegExp(r'[\\/*?:"<>|]'), '_');
            allGadgets.add(Gadget(
              name: row[nameIndex].toString(),
              type: 'laptop',
              processor: row[cpuIndex].toString(),
              image: 'assets/images/$sanitizedName.jpg',
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading laptop data: $e');
    }

    // 2. Load Smartphones
    try {
      final smartphoneData = await rootBundle.loadString('backend/data/ALL_SMARTPHONES_MERGED.csv');
      final List<List<dynamic>> smartphoneRows = const CsvToListConverter().convert(smartphoneData);

      if (smartphoneRows.isNotEmpty) {
        final header = smartphoneRows[0].map((e) => e.toString().toLowerCase()).toList();
        final nameIndex = header.indexOf('device name');
        final chipsetIndex = header.indexOf('platform_chipset');
        final cameraIndex = header.indexOf('main_camera_spec');

        if (nameIndex != -1 && chipsetIndex != -1 && cameraIndex != -1) {
          for (var row in smartphoneRows.skip(1)) {
            // Sanitize name for image path
            String sanitizedName = row[nameIndex].toString().replaceAll(RegExp(r'[\\/*?:"<>|]'), '_');
            allGadgets.add(Gadget(
              name: row[nameIndex].toString(),
              type: 'smartphone',
              processor: row[chipsetIndex].toString(),
              camera: row[cameraIndex].toString(),
              image: 'assets/images/$sanitizedName.jpg',
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading smartphone data: $e');
    }

    return allGadgets;
  }
}

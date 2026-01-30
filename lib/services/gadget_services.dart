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
            try {
              // Safety check: ensure row has enough columns
              if (row.length <= nameIndex || row.length <= cpuIndex) continue;

              final nameVal = row[nameIndex].toString();
              final cpuVal = row[cpuIndex].toString();

              if (nameVal.isEmpty) continue;

              // Sanitize name for image path
              String sanitizedName = nameVal.replaceAll(RegExp(r'[\\/*?:"<>|]'), '_');
              allGadgets.add(Gadget(
                name: nameVal,
                type: 'laptop',
                processor: cpuVal.isEmpty ? 'Unknown Processor' : cpuVal,
                image: 'assets/images/$sanitizedName.jpg',
              ));
            } catch (e) {
               debugPrint('Error parsing laptop row: $e');
               continue; // Skip bad row, don't crash
            }
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
             try {
               // Safety check
               if (row.length <= nameIndex) continue;
               
               final nameVal = row[nameIndex].toString();
               if (nameVal.isEmpty) continue;

               final chipsetVal = (chipsetIndex < row.length) ? row[chipsetIndex].toString() : '';
               final cameraVal = (cameraIndex < row.length) ? row[cameraIndex].toString() : '';

              // Sanitize name for image path
              String sanitizedName = nameVal.replaceAll(RegExp(r'[\\/*?:"<>|]'), '_');
              allGadgets.add(Gadget(
                name: nameVal,
                type: 'smartphone',
                processor: chipsetVal.isEmpty ? 'Unknown Chipset' : chipsetVal,
                camera: cameraVal.isEmpty ? '-' : cameraVal,
                image: 'assets/images/$sanitizedName.jpg',
              ));
             } catch (e) {
                debugPrint('Error parsing smartphone row: $e');
                continue;
             }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading smartphone data: $e');
    }

    return allGadgets;
  }
}

import 'package:flutter/material.dart';

class RamDetails {
  final String capacity;
  final String type;
  final String? speed;
  const RamDetails({required this.capacity, required this.type, this.speed});
}

class CpuDetails {
  final String? cores;
  final String? threads;
  final String? baseClock;
  final String? boostClock;
  const CpuDetails({this.cores, this.threads, this.baseClock, this.boostClock});
}

class BenchmarkScores {
  final int? geekbenchSingle;
  final int? geekbenchMulti;
  final int? passmarkCpu;
  final int? passmarkGpu;
  final String? gpuName;
  const BenchmarkScores({
    this.geekbenchSingle,
    this.geekbenchMulti,
    this.passmarkCpu,
    this.passmarkGpu,
    this.gpuName,
  });
}

class EcoFriendlyFeature {
  final IconData icon;
  final String component;
  final String detail;
  const EcoFriendlyFeature({
    required this.icon,
    required this.component,
    required this.detail,
  });
}

class EcoInfo {
  final List<EcoFriendlyFeature> features;
  const EcoInfo({this.features = const []});
}

class Gadget {
  final int id;
  final String name;
  final String type;        // smartphone | laptop
  final double price;       // IDR
  final String processor;
  final String storage;
  final String screen;
  final String battery;
  final String camera;
  final String weight;
  final double rating;
  final String image;
  final bool isPopular;
  final bool isNewest;
  final RamDetails ramDetails;
  final CpuDetails cpuDetails;
  final BenchmarkScores benchmarks;
  final EcoInfo ecoInfo;
  final String? vram;       // opsional

  const Gadget({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.processor,
    required this.storage,
    required this.screen,
    required this.battery,
    required this.camera,
    required this.weight,
    required this.rating,
    required this.image,
    required this.isPopular,
    required this.isNewest,
    required this.ramDetails,
    required this.cpuDetails,
    required this.benchmarks,
    this.ecoInfo = const EcoInfo(),
    this.vram,
  });

  /// FROM JSON – SUPPORT SMARTPHONE & LAPTOP dari backend Render
  factory Gadget.fromJson(Map<String, dynamic> json, String type) {
    final name = json['device_name']?.toString() ?? 'Unknown Gadget';
    final cleanName = name.toLowerCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^a-z0-9_]'), '');

    return Gadget(
      id: json['rank'] ?? 999,
      name: name,
      type: type,
      price: (json['harga_rp'] ?? 0).toDouble(),
      processor: _safeString(json, ['cpu', 'chipset', 'processor', 'prosesor']),
      storage: _safeString(json, ['storage_gb', 'storage', 'penyimpanan']),
      screen: _safeString(json, ['display', 'layar', 'screen']),
      battery: _safeString(json, ['battery_capacity', 'baterai', 'battery']),
      camera: _safeString(json, ['main_camera_mp', 'kamera', 'camera']),
      weight: _safeString(json, ['weight_kg', 'weight_g', 'berat', 'bobot']),
      rating: (json['worth_score'] ?? 0.0).toDouble(),
      image: 'assets/images/$cleanName.jpg',
      isPopular: (json['is_popular'] ?? false) == true,
      isNewest: (json['is_newest'] ?? false) == true,
      ramDetails: RamDetails(
        capacity: _safeString(json, ['ram_gb', 'ram_capacity', 'ram']),
        type: _safeString(json, ['ram_type', 'ram_jenis']),
        speed: _safeString(json, ['ram_speed', 'ram_kecepatan']),
      ),
      cpuDetails: CpuDetails(
        cores: _safeString(json, ['cpu_cores', 'cores']),
        threads: _safeString(json, ['cpu_threads', 'threads']),
        baseClock: _safeString(json, ['base_clock', 'clock_base']),
        boostClock: _safeString(json, ['boost_clock', 'clock_boost']),
      ),
      benchmarks: BenchmarkScores(
        geekbenchSingle: _safeInt(json, ['geekbench_single', 'gb_single']),
        geekbenchMulti: _safeInt(json, ['geekbench_multi', 'gb_multi']),
        passmarkCpu: _safeInt(json, ['passmark_cpu']),
        passmarkGpu: _safeInt(json, ['passmark_gpu']),
        gpuName: _safeString(json, ['gpu_name', 'gpu']),
      ),
      vram: _safeString(json, ['vram', 'vram_gb']),
      ecoInfo: const EcoInfo(),
    );
  }

  /// Helper: Ambil nilai string dari beberapa kemungkinan key
  static String _safeString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '';
  }

  /// Helper: Ambil nilai int dari beberapa kemungkinan key
  static int? _safeInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String && value.isNotEmpty) {
        return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
      }
    }
    return null;
  }
}
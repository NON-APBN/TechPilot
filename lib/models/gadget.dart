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
}

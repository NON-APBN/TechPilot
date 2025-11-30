// lib/models/gadget.dart
class Gadget {
  final String name;
  final String type; // 'laptop' or 'smartphone'
  final String processor;
  final String? camera;
  final String image;

  const Gadget({
    required this.name,
    required this.type,
    required this.processor,
    this.camera,
    required this.image,
  });
}

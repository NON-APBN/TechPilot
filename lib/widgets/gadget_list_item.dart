
import 'package:flutter/material.dart';
import '../models/gadget.dart';

class GadgetListItem extends StatelessWidget {
  final Gadget gadget;
  // Callback untuk tombol "Bandingkan", bisa dikembangkan nanti
  final VoidCallback? onCompare;

  const GadgetListItem({super.key, required this.gadget, this.onCompare});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(gadget.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                return Container(color: const Color(0xFFF2F2F2), child: const Icon(Icons.image_not_supported_outlined));
              }),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gadget.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  [
                    gadget.processor, gadget.storage, gadget.screen,
                    if (gadget.camera.isNotEmpty) 'Kamera: ${gadget.camera}',
                  ].where((e) => e.isNotEmpty).join(' • '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const Spacer(),
                Text('Rp ${gadget.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, '/detail', arguments: gadget),
                      child: const Text('Detail'),
                    ),
                    const SizedBox(width: 8),
                    // Tombol Bandingkan bisa di-enable jika onCompare tidak null
                    FilledButton.tonal(onPressed: onCompare, child: const Text('Bandingkan')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

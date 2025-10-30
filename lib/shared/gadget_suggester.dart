// lib/shared/gadget_suggester.dart
import '../models/gadget.dart';

class GadgetSuggester {
  /// Balasan ringkas dari input user (dalam bhs Indonesia).
  /// - Deteksi budget: "8 jt", "8juta", atau rentang "6-8 jt"
  /// - Deteksi kebutuhan: gaming/kamera/baterai/ringan/layar/render/ai
  static String replyFor(String input, List<Gadget> data) {
    final text = input.toLowerCase();

    // ==== Ambil budget ====
    // Contoh cocok: "8 jt", "10juta", "6-8 jt"
    final budgetRgx = RegExp(r'(\d+)(?:\s*-\s*(\d+))?\s*(jt|juta)?');
    int? fromJt;
    int? toJt;
    for (final m in budgetRgx.allMatches(text)) {
      final a = int.tryParse(m.group(1) ?? '');
      final b = int.tryParse(m.group(2) ?? '');
      if (a != null && b != null) {
        fromJt = a;
        toJt = b;
      } else if (a != null) {
        fromJt = a;
      }
    }

    final int min;
    final int max;
    if (fromJt != null && toJt != null) {
      min = fromJt! * 1_000_000;
      max = toJt! * 1_000_000;
    } else if (fromJt != null) {
      // ±1 jt di sekitar angka yang disebut
      min = (fromJt! - 1) * 1_000_000;
      max = (fromJt! + 1) * 1_000_000;
    } else {
      // default range
      min = 3 * 1_000_000;
      max = 12 * 1_000_000;
    }

    // ==== Kebutuhan ====
    final needs = <String>[];
    for (final k in ['gaming', 'kamera', 'baterai', 'ringan', 'layar', 'render', 'ai']) {
      if (text.contains(k)) needs.add(k);
    }

    // Tambahkan tag otomatis dari spesifikasi
    final enriched = data.map((g) => (g: g, tags: deriveTags(g))).toList();

    // ==== Filter kandidat ====
    final candidates = enriched
        .where((e) {
      final g = e.g;
      final okBudget = g.price >= min && g.price <= max;
      final okNeed = needs.isEmpty || needs.any((n) => e.tags.contains(n));
      return okBudget && okNeed;
    })
        .map((e) => e.g)
        .toList();

    // ==== Fallback jika kosong ====
    if (candidates.isEmpty) {
      final alt = data
          .take(3)
          .map((g) => '- ${g.name} (${g.processor} • ${g.screen})')
          .join('\n');
      return 'Belum nemu yang pas di budget itu. Coba pertimbangkan:\n$alt'
          '\n\nTambahkan kata kunci seperti "gaming", "kamera", atau "baterai".';
    }

    // Formatter sederhana ribuan tanpa package intl
    String fmt(int v) {
      final s = v.toString();
      final buf = StringBuffer();
      for (var i = 0; i < s.length; i++) {
        final left = s.length - i - 1; // sisa digit di kanan
        buf.write(s[i]);
        if (left > 0 && left % 3 == 0) buf.write('.');
      }
      return buf.toString();
    }

    // ==== Susun jawaban top-3 ====
    final top = candidates.take(3).map((g) {
      final detail = [
        g.processor,
        if (g.camera.isNotEmpty) 'Kamera: ${g.camera}',
        g.screen,
      ].where((e) => e.isNotEmpty).join(' • ');
      return '- ${g.name} — $detail (±Rp ${fmt(g.price.toInt())})';
    }).join('\n');

    final needTxt = needs.isEmpty ? 'umum' : needs.join(', ');
    final btxt = (fromJt != null && toJt != null)
        ? '~${fromJt}-${toJt} jt'
        : (fromJt == null ? 'kisaran' : '~$fromJt jt');

    return 'Oke, kebutuhan: $needTxt, budget: $btxt.\n'
        'Rekomendasi awal:\n$top\n\n'
        'Mau dibandingkan side-by-side? ketik: "bandingkan 1 & 2" (contoh).';
  }

  /// Derivasi tag dari spesifikasi untuk pencocokan kebutuhan.
  static Set<String> deriveTags(Gadget g) {
    final tags = <String>{};
    final proc = g.processor.toLowerCase();
    final scr = g.screen.toLowerCase();
    final cam = g.camera.toLowerCase();
    final bat = g.battery.toLowerCase();
    final name = g.name.toLowerCase();

    // gaming / render
    if (proc.contains('rtx') ||
        proc.contains('ryzen 9') ||
        proc.contains('i9') ||
        proc.contains('i7') ||
        name.contains('rog') ||
        name.contains('legion')) {
      tags..add('gaming')..add('render');
    }

    // kamera (smartphone)
    if (g.type == 'smartphone' &&
        (cam.contains('mp') ||
            name.contains('iphone') ||
            name.contains('pixel') ||
            name.contains('galaxy'))) {
      tags.add('kamera');
    }

    // layar
    if (scr.contains('oled') ||
        scr.contains('retina') ||
        scr.contains('amoled') ||
        scr.contains('qhd') ||
        scr.contains('3.5k') ||
        scr.contains('165hz')) {
      tags.add('layar');
    }

    // baterai
    if (bat.contains('wh') || bat.contains('mah')) tags.add('baterai');

    // ringan (laptop)
    final w = g.weight.toLowerCase();
    if (g.type == 'laptop' && (w.startsWith('1.') || name.contains('air'))) {
      tags.add('ringan');
    }

    // ai/soc dengan NPU
    if (proc.contains('m3') || proc.contains('tensor') || proc.contains('ai')) {
      tags.add('ai');
    }

    return tags;
  }
}

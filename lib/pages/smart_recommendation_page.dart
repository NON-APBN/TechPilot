import 'package:flutter/material.dart';
import '../models/gadget.dart';
import '../data/dummy_data.dart';
import '../shared/gadget_suggester.dart';

class SmartRecommendationPage extends StatefulWidget {
  final bool showCompareHint;
  const SmartRecommendationPage({super.key, this.showCompareHint = false});

  @override
  State<SmartRecommendationPage> createState() => _SmartRecommendationPageState();
}

class _SmartRecommendationPageState extends State<SmartRecommendationPage> {
  String _type = 'smartphone';
  double _budget = 8;
  final Set<String> _needs = {'kamera'};

  late final List<_WithTags> _withTags =
  allGadgets.map((g) => _WithTags(g, GadgetSuggester.deriveTags(g))).toList();

  List<_WithTags> get _filtered {
    final min = (_budget - 1).clamp(1, 100) * 1_000_000;
    final max = (_budget + 1) * 1_000_000;
    return _withTags.where((wt) {
      final g = wt.g;
      final okType = g.type == _type;
      final okBudget = g.price >= min && g.price <= max;
      final okNeeds = _needs.isEmpty || _needs.any((n) => wt.tags.contains(n));
      return okType && okBudget && okNeeds;
    }).toList();
  }

  Widget chip(String label) {
    final selected = _needs.contains(label);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (v) => setState(() => v ? _needs.add(label) : _needs.remove(label)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 760;

    return ListView(
      children: [
        const Text('Rekomendasi Pintar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        if (widget.showCompareHint)
          const Padding(
            padding: EdgeInsets.only(top: 6.0, bottom: 8),
            child: Text('Tips: pilih 2–3 item dari hasil untuk dibandingkan side-by-side.'),
          ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Tipe: '),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _type,
                      items: const [
                        DropdownMenuItem(value: 'smartphone', child: Text('Smartphone')),
                        DropdownMenuItem(value: 'laptop', child: Text('Laptop')),
                      ],
                      onChanged: (v) => setState(() => _type = v!),
                    ),
                  ]),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Budget: '),
                    Slider(
                      value: _budget, min: 2, max: 40, divisions: 38,
                      label: '${_budget.toStringAsFixed(0)} jt',
                      onChanged: (v) => setState(() => _budget = v),
                    ),
                    Text('${_budget.toStringAsFixed(0)} jt'),
                  ]),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Kebutuhan:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  chip('gaming'),
                  chip('kamera'),
                  chip('baterai'),
                  chip('ringan'),
                  chip('layar'),
                  chip('render'),
                  chip('ai'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _filtered.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isNarrow ? 1 : 2,
            crossAxisSpacing: 12, mainAxisSpacing: 12, mainAxisExtent: 180,
          ),
          itemBuilder: (_, i) {
            final g = _filtered[i].g;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 3))],
              ),
              child: Row(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(g.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                        return Container(color: const Color(0xFFF2F2F2), child: const Icon(Icons.image_not_supported_outlined));
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(
                          [
                            g.processor, g.storage, g.screen,
                            if (g.camera.isNotEmpty) 'Kamera: ${g.camera}',
                          ].where((e) => e.isNotEmpty).join(' • '),
                          maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54),
                        ),
                        const Spacer(),
                        Text('Rp ${g.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pushNamed(context, '/detail', arguments: g),
                              child: const Text('Detail'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.tonal(onPressed: () {}, child: const Text('Bandingkan')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (_filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('Tidak ada hasil. Coba naikkan budget atau ubah kebutuhan.'),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _WithTags {
  final Gadget g;
  final Set<String> tags;
  _WithTags(this.g, this.tags);
}

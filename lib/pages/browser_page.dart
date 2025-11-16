// lib/pages/browser_page.dart (Update: Integrasi fetchRank)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/gadget_browser_cubit.dart';
import '../shared/http_helper.dart';
import '../widgets/gadget_card.dart';

class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GadgetBrowserCubit(),
      child: const BrowseView(),
    );
  }
}

class BrowseView extends StatelessWidget {
  const BrowseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jelajahi Gadget', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                BlocBuilder<GadgetBrowserCubit, GadgetBrowserState>(
                  buildWhen: (p, c) => p.type != c.type,
                  builder: (context, state) {
                    return DropdownButton<String>(
                      value: state.type,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'smartphone', child: Text('Smartphone')),
                        DropdownMenuItem(value: 'laptop', child: Text('Laptop')),
                      ],
                      onChanged: (v) => context.read<GadgetBrowserCubit>().setType(v!),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Cari nama, prosesor, atau fitur...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (v) => context.read<GadgetBrowserCubit>().setQuery(v),
                  ),
                ),
                const Icon(Icons.search),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: BlocBuilder<GadgetBrowserCubit, GadgetBrowserState>(
            builder: (context, state) {
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchRank(state.type, 0, 50000000),  // Fetch all, filter local
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final items = snapshot.data ?? [];
                  final filtered = items.where((g) => g['device_name'].toLowerCase().contains(state.query.toLowerCase())).toList();
                  return GridView.builder(
                    itemCount: filtered.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (_, i) {
                      final g = filtered[i];
                      return GadgetCard(
                        gadget: Gadget(
                          id: g['rank'],
                          name: g['device_name'],
                          type: state.type,
                          price: g['harga_rp'].toDouble(),
                          processor: '',  // Tambah jika backend kirim
                          storage: '',
                          screen: '',
                          battery: '',
                          camera: '',
                          weight: '',
                          rating: 0.0,
                          image: 'assets/images/${g['device_name'].toLowerCase().replaceAll(' ', '_')}.jpg',
                          isPopular: false,
                          isNewest: false,
                          ramDetails: const RamDetails(capacity: '', type: ''),
                          cpuDetails: const CpuDetails(),
                          benchmarks: const BenchmarkScores(),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/gadget_browser_cubit.dart';
import '../widgets/gadget_list_item.dart';

class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GadgetBrowserCubit(),
      child: const BrowseView(),
    );
  }
}

class BrowseView extends StatelessWidget {
  const BrowseView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text('Jelajahi Gadget', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        const FilterBar(),
        const SizedBox(height: 16),
        const GadgetGrid(),
        const SizedBox(height: 24),
      ],
    );
  }
}

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GadgetBrowserCubit, GadgetBrowserState>(
      buildWhen: (p, c) => p.type != c.type,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Tipe: '),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: state.type,
                    items: const [
                      DropdownMenuItem(value: 'smartphone', child: Text('Smartphone')),
                      DropdownMenuItem(value: 'laptop', child: Text('Laptop')),
                    ],
                    onChanged: (v) => context.read<GadgetBrowserCubit>().setType(v!),
                  ),
                ],
              ),
              SizedBox(
                width: 250,
                child: SearchBar(
                  hintText: 'Cari gadget...',
                  leading: const Icon(Icons.search),
                  onChanged: (q) => context.read<GadgetBrowserCubit>().setQuery(q),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GadgetGrid extends StatelessWidget {
  const GadgetGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 760;
    return BlocBuilder<GadgetBrowserCubit, GadgetBrowserState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: state.items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isNarrow ? 1 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 180,
          ),
          itemBuilder: (_, i) {
            final g = state.items[i];
            return GadgetListItem(gadget: g);
          },
        );
      },
    );
  }
}

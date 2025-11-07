
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../cubit/gadget_browser_cubit.dart';
import '../widgets/gadget_card.dart'; // Import GadgetCard yang baru

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
    final isNarrow = 100.w < 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jelajahi Gadget', style: Theme.of(context).textTheme.headlineMedium),
        SizedBox(height: 2.h),
        Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
                SizedBox(width: 4.w),
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
        SizedBox(height: 2.5.h),
        Expanded(
          child: BlocBuilder<GadgetBrowserCubit, GadgetBrowserState>(
            builder: (context, state) {
              return GridView.builder(
                itemCount: state.items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isNarrow ? 2 : 4,
                  crossAxisSpacing: 4.w,
                  mainAxisSpacing: 2.h,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (_, i) {
                  final g = state.items[i];
                  return GadgetCard(gadget: g); // Menggunakan GadgetCard yang baru
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

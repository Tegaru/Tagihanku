import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../global_widgets/section_header.dart';
import '../providers/bills_provider.dart';
import '../providers/categories_provider.dart';
import '../screens/bill_form_screen.dart';
import '../widgets/bill_card.dart';
import '../widgets/category_card.dart';

class BillsScreen extends ConsumerWidget {
  const BillsScreen({super.key});

  static const routeName = 'bills';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(billsProvider);

    return SafeArea(
      child: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          Row(
            children: [
              const Expanded(
                child: SectionHeader(
                  title: 'Daftar Tagihan',
                  subtitle: 'Kelola semua tagihan Anda',
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.push('/bills/form'),
                icon: const Icon(Icons.add),
                label: const Text('Tambah'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _CategoryGrid(),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Semua Tagihan'),
          const SizedBox(height: AppSpacing.md),
          bills.when(
            data: (items) => Column(
              children: items
                  .map((bill) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.md),
                        child: BillCard(
                          bill: bill,
                          onTap: () => context.push(
                            '/bills/form/${bill.id}',
                          ),
                        ),
                      ))
                  .toList(),
            ),
            error: (error, _) => Text(error.toString()),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final bills = ref.watch(billsProvider);

    return categories.when(
      data: (items) {
        return bills.when(
          data: (billsList) {
            final counts = <int, int>{};
            for (final bill in billsList) {
              final id = bill.categoryId;
              if (id == null) continue;
              counts[id] = (counts[id] ?? 0) + 1;
            }
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.2,
              children: items
                  .map(
                    (category) => CategoryCard(
                      title: category.name,
                      count: '${counts[category.id] ?? 0} tagihan',
                      icon: _iconForCategory(category.name),
                    ),
                  )
                  .toList(),
            );
          },
          error: (error, _) => Text(error.toString()),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, _) => Text(error.toString()),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  IconData _iconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('utilitas')) return Icons.flash_on;
    if (lower.contains('asuransi')) return Icons.shield_outlined;
    if (lower.contains('subscription')) return Icons.autorenew;
    return Icons.push_pin_outlined;
  }
}

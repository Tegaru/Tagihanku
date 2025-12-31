import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../domain/entities/bill_entity.dart';
import '../../../global_widgets/section_header.dart';
import '../../../global_widgets/status_badge.dart';
import '../providers/home_provider.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const routeName = 'home';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);

    return SafeArea(
      child: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          const _HomeHeader(),
          const SizedBox(height: AppSpacing.md),
          _SearchField(
            controller: _searchController,
            onChanged: (value) {
              setState(() => _query = value.trim().toLowerCase());
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _InsightCard(
            totalAmount: _sumAmount(state),
            upcomingCount: _countUpcoming(state),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(
            title: 'Tagihan Mendesak',
            subtitle: 'Prioritaskan tagihan jatuh tempo terdekat',
          ),
          const SizedBox(height: AppSpacing.md),
          state.when(
            data: (items) {
              final filtered = _query.isEmpty
                  ? items
                  : items
                      .where((bill) =>
                          bill.name.toLowerCase().contains(_query))
                      .toList();
              if (filtered.isEmpty) {
                return const Text('Belum ada tagihan.');
              }
              final sorted = List<BillEntity>.from(filtered)
                ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
              return Column(
                children: sorted
                    .map((bill) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _UrgentBillCard(bill: bill),
                        ))
                    .toList(),
              );
            },
            error: (error, _) => Text(error.toString()),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final name = auth.profileName ??
        (auth.email != null && auth.email!.contains('@')
            ? auth.email!.split('@').first
            : 'User');
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hai, $name!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Kelola tagihan Anda dengan mudah',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primary,
          child: Text('U', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(color: isDark ? Colors.white : null),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.search,
          color: isDark ? Colors.white70 : null,
        ),
        hintText: 'Cari tagihan...',
        hintStyle: TextStyle(color: isDark ? Colors.white70 : null),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.totalAmount,
    required this.upcomingCount,
  });

  final int totalAmount;
  final int upcomingCount;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).cardColor;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF3EEFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wallet, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insight Keuangan',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  'Total tagihan bulan ini: ${MoneyFormatter.format(totalAmount)}. '
                  'Bayar $upcomingCount tagihan sebelum jatuh tempo!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

int _sumAmount(AsyncValue<List<BillEntity>> state) {
  return state.maybeWhen(
    data: (items) => items.fold(0, (sum, item) => sum + item.amount),
    orElse: () => 0,
  );
}

int _countUpcoming(AsyncValue<List<BillEntity>> state) {
  return state.maybeWhen(
    data: (items) => items.length,
    orElse: () => 0,
  );
}

class _UrgentBillCard extends StatelessWidget {
  const _UrgentBillCard({required this.bill});

  final BillEntity bill;

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel(bill.status);
    final statusColor = _statusColor(bill.status);
    final isPaid = bill.status == BillStatus.paid;

    final surface = Theme.of(context).cardColor;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: statusColor, width: 2),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration:
                            isPaid ? TextDecoration.lineThrough : null,
                        color: isPaid
                            ? Theme.of(context).textTheme.labelMedium?.color
                            : null,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  MoneyFormatter.format(bill.amount),
                  style: isPaid
                      ? Theme.of(context).textTheme.labelMedium
                      : Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  isPaid
                      ? 'Dibayar: ${DateFormatter.day(bill.dueDate)}'
                      : 'Jatuh tempo ${DateFormatter.day(bill.dueDate)}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          StatusBadge(status: bill.status, label: statusLabel),
        ],
      ),
    );
  }

  String _statusLabel(BillStatus status) {
    switch (status) {
      case BillStatus.overdue:
        return 'Terlambat';
      case BillStatus.paid:
        return 'Sudah Bayar';
      case BillStatus.unpaid:
        return 'Mendatang';
    }
  }

  Color _statusColor(BillStatus status) {
    switch (status) {
      case BillStatus.overdue:
        return AppColors.accentRed;
      case BillStatus.paid:
        return AppColors.accentGreen;
      case BillStatus.unpaid:
        return AppColors.accentYellow;
    }
  }
}

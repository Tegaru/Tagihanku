import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../global_widgets/section_header.dart';
import '../../bills/providers/bills_provider.dart';
import '../../../../domain/entities/bill_entity.dart';
import '../providers/calendar_provider.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  static const routeName = 'calendar';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);
    final notifier = ref.read(calendarProvider.notifier);

    return SafeArea(
      child: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          const SectionHeader(
            title: 'Kalender Tagihan',
            subtitle: 'Lihat jadwal jatuh tempo tagihan Anda',
          ),
          const SizedBox(height: AppSpacing.lg),
          _CalendarHeader(
            monthLabel: DateFormatter.month(state.month),
            onPrev: notifier.previousMonth,
            onNext: notifier.nextMonth,
          ),
          const SizedBox(height: AppSpacing.md),
          _CalendarGrid(month: state.month),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(
            title: 'Tagihan Mendatang',
            subtitle: 'Tagihan yang akan jatuh tempo',
          ),
          const SizedBox(height: AppSpacing.md),
          const _UpcomingBillSection(),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.monthLabel,
    required this.onPrev,
    required this.onNext,
  });

  final String monthLabel;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
        Expanded(
          child: Center(
            child: Text(
              monthLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }
}

class _CalendarGrid extends ConsumerWidget {
  const _CalendarGrid({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = _daysInMonth(month);
    final startWeekday = DateTime(month.year, month.month, 1).weekday;
    final cells = <int?>[];
    cells.addAll(List<int?>.filled(startWeekday - 1, null));
    cells.addAll(days.map((d) => d.day));
    final bills = ref.watch(billsProvider);

    final surface = Theme.of(context).cardColor;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          _WeekHeader(),
          const SizedBox(height: AppSpacing.sm),
          bills.when(
            data: (items) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cells.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  final value = cells[index];
                  if (value == null) {
                    return const SizedBox.shrink();
                  }
                  final marker = _markerForDay(items, value);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$value'),
                      const SizedBox(height: 4),
                      if (marker != null)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: marker,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  );
                },
              );
            },
            error: (error, _) => Text(error.toString()),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  List<DateTime> _daysInMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    final days = nextMonth.difference(firstDay).inDays;
    return List.generate(days, (i) => DateTime(date.year, date.month, i + 1));
  }

  Color? _markerForDay(List<BillEntity> items, int day) {
    final list = items.where(
      (bill) =>
          bill.dueDate.year == month.year &&
          bill.dueDate.month == month.month &&
          bill.dueDate.day == day,
    );
    if (list.isEmpty) return null;
    if (list.any((bill) => bill.status == BillStatus.overdue)) {
      return AppColors.accentRed;
    }
    if (list.any((bill) => bill.status == BillStatus.unpaid)) {
      return AppColors.accentYellow;
    }
    if (list.any((bill) => bill.status == BillStatus.paid)) {
      return AppColors.accentGreen;
    }
    return null;
  }
}

class _WeekHeader extends StatelessWidget {
  final List<String> labels = const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  const _WeekHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: labels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _UpcomingBillSection extends ConsumerWidget {
  const _UpcomingBillSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(billsProvider);
    return bills.when(
      data: (items) {
        if (items.isEmpty) {
          return const Text('Belum ada tagihan.');
        }
        final upcoming = items
            .where((bill) => bill.status != BillStatus.paid)
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
        if (upcoming.isEmpty) {
          return const Text('Tidak ada tagihan mendatang.');
        }
        return Column(
          children: upcoming
              .map(
                (bill) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _UpcomingBillTile(bill: bill),
                ),
              )
              .toList(),
        );
      },
      error: (error, _) => Text(error.toString()),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  String _buildSubtitle(BillEntity bill) {
    final now = DateTime.now();
    final diffDays =
        bill.dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (bill.status == BillStatus.paid) {
      return 'Sudah dibayar';
    }
    if (diffDays < 0) {
      return 'Terlambat ${diffDays.abs()} hari';
    }
    if (diffDays == 0) {
      return 'Jatuh tempo hari ini';
    }
    return '$diffDays hari lagi';
  }

  Color _statusColor(BillStatus status) {
    switch (status) {
      case BillStatus.overdue:
        return AppColors.accentRed;
      case BillStatus.unpaid:
        return AppColors.accentYellow;
      case BillStatus.paid:
        return AppColors.accentGreen;
    }
  }
}

class _UpcomingBillTile extends StatelessWidget {
  const _UpcomingBillTile({required this.bill});

  final BillEntity bill;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(bill.status);
    final subtitle = _buildSubtitle(bill);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${MoneyFormatter.format(bill.amount)} • $subtitle',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Icon(Icons.error_outline, color: statusColor),
        ],
      ),
    );
  }

  String _buildSubtitle(BillEntity bill) {
    final now = DateTime.now();
    final diffDays =
        bill.dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (bill.status == BillStatus.paid) {
      return 'Sudah dibayar';
    }
    if (diffDays < 0) {
      return 'Terlambat ${diffDays.abs()} hari';
    }
    if (diffDays == 0) {
      return 'Jatuh tempo hari ini';
    }
    return '$diffDays hari lagi';
  }

  Color _statusColor(BillStatus status) {
    switch (status) {
      case BillStatus.overdue:
        return AppColors.accentRed;
      case BillStatus.unpaid:
        return AppColors.accentYellow;
      case BillStatus.paid:
        return AppColors.accentGreen;
    }
  }
}

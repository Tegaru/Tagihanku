import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/bill_entity.dart';
import '../../bills/providers/bills_provider.dart';

class StatsState {
  const StatsState({
    required this.totalPaid,
    required this.totalUnpaid,
    required this.totalOverdue,
    required this.average,
    required this.totalAll,
    required this.paidPercent,
    required this.unpaidPercent,
    required this.overdueCount,
  });

  final int totalPaid;
  final int totalUnpaid;
  final int totalOverdue;
  final int average;
  final int totalAll;
  final int paidPercent;
  final int unpaidPercent;
  final int overdueCount;
}

final statsProvider = Provider<AsyncValue<StatsState>>((ref) {
  final bills = ref.watch(billsProvider);
  return bills.whenData(_buildStats);
});

class ChartPoint {
  const ChartPoint({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;
}

final statsPeriodProvider = StateProvider<int>((ref) => 1);

final statsChartProvider = Provider<AsyncValue<List<ChartPoint>>>((ref) {
  final months = ref.watch(statsPeriodProvider);
  final bills = ref.watch(billsProvider);
  return bills.whenData((items) => _buildChart(items, months));
});

StatsState _buildStats(List<BillEntity> items) {
  final paid = _sumBy(items, BillStatus.paid);
  final overdue = _sumBy(items, BillStatus.overdue);
  final unpaid = _sumBy(items, BillStatus.unpaid);
  final total = paid + unpaid + overdue;
  final avg = items.isEmpty
      ? 0
      : (items.map((e) => e.amount).reduce((a, b) => a + b) ~/ items.length);
  final paidPercent = total == 0 ? 0 : ((paid / total) * 100).round();
  final unpaidPercent = total == 0 ? 0 : ((unpaid / total) * 100).round();
  final overdueCount = items.where((e) => e.status == BillStatus.overdue).length;
  return StatsState(
    totalPaid: paid,
    totalUnpaid: unpaid,
    totalOverdue: overdue,
    average: avg,
    totalAll: total,
    paidPercent: paidPercent,
    unpaidPercent: unpaidPercent,
    overdueCount: overdueCount,
  );
}

List<ChartPoint> _buildChart(List<BillEntity> items, int months) {
  final now = DateTime.now();
  final formatter = DateFormat('MMM', 'id_ID');
  final points = <ChartPoint>[];
  for (var i = months - 1; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    final total = items
        .where((bill) =>
            bill.dueDate.year == month.year &&
            bill.dueDate.month == month.month)
        .fold<int>(0, (sum, bill) => sum + bill.amount);
    points.add(
      ChartPoint(
        label: formatter.format(month),
        value: total.toDouble(),
      ),
    );
  }
  return points;
}

int _sumBy(List<BillEntity> items, BillStatus status) {
  return items
      .where((bill) => bill.status == status)
      .fold(0, (sum, bill) => sum + bill.amount);
}

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../domain/entities/bill_entity.dart';
import '../../../global_widgets/status_badge.dart';

class BillCard extends StatelessWidget {
  const BillCard({
    super.key,
    required this.bill,
    this.onTap,
  });

  final BillEntity bill;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).cardColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 52,
              decoration: BoxDecoration(
                color: _statusColor(bill.status),
                borderRadius: BorderRadius.circular(8),
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
                    MoneyFormatter.format(bill.amount),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            StatusBadge(
              status: bill.status,
              label: _statusLabel(bill.status),
            ),
          ],
        ),
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

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/bill_entity.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    required this.label,
  });

  final BillStatus status;
  final String label;

  Color get _color {
    switch (status) {
      case BillStatus.overdue:
        return AppColors.accentRed;
      case BillStatus.unpaid:
        return AppColors.accentYellow;
      case BillStatus.paid:
        return AppColors.accentGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: _color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

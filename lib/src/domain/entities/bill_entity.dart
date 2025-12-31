enum BillStatus {
  unpaid,
  paid,
  overdue,
}

class BillEntity {
  const BillEntity({
    this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.categoryId,
    this.isRecurring = false,
    this.recurringPattern,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String name;
  final int amount;
  final DateTime dueDate;
  final BillStatus status;
  final int? categoryId;
  final bool isRecurring;
  final String? recurringPattern;
  final DateTime createdAt;
  final DateTime updatedAt;
}

import '../../domain/entities/bill_entity.dart';

class BillModel {
  BillModel({
    required this.id,
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

  final int id;
  final String name;
  final int amount;
  final DateTime dueDate;
  final BillStatus status;
  final int? categoryId;
  final bool isRecurring;
  final String? recurringPattern;
  final DateTime createdAt;
  final DateTime updatedAt;

  BillEntity toEntity() {
    return BillEntity(
      id: id,
      name: name,
      amount: amount,
      dueDate: dueDate,
      status: status,
      categoryId: categoryId,
      isRecurring: isRecurring,
      recurringPattern: recurringPattern,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'amount': amount,
        'dueDate': dueDate.millisecondsSinceEpoch,
        'status': status.name,
        'categoryId': categoryId,
        'isRecurring': isRecurring,
        'recurringPattern': recurringPattern,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  static BillModel fromMap(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] as int,
      name: map['name'] as String,
      amount: map['amount'] as int,
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int),
      status: BillStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BillStatus.unpaid,
      ),
      categoryId: map['categoryId'] as int?,
      isRecurring: map['isRecurring'] as bool? ?? false,
      recurringPattern: map['recurringPattern'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }
}

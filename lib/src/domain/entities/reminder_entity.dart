class ReminderEntity {
  const ReminderEntity({
    this.id,
    required this.billId,
    required this.reminderTime,
    this.isActive = true,
  });

  final int? id;
  final int billId;
  final DateTime reminderTime;
  final bool isActive;
}

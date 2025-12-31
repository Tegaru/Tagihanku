import 'package:fpdart/fpdart.dart';

import '../entities/reminder_entity.dart';

abstract class ReminderRepository {
  Future<Either<String, ReminderEntity>> add(ReminderEntity reminder);
  Future<Either<String, bool>> removeByBill(int billId);
}

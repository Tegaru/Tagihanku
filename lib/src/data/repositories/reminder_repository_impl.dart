import 'package:fpdart/fpdart.dart';

import '../../domain/entities/reminder_entity.dart';
import '../../domain/repositories/reminder_repository.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  @override
  Future<Either<String, ReminderEntity>> add(ReminderEntity reminder) async {
    return Right(reminder);
  }

  @override
  Future<Either<String, bool>> removeByBill(int billId) async {
    return const Right(true);
  }
}

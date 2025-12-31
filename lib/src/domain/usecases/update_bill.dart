import 'package:fpdart/fpdart.dart';

import '../entities/bill_entity.dart';
import '../repositories/bill_repository.dart';

class UpdateBill {
  UpdateBill(this._repository);

  final BillRepository _repository;

  Future<Either<String, BillEntity>> call(BillEntity bill) {
    return _repository.update(bill);
  }
}

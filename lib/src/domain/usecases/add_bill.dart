import 'package:fpdart/fpdart.dart';

import '../entities/bill_entity.dart';
import '../repositories/bill_repository.dart';

class AddBill {
  AddBill(this._repository);

  final BillRepository _repository;

  Future<Either<String, BillEntity>> call(BillEntity bill) {
    return _repository.add(bill);
  }
}

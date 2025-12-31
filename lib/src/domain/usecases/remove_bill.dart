import 'package:fpdart/fpdart.dart';

import '../repositories/bill_repository.dart';

class RemoveBill {
  RemoveBill(this._repository);

  final BillRepository _repository;

  Future<Either<String, bool>> call(int id) {
    return _repository.remove(id);
  }
}

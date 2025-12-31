import 'package:fpdart/fpdart.dart';

import '../entities/bill_entity.dart';
import '../repositories/bill_repository.dart';

class GetUpcomingBills {
  GetUpcomingBills(this._repository);

  final BillRepository _repository;

  Future<Either<String, List<BillEntity>>> call() {
    return _repository.getUpcoming();
  }
}

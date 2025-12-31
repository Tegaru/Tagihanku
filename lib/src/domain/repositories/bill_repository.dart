import 'package:fpdart/fpdart.dart';

import '../entities/bill_entity.dart';

abstract class BillRepository {
  Future<Either<String, List<BillEntity>>> getAll();
  Future<Either<String, List<BillEntity>>> getUpcoming();
  Future<Either<String, BillEntity>> add(BillEntity bill);
  Future<Either<String, BillEntity>> update(BillEntity bill);
  Future<Either<String, bool>> remove(int id);
}

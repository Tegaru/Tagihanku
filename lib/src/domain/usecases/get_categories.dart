import 'package:fpdart/fpdart.dart';

import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetCategories {
  GetCategories(this._repository);

  final CategoryRepository _repository;

  Future<Either<String, List<CategoryEntity>>> call() {
    return _repository.getAll();
  }
}

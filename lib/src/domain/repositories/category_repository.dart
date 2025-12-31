import 'package:fpdart/fpdart.dart';

import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<Either<String, List<CategoryEntity>>> getAll();
}

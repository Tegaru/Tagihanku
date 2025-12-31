import 'package:fpdart/fpdart.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  @override
  Future<Either<String, List<CategoryEntity>>> getAll() async {
    return const Right([
      CategoryEntity(id: 1, name: 'Utilitas', colorHex: '#FFB84C'),
      CategoryEntity(id: 2, name: 'Asuransi', colorHex: '#FF6B6B'),
      CategoryEntity(id: 3, name: 'Subscription', colorHex: '#6C8CFF'),
      CategoryEntity(id: 4, name: 'Lainnya', colorHex: '#9B9B9B'),
    ]);
  }
}

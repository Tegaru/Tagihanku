import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/di.dart';
import '../../../../domain/entities/category_entity.dart';
import '../../../../domain/usecases/get_categories.dart';

final categoriesProvider =
    FutureProvider.autoDispose<List<CategoryEntity>>((ref) async {
  final usecase = ref.watch(getCategoriesProvider);
  final result = await usecase();
  return result.match(
    (error) => throw Exception(error),
    (items) => items,
  );
});

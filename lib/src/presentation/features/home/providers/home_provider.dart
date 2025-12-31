import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/di.dart';
import '../../../../domain/entities/bill_entity.dart';
import '../../../../domain/usecases/get_upcoming_bills.dart';

final homeProvider =
    StateNotifierProvider<HomeNotifier, AsyncValue<List<BillEntity>>>(
        (ref) {
  final usecase = ref.watch(getUpcomingBillsProvider);
  return HomeNotifier(usecase)..load();
});

class HomeNotifier extends StateNotifier<AsyncValue<List<BillEntity>>> {
  HomeNotifier(this._usecase) : super(const AsyncValue.loading());

  final GetUpcomingBills _usecase;

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _usecase();
    state = result.match(
      (error) => AsyncValue.error(error, StackTrace.current),
      AsyncValue.data,
    );
  }
}

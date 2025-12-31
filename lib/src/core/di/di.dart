import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/bill_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../data/services/notification_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/bill_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/usecases/add_bill.dart';
import '../../domain/usecases/get_bills.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_upcoming_bills.dart';
import '../../domain/usecases/remove_bill.dart';
import '../../domain/usecases/update_bill.dart';
import '../../presentation/routing/app_router.dart';

final billRepositoryProvider = Provider<BillRepository>((ref) {
  return BillRepositoryImpl();
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl();
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepositoryImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  service.requestPermission();
  return service;
});

final getBillsProvider = Provider<GetBills>((ref) {
  return GetBills(ref.watch(billRepositoryProvider));
});

final getUpcomingBillsProvider = Provider<GetUpcomingBills>((ref) {
  return GetUpcomingBills(ref.watch(billRepositoryProvider));
});

final addBillProvider = Provider<AddBill>((ref) {
  return AddBill(ref.watch(billRepositoryProvider));
});

final updateBillProvider = Provider<UpdateBill>((ref) {
  return UpdateBill(ref.watch(billRepositoryProvider));
});

final removeBillProvider = Provider<RemoveBill>((ref) {
  return RemoveBill(ref.watch(billRepositoryProvider));
});

final getCategoriesProvider = Provider<GetCategories>((ref) {
  return GetCategories(ref.watch(categoryRepositoryProvider));
});

final appRouterProvider = Provider<GoRouter>((ref) {
  return buildRouter(ref);
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/di.dart';
import '../../../../domain/entities/bill_entity.dart';
import '../../../../domain/usecases/add_bill.dart';
import '../../../../domain/usecases/get_bills.dart';
import '../../../../domain/usecases/remove_bill.dart';
import '../../../../domain/usecases/update_bill.dart';
import '../../../features/settings/providers/settings_provider.dart';
import '../../../../data/services/notification_service.dart';

final billsProvider =
    StateNotifierProvider<BillsNotifier, AsyncValue<List<BillEntity>>>((ref) {
  final getBills = ref.watch(getBillsProvider);
  final addBill = ref.watch(addBillProvider);
  final updateBill = ref.watch(updateBillProvider);
  final removeBill = ref.watch(removeBillProvider);
  final notifications = ref.watch(notificationServiceProvider);
  final isNotificationsEnabled = () => ref.read(settingsProvider).notificationsEnabled;
  return BillsNotifier(
    getBills,
    addBill,
    updateBill,
    removeBill,
    notifications,
    isNotificationsEnabled,
  )..load();
});

class BillsNotifier extends StateNotifier<AsyncValue<List<BillEntity>>> {
  BillsNotifier(
    this._getBills,
    this._addBill,
    this._updateBill,
    this._removeBill,
    this._notifications,
    this._isNotificationsEnabled,
  ) : super(const AsyncValue.loading());

  final GetBills _getBills;
  final AddBill _addBill;
  final UpdateBill _updateBill;
  final RemoveBill _removeBill;
  final NotificationService _notifications;
  final bool Function() _isNotificationsEnabled;

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _getBills();
    state = result.match(
      (error) => AsyncValue.error(error, StackTrace.current),
      AsyncValue.data,
    );
    await refreshNotifications(enabled: _isNotificationsEnabled());
  }

  Future<bool> create(BillEntity bill, {required bool isPro}) async {
    final current = state;
    if (!isPro && current is AsyncData<List<BillEntity>>) {
      if (current.value.length >= 10) {
        return false;
      }
    }
    final result = await _addBill(bill);
    return result.match(
      (_) => false,
      (_) {
        load();
        return true;
      },
    );
  }

  Future<bool> update(BillEntity bill) async {
    final result = await _updateBill(bill);
    return result.match(
      (_) => false,
      (_) {
        load();
        return true;
      },
    );
  }

  Future<void> remove(int id) async {
    await _removeBill(id);
    await load();
  }

  Future<void> refreshNotifications({required bool enabled}) async {
    if (!enabled) {
      await _notifications.cancelAll();
      return;
    }
    final current = state;
    if (current is! AsyncData<List<BillEntity>>) return;
    for (final bill in current.value) {
      await _scheduleForBill(bill);
    }
  }

  Future<void> _scheduleForBill(BillEntity bill) async {
    if (bill.id == null) return;
    if (bill.status == BillStatus.paid) {
      await _notifications.cancelReminder(bill.id!);
      return;
    }
    await _notifications.scheduleBillReminder(
      id: bill.id!,
      title: 'Pengingat Tagihan',
      body: '${bill.name} jatuh tempo besok',
      dueDate: bill.dueDate,
      daysBefore: 1,
      time: const TimeOfDay(hour: 7, minute: 0),
    );
  }
}

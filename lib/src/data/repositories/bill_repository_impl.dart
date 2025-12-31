import 'package:fpdart/fpdart.dart';

import '../../domain/entities/bill_entity.dart';
import '../../domain/repositories/bill_repository.dart';
import '../datasources/local_storage.dart';
import '../models/bill_model.dart';

class BillRepositoryImpl implements BillRepository {
  BillRepositoryImpl({LocalStorage? storage})
      : _storage = storage ?? LocalStorage();

  final LocalStorage _storage;

  Future<void> _ensureSeeded() async {
    final raw = await _storage.loadBills();
    if (raw.isNotEmpty) return;
    final now = DateTime.now();
    final seed = [
      BillModel(
        id: 1,
        name: 'Tagihan Listrik',
        amount: 450000,
        dueDate: DateTime(now.year, now.month, 5),
        status: BillStatus.overdue,
        categoryId: 1,
        createdAt: now,
        updatedAt: now,
      ),
      BillModel(
        id: 2,
        name: 'Tagihan Air',
        amount: 280000,
        dueDate: DateTime(now.year, now.month, 13),
        status: BillStatus.unpaid,
        categoryId: 1,
        createdAt: now,
        updatedAt: now,
      ),
      BillModel(
        id: 3,
        name: 'Tagihan Internet',
        amount: 399000,
        dueDate: DateTime(now.year, now.month, 23),
        status: BillStatus.unpaid,
        categoryId: 1,
        createdAt: now,
        updatedAt: now,
      ),
      BillModel(
        id: 4,
        name: 'Tagihan Asuransi',
        amount: 750000,
        dueDate: DateTime(now.year, now.month, 8),
        status: BillStatus.paid,
        categoryId: 2,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    await _storage.saveBills(seed.map((e) => e.toMap()).toList());
  }

  @override
  Future<Either<String, List<BillEntity>>> getAll() async {
    try {
      await _ensureSeeded();
      final raw = await _storage.loadBills();
      final items = raw.map(BillModel.fromMap).map((e) => e.toEntity()).toList();
      return Right(items);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<BillEntity>>> getUpcoming() async {
    final result = await getAll();
    return result.map(
      (items) => items.where((bill) => bill.status != BillStatus.paid).toList(),
    );
  }

  @override
  Future<Either<String, BillEntity>> add(BillEntity bill) async {
    try {
      final raw = await _storage.loadBills();
      final items = raw.map(BillModel.fromMap).toList();
      final nextId = items.isEmpty
          ? 1
          : (items.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
      final created = BillModel(
        id: nextId,
        name: bill.name,
        amount: bill.amount,
        dueDate: bill.dueDate,
        status: bill.status,
        categoryId: bill.categoryId,
        isRecurring: bill.isRecurring,
        recurringPattern: bill.recurringPattern,
        createdAt: bill.createdAt,
        updatedAt: bill.updatedAt,
      );
      items.add(created);
      await _storage.saveBills(items.map((e) => e.toMap()).toList());
      return Right(created.toEntity());
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, BillEntity>> update(BillEntity bill) async {
    try {
      final raw = await _storage.loadBills();
      final items = raw.map(BillModel.fromMap).toList();
      final index = items.indexWhere((item) => item.id == bill.id);
      if (index == -1) {
        return const Left('Tagihan tidak ditemukan');
      }
      items[index] = BillModel(
        id: bill.id!,
        name: bill.name,
        amount: bill.amount,
        dueDate: bill.dueDate,
        status: bill.status,
        categoryId: bill.categoryId,
        isRecurring: bill.isRecurring,
        recurringPattern: bill.recurringPattern,
        createdAt: bill.createdAt,
        updatedAt: bill.updatedAt,
      );
      await _storage.saveBills(items.map((e) => e.toMap()).toList());
      return Right(items[index].toEntity());
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> remove(int id) async {
    try {
      final raw = await _storage.loadBills();
      final items = raw.map(BillModel.fromMap).toList();
      items.removeWhere((item) => item.id == id);
      await _storage.saveBills(items.map((e) => e.toMap()).toList());
      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

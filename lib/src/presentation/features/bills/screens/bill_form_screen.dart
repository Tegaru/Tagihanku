import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/entities/bill_entity.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/categories_provider.dart';
import '../../home/providers/home_provider.dart';
import '../providers/bills_provider.dart';

class BillFormScreen extends ConsumerStatefulWidget {
  const BillFormScreen({super.key, this.billId});

  static const routeName = 'bill-form';
  static const editRouteName = 'bill-edit';

  final int? billId;

  @override
  ConsumerState<BillFormScreen> createState() => _BillFormScreenState();
}

class _BillFormScreenState extends ConsumerState<BillFormScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _dueDate;
  BillStatus _status = BillStatus.unpaid;
  int? _categoryId;

  @override
  void initState() {
    super.initState();
    final bill = _findBill();
    if (bill != null) {
      _nameController.text = bill.name;
      _amountController.text = bill.amount.toString();
      _dueDate = bill.dueDate;
      _status = bill.status;
      _categoryId = bill.categoryId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  BillEntity? _findBill() {
    final state = ref.read(billsProvider);
    if (state is AsyncData<List<BillEntity>>) {
      for (final bill in state.value) {
        if (bill.id == widget.billId) return bill;
      }
    }
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final amount = int.tryParse(_amountController.text.trim());

    if (name.isEmpty || amount == null || _dueDate == null) {
      _showSnack('Nama, jumlah, dan tanggal wajib diisi');
      return;
    }

    final now = DateTime.now();
    final isEdit = widget.billId != null;
    final entity = BillEntity(
      id: widget.billId,
      name: name,
      amount: amount,
      dueDate: _dueDate!,
      status: _status,
      categoryId: _categoryId,
      createdAt: now,
      updatedAt: now,
    );

    final notifier = ref.read(billsProvider.notifier);
    final isPro = ref.read(authProvider).isPro;
    final ok = isEdit
        ? await notifier.update(entity)
        : await notifier.create(entity, isPro: isPro);
    if (!ok) {
      if (!isPro) {
        _showSnack('Batas 10 tagihan untuk versi gratis. Upgrade ke PRO.');
      } else {
        _showSnack('Gagal menyimpan tagihan');
      }
      return;
    }
    ref.read(homeProvider.notifier).load();
    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    final id = widget.billId;
    if (id == null) return;
    await ref.read(billsProvider.notifier).remove(id);
    ref.read(homeProvider.notifier).load();
    if (mounted) context.pop();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.billId != null;
    final categories = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final labelColor = isDark ? Colors.white70 : AppColors.textSecondary;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Tagihan' : 'Tambah Tagihan'),
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(color: isDark ? Colors.white : null),
              decoration: InputDecoration(
                labelText: 'Nama Tagihan',
                labelStyle:
                    TextStyle(color: isDark ? Colors.white70 : null),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDark ? Colors.white : null),
              decoration: InputDecoration(
                labelText: 'Jumlah (Rp)',
                labelStyle:
                    TextStyle(color: isDark ? Colors.white70 : null),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: isDark ? Colors.white70 : null,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _dueDate == null
                          ? 'Pilih tanggal jatuh tempo'
                          : DateFormatter.day(_dueDate!),
                      style: TextStyle(color: isDark ? Colors.white : null),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<BillStatus>(
              value: _status,
              style: TextStyle(color: textColor),
              dropdownColor: Theme.of(context).cardColor,
              items: _statusOptions
                  .map(
                    (option) => DropdownMenuItem(
                      value: option.status,
                      child: Text(option.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
              decoration: InputDecoration(
                labelText: 'Status',
                labelStyle: TextStyle(color: labelColor),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            categories.when(
              data: (items) {
                return DropdownButtonFormField<int?>(
                  value: _categoryId,
                  style: TextStyle(color: textColor),
                  dropdownColor: Theme.of(context).cardColor,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Tanpa Kategori'),
                    ),
                    ...items.map(
                      (category) => DropdownMenuItem<int?>(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _categoryId = value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    labelStyle: TextStyle(color: labelColor),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text(error.toString()),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Tagihan'),
            ),
            if (isEdit) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: _delete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentRed,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Hapus Tagihan'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusOption {
  const _StatusOption(this.status, this.label);

  final BillStatus status;
  final String label;
}

const _statusOptions = [
  _StatusOption(BillStatus.unpaid, 'Belum Dibayar'),
  _StatusOption(BillStatus.paid, 'Sudah Dibayar'),
  _StatusOption(BillStatus.overdue, 'Terlambat'),
];

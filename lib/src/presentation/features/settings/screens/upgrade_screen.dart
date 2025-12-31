import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/qris_dynamic.dart';
import '../../auth/providers/auth_provider.dart';

class UpgradeScreen extends ConsumerWidget {
  const UpgradeScreen({super.key});

  static const routeName = 'upgrade';
  static const _staticQris =
      '00020101021226570011ID.DANA.WWW011893600915399731458602099973145860303UMI51440014ID.CO.QRIS.WWW0215ID10254334477250303UMI5204511153033605405150005802ID5911TEGAR STORE6011Kab. Jepara61055945463043367';
  static const _amount = '10000';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    final dynamicQris = QrisDynamic.toDynamic(
      staticQris: _staticQris,
      amount: _amount,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade ke PRO')),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fitur PRO', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              '• Unlimited Tagihan\n'
              '• Dark Mode\n'
              '• Analisis Tagihan (Stats)',
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  const Text(
                    'Harga Upgrade',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text('Rp 10.000'),
                  const SizedBox(height: AppSpacing.md),
                  QrImageView(
                    data: dynamicQris,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text('TEGAR STORE'),
                  const SizedBox(height: 4),
                  const Text('Scan QRIS untuk bayar dan aktifkan PRO'),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    auth.isPro
                        ? null
                        : () async {
                          await ref.read(authProvider.notifier).upgradeToPro();
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(auth.isPro ? 'Sudah PRO' : 'Saya Sudah Bayar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

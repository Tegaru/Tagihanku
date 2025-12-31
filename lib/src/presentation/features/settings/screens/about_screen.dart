import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const routeName = 'about';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Tagihanku'),
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo_tagihanku.png',
                width: 120,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Tagihanku',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Versi 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Aplikasi pencatat dan pengingat tagihan untuk membantu '
              'pengelolaan keuangan pribadi.',
            ),
          ],
        ),
      ),
    );
  }
}

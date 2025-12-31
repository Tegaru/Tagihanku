import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../global_widgets/section_header.dart';
import '../../auth/providers/auth_provider.dart';
import '../../bills/providers/bills_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const routeName = 'settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final authState = ref.watch(authProvider);

    return SafeArea(
      child: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          const SectionHeader(
            title: 'Pengaturan',
            subtitle: 'Kelola akun dan preferensi aplikasi',
          ),
          const SizedBox(height: AppSpacing.md),
          _ProfileCard(
            email: authState.email ?? 'user@email.com',
            profileName: authState.profileName,
            isPro: authState.isPro,
          ),
          const SizedBox(height: AppSpacing.md),
          SettingsTile(
            title: 'Edit Profil',
            subtitle: 'Ubah nama dan foto profil',
            leading: _IconCircle(icon: Icons.person_outline),
            onTap: () {
              context.push('/settings/edit-profile');
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'Notifikasi',
            subtitle: 'Atur reminder pembayaran',
            leading: _IconCircle(icon: Icons.notifications_outlined),
            trailing: Switch(
              value: state.notificationsEnabled,
              onChanged: (value) {
                notifier.toggleNotifications(value);
                ref
                    .read(billsProvider.notifier)
                    .refreshNotifications(enabled: value);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'Tema',
            subtitle:
                authState.isPro ? 'Light / Dark mode' : 'Fitur PRO untuk Dark',
            leading: _IconCircle(icon: Icons.dark_mode_outlined),
            trailing: DropdownButton<ThemeModeOption>(
              value: state.themeMode,
              underline: const SizedBox.shrink(),
              dropdownColor: Theme.of(context).cardColor,
              items: ThemeModeOption.values
                  .map(
                    (mode) => DropdownMenuItem(
                      value: mode,
                      child: Text(
                        mode.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : null,
                            ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: authState.isPro
                  ? (mode) {
                      if (mode != null) notifier.changeTheme(mode);
                    }
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'Upgrade ke PRO',
            subtitle: 'Bayar via QRIS untuk fitur penuh',
            leading: _IconCircle(icon: Icons.workspace_premium_outlined),
            onTap: () {
              context.push('/upgrade');
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          SettingsTile(
            title: 'Tentang Tagihanku',
            subtitle: 'Versi 1.0.0',
            leading: _IconCircle(icon: Icons.info_outline),
            onTap: () {
              context.push('/settings/about');
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          SettingsTile(
            title: 'Keluar',
            subtitle: 'Logout dari akun kamu',
            leading: const Icon(Icons.logout, color: AppColors.accentRed),
            trailing: const SizedBox.shrink(),
            isDanger: true,
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.email,
    required this.isPro,
    this.profileName,
  });

  final String email;
  final bool isPro;
  final String? profileName;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).cardColor;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFEFF2FF),
            child: Text('U'),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (profileName == null || profileName!.isEmpty)
                      ? (email.isEmpty ? 'User Name' : email.split('@').first)
                      : profileName!,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPro
                        ? const Color(0xFFFFF4E5)
                        : const Color(0xFFEFF2FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isPro ? 'Member PRO' : 'Member Aktif',
                    style: TextStyle(
                      fontSize: 11,
                      color: isPro ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: Color(0xFFF3EEFF),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primary),
    );
  }
}

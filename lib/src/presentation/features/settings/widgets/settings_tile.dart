import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.isDanger = false,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool isDanger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? AppColors.accentRed : AppColors.outline;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).cardColor;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: leading,
        title: Text(
          title,
          style: isDark
              ? Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white)
              : null,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: isDark
                    ? Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: Colors.white70)
                    : null,
              )
            : null,
        trailing: trailing ??
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white70 : null,
            ),
        onTap: onTap,
      ),
    );
  }
}

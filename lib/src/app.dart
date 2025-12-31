import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/di.dart';
import 'core/themes/app_theme.dart';
import 'presentation/features/settings/providers/settings_provider.dart';
import 'presentation/routing/app_router.dart';

class TagihankuApp extends ConsumerWidget {
  const TagihankuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(settingsProvider).themeMode;

    return MaterialApp.router(
      title: 'Tagihanku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _mapThemeMode(themeMode),
      routerConfig: router,
    );
  }
}

ThemeMode _mapThemeMode(ThemeModeOption mode) {
  switch (mode) {
    case ThemeModeOption.light:
      return ThemeMode.light;
    case ThemeModeOption.dark:
      return ThemeMode.dark;
    case ThemeModeOption.system:
      return ThemeMode.system;
  }
}

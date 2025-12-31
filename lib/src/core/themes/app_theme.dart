import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.surface,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          background: AppColors.background,
        ),
        textTheme: const TextTheme(
          headlineMedium: AppTextStyles.headlineMedium,
          titleMedium: AppTextStyles.title,
          bodyMedium: AppTextStyles.body,
          labelMedium: AppTextStyles.label,
        ),
        cardTheme: CardTheme(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      );

  static ThemeData get dark => light.copyWith(
        colorScheme: light.colorScheme.copyWith(
          brightness: Brightness.dark,
          background: const Color(0xFF0F0F1C),
          surface: const Color(0xFF1C1B2E),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1C),
        cardColor: const Color(0xFF1C1B2E),
        cardTheme: light.cardTheme.copyWith(
          color: const Color(0xFF1C1B2E),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF2F1FF),
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF2F1FF),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFFB8B6D9),
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            color: Color(0xFFB8B6D9),
          ),
        ),
      );
}

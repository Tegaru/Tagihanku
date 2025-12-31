import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemeModeOption { light, dark, system }

class SettingsState {
  const SettingsState({
    required this.notificationsEnabled,
    required this.themeMode,
  });

  final bool notificationsEnabled;
  final ThemeModeOption themeMode;

  SettingsState copyWith({
    bool? notificationsEnabled,
    ThemeModeOption? themeMode,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(
          const SettingsState(
            notificationsEnabled: true,
            themeMode: ThemeModeOption.light,
          ),
        );

  void toggleNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
  }

  void changeTheme(ThemeModeOption mode) {
    state = state.copyWith(themeMode: mode);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

enum ThemeModeOption { light, dark, system }

class ThemeState {
  final ThemeModeOption mode;

  const ThemeState({this.mode = ThemeModeOption.system});

  ThemeMode get themeMode {
    switch (mode) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final box = await Hive.openBox('settings');
    final saved = box.get('themeMode', defaultValue: 'system') as String;
    final mode = ThemeModeOption.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => ThemeModeOption.system,
    );
    state = ThemeState(mode: mode);
  }

  Future<void> setTheme(ThemeModeOption mode) async {
    state = ThemeState(mode: mode);
    final box = await Hive.openBox('settings');
    await box.put('themeMode', mode.name);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_theme_service.g.dart';

enum AppThemeMode { light, dark }

@riverpod
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError("Override");
}

@riverpod
class AppThemeService extends _$AppThemeService {
  @override
  AppThemeMode build() {
    final themeMode =
        ref.watch(sharedPreferencesProvider).getString('themeMode') ?? 'dark';
    return themeMode == 'light' ? AppThemeMode.light : AppThemeMode.dark;
  }

  void setTheme(AppThemeMode theme) {
    state = theme;
    ref
        .read(sharedPreferencesProvider)
        .setString('themeMode', theme == AppThemeMode.light ? 'light' : 'dark');
  }
}

ThemeMode getThemeMode(AppThemeMode theme) {
  return theme == AppThemeMode.light ? ThemeMode.light : ThemeMode.dark;
}

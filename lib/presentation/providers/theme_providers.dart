import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_providers.g.dart';

/// SharedPreferences 인스턴스 -- main.dart에서 override 필수.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  );
}

/// ThemeMode 상태 관리.
///
/// 기본값: [ThemeMode.dark] (패널 결정).
/// SharedPreferences에 'theme_mode' 키로 persist.
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString('theme_mode');
    if (saved == null) return ThemeMode.dark;

    return ThemeMode.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => ThemeMode.dark,
    );
  }

  /// ThemeMode를 변경하고 SharedPreferences에 저장한다.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('theme_mode', mode.name);
  }
}

/// 앱 Locale 상태 관리.
///
/// `null` = 시스템 언어 자동감지, `Locale('ko')` 등 = 명시적 오버라이드.
/// SharedPreferences에 'user_locale' 키로 persist.
@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString('user_locale');
    if (saved == null) return null;
    return Locale(saved);
  }

  /// Locale을 변경하고 SharedPreferences에 저장한다.
  ///
  /// `null`이면 시스템 언어로 복원.
  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove('user_locale');
    } else {
      await prefs.setString('user_locale', locale.languageCode);
    }
  }
}

import 'dart:math' as math;

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

/// WCAG 2.1 상대 휘도 기반 대비율 계산.
///
/// 반환값: 1.0 (동일) ~ 21.0 (흑백). 4.5 미만이면 AA 미충족.
double contrastRatio(Color fg, Color bg) {
  double luminanceComponent(double c) {
    return c <= 0.04045
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  double relativeLuminance(Color color) {
    final r = luminanceComponent(color.r);
    final g = luminanceComponent(color.g);
    final b = luminanceComponent(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  final l1 = relativeLuminance(fg);
  final l2 = relativeLuminance(bg);
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

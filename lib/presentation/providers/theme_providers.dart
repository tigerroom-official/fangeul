import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fangeul/presentation/theme/theme_palettes.dart';

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

/// 테마 seed color + 커스텀 글자색 선택 상태.
///
/// null이면 기본 틸 테마(수동 튜닝), non-null이면 fromSeed() 동적 생성.
/// 자유 피커 IAP 구매자는 customTextColor도 설정 가능 (프리미엄 차별화).
@Riverpod(keepAlive: true)
class ThemeColorNotifier extends _$ThemeColorNotifier {
  static const _seedKey = 'theme_seed_color';
  static const _textKey = 'theme_custom_text_color';

  @override
  Color? build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final hex = prefs.getString(_seedKey);
    if (hex == null) return null;
    return _parseHexColor(hex);
  }

  /// 커스텀 글자색 (자유 피커 IAP 전용). null이면 자동 대비.
  Color? get customTextColor {
    final prefs = ref.read(sharedPreferencesProvider);
    final hex = prefs.getString(_textKey);
    if (hex == null) return null;
    return _parseHexColor(hex);
  }

  /// hex 문자열을 Color로 파싱. 형식 오류 시 null 반환 (방어적 코딩).
  static Color? _parseHexColor(String hex) {
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  /// seed color 설정. null이면 기본 틸 테마로 복원.
  Future<void> setSeedColor(Color? color) async {
    state = color;
    final prefs = ref.read(sharedPreferencesProvider);
    if (color == null) {
      await prefs.remove(_seedKey);
      await prefs.remove(_textKey);
    } else {
      await prefs.setString(
        _seedKey,
        color.toARGB32().toRadixString(16).padLeft(8, '0'),
      );
    }
  }

  /// 커스텀 글자색 설정 (자유 피커 IAP 전용). null이면 자동 대비로 복원.
  Future<void> setCustomTextColor(Color? color) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (color == null) {
      await prefs.remove(_textKey);
    } else {
      await prefs.setString(
        _textKey,
        color.toARGB32().toRadixString(16).padLeft(8, '0'),
      );
    }
    ref.invalidateSelf();
  }

  /// 추천 팔레트 적용 (글자색 자동 대비).
  Future<void> applyPalette(ThemePalette palette) async {
    await setSeedColor(palette.seedColor);
  }

  /// 기본 테마로 복원.
  Future<void> resetToDefault() async {
    await setSeedColor(null);
  }
}

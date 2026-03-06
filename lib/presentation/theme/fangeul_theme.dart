import 'package:flutter/material.dart';

import 'package:fangeul/presentation/theme/fangeul_colors.dart';
import 'package:fangeul/presentation/theme/fangeul_text_styles.dart';

/// Fangeul ThemeData 팩토리.
///
/// M3 ColorScheme을 seed가 아닌 명시적 토큰으로 구성한다.
/// seed-only 생성 시 tonal surface 편차 위험 방지.
abstract final class FangeulTheme {
  /// 다크 테마 (기본값).
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: FangeulColors.primary,
        onPrimary: FangeulColors.darkBackground,
        primaryContainer: FangeulColors.primaryContainerDark,
        onPrimaryContainer: FangeulColors.primary,
        secondary: FangeulColors.secondary,
        onSecondary: FangeulColors.darkBackground,
        tertiary: FangeulColors.tertiary,
        onTertiary: FangeulColors.darkBackground,
        surface: FangeulColors.darkSurface,
        onSurface: FangeulColors.darkOnSurface,
        onSurfaceVariant: FangeulColors.darkOnSurfaceVariant,
        outline: FangeulColors.darkOutline,
        outlineVariant: FangeulColors.darkOutlineVariant,
        surfaceContainerLowest: FangeulColors.darkBackground,
        surfaceContainerLow: FangeulColors.darkBackground,
        surfaceContainer: FangeulColors.darkSurfaceContainer,
        surfaceContainerHigh: FangeulColors.darkSurfaceContainerHigh,
        surfaceContainerHighest: FangeulColors.darkSurfaceContainerHigh,
      ),
      scaffoldBackgroundColor: FangeulColors.darkBackground,
      textTheme: FangeulTextStyles.textTheme,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: FangeulColors.darkSurface,
        indicatorColor: FangeulColors.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStatePropertyAll(
          FangeulTextStyles.textTheme.labelMedium,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: FangeulColors.darkBackground,
        foregroundColor: FangeulColors.darkOnSurface,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: FangeulColors.darkSurface,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: FangeulColors.darkSurfaceContainer,
        selectedColor: FangeulColors.primary,
        labelStyle: FangeulTextStyles.textTheme.labelLarge,
        showCheckmark: false,
        side: BorderSide(color: FangeulColors.darkOutlineVariant),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FangeulColors.darkSurfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FangeulColors.primary),
        ),
      ),
    );
  }

  /// 라이트 테마.
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: FangeulColors.primaryLight,
        onPrimary: Colors.white,
        primaryContainer: FangeulColors.primaryContainerLight,
        onPrimaryContainer: FangeulColors.primaryLight,
        secondary: FangeulColors.secondaryLight,
        onSecondary: Colors.white,
        tertiary: FangeulColors.tertiary,
        surface: FangeulColors.lightSurface,
        onSurface: FangeulColors.lightOnSurface,
        onSurfaceVariant: FangeulColors.lightOnSurfaceVariant,
        outline: FangeulColors.lightOutline,
        outlineVariant: FangeulColors.lightOutlineVariant,
        surfaceContainer: FangeulColors.lightSurfaceContainer,
        surfaceContainerHigh: FangeulColors.lightSurfaceContainerHigh,
      ),
      scaffoldBackgroundColor: FangeulColors.lightBackground,
      textTheme: FangeulTextStyles.textTheme,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: FangeulColors.lightSurface,
        indicatorColor: FangeulColors.primaryLight.withValues(alpha: 0.35),
        labelTextStyle: WidgetStatePropertyAll(
          FangeulTextStyles.textTheme.labelMedium,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: FangeulColors.lightBackground,
        foregroundColor: FangeulColors.lightOnSurface,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: FangeulColors.lightSurface,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: FangeulColors.lightSurfaceContainer,
        selectedColor: FangeulColors.primaryLight,
        labelStyle: FangeulTextStyles.textTheme.labelLarge,
        showCheckmark: false,
        side: BorderSide(color: FangeulColors.lightOutlineVariant),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FangeulColors.lightSurfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FangeulColors.primaryLight),
        ),
      ),
    );
  }

  /// seed color 기반 동적 다크 테마.
  ///
  /// ColorScheme.fromSeed()가 배경/surface/on* 색상 전부 자동 생성.
  /// [customTextColor] 지정 시 onSurface/onPrimary를 해당 색으로 override.
  /// 자유 피커 IAP 구매자 전용 프리미엄 차별화.
  static ThemeData dynamicDark(Color seedColor, {Color? customTextColor}) {
    var colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    if (customTextColor != null) {
      colorScheme = colorScheme.copyWith(
        onSurface: customTextColor,
        onSurfaceVariant: customTextColor.withValues(alpha: 0.7),
        onPrimary: customTextColor,
      );
    }
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: FangeulTextStyles.textTheme,
    );
  }

  /// seed color 기반 동적 라이트 테마.
  static ThemeData dynamicLight(Color seedColor, {Color? customTextColor}) {
    var colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    if (customTextColor != null) {
      colorScheme = colorScheme.copyWith(
        onSurface: customTextColor,
        onSurfaceVariant: customTextColor.withValues(alpha: 0.7),
        onPrimary: customTextColor,
      );
    }
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: FangeulTextStyles.textTheme,
    );
  }
}

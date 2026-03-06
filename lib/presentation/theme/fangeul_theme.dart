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
    return _withComponentThemes(ThemeData(
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
    ));
  }

  /// 라이트 테마.
  static ThemeData light() {
    return _withComponentThemes(ThemeData(
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
        surfaceContainerLowest: FangeulColors.lightBackground,
        surfaceContainer: FangeulColors.lightSurfaceContainer,
        surfaceContainerHigh: FangeulColors.lightSurfaceContainerHigh,
      ),
      scaffoldBackgroundColor: FangeulColors.lightBackground,
      textTheme: FangeulTextStyles.textTheme,
    ));
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
    return _withComponentThemes(ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: FangeulTextStyles.textTheme,
    ));
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
    return _withComponentThemes(ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: FangeulTextStyles.textTheme,
    ));
  }

  /// Component theme 헬퍼 — ColorScheme 토큰 기반.
  ///
  /// appBar/card/chip/navigationBar/inputDecoration 5개 component theme을
  /// [ColorScheme] 토큰으로 구성한다. 정적/동적 테마 모두 공유.
  static ThemeData _withComponentThemes(ThemeData base) {
    final cs = base.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    return base.copyWith(
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primary.withValues(alpha: isDark ? 0.15 : 0.35),
        labelTextStyle: WidgetStatePropertyAll(
          FangeulTextStyles.textTheme.labelMedium,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: base.scaffoldBackgroundColor,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cs.surface,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainer,
        selectedColor: cs.primary,
        labelStyle: FangeulTextStyles.textTheme.labelLarge,
        showCheckmark: false,
        side: BorderSide(color: cs.outlineVariant),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary),
        ),
      ),
    );
  }
}

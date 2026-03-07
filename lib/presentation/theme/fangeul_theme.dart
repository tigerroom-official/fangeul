import 'package:flutter/material.dart';

import 'package:fangeul/presentation/theme/choeae_color_config.dart';
import 'package:fangeul/presentation/theme/fangeul_text_styles.dart';

/// Fangeul ThemeData 팩토리.
///
/// 단일 진입점 [build]가 brightness + 최애색 설정으로 ThemeData를 합성한다.
/// 최애색 레이어가 ColorScheme 전체를 공급 (덧대기 아님, override).
abstract final class FangeulTheme {
  /// 앱 전체 ThemeData 생성.
  ///
  /// [brightness] — Dark/Light/System에서 결정된 값.
  /// [choeaeColor] — 최애색 설정 (팔레트팩 or 커스텀).
  static ThemeData build({
    required Brightness brightness,
    required ChoeaeColorConfig choeaeColor,
  }) {
    final colorScheme = choeaeColor.buildColorScheme(brightness);

    return _withComponentThemes(ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,
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
        indicatorColor: cs.primary.withValues(alpha: isDark ? 0.30 : 0.35),
        labelTextStyle: WidgetStatePropertyAll(
          FangeulTextStyles.textTheme.labelMedium,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surfaceContainerHigh,
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

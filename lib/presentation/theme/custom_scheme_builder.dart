import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// 유저 선택 seed color에서 [ColorScheme]을 직접 생성한다.
///
/// Material 3 [ColorScheme.fromSeed]의 HCT 알고리즘은 neutral chroma ~6으로
/// surface 채도를 극히 낮춰 테마 색상 변경 체감이 약하다. 이 빌더는
/// neutral chroma 24 (4배)로 surface에 seed hue를 강하게 반영하여
/// "내가 고른 색 = 앱 색상"을 체감시킨다.
abstract final class CustomSchemeBuilder {
  /// [seedColor] + [brightness]로 풀 [ColorScheme]을 생성한다.
  ///
  /// [textColorOverride]가 null이면 배경 luminance 기반 auto contrast를 적용한다.
  static ColorScheme build({
    required Color seedColor,
    required Brightness brightness,
    Color? textColorOverride,
  }) {
    final isDark = brightness == Brightness.dark;
    final src = Hct.fromInt(seedColor.toARGB32());

    final scheme = _SchemeVividTint(
      sourceColorHct: src,
      isDark: isDark,
    );

    final cs = _colorSchemeFromDynamic(scheme, brightness);

    if (textColorOverride == null) return cs;

    final dimmed =
        textColorOverride.withValues(alpha: textColorOverride.a * 0.78);
    return cs.copyWith(
      onSurface: textColorOverride,
      onSurfaceVariant: dimmed,
      onPrimary: textColorOverride,
      onPrimaryContainer: textColorOverride,
      onSecondary: textColorOverride,
      onSecondaryContainer: textColorOverride,
      onTertiary: textColorOverride,
      onTertiaryContainer: textColorOverride,
      onError: textColorOverride,
      onErrorContainer: dimmed,
    );
  }

  /// [DynamicScheme] convenience getters → Flutter [ColorScheme] 변환.
  static ColorScheme _colorSchemeFromDynamic(
    DynamicScheme s,
    Brightness brightness,
  ) {
    return ColorScheme(
      brightness: brightness,
      primary: Color(s.primary),
      onPrimary: Color(s.onPrimary),
      primaryContainer: Color(s.primaryContainer),
      onPrimaryContainer: Color(s.onPrimaryContainer),
      secondary: Color(s.secondary),
      onSecondary: Color(s.onSecondary),
      secondaryContainer: Color(s.secondaryContainer),
      onSecondaryContainer: Color(s.onSecondaryContainer),
      tertiary: Color(s.tertiary),
      onTertiary: Color(s.onTertiary),
      tertiaryContainer: Color(s.tertiaryContainer),
      onTertiaryContainer: Color(s.onTertiaryContainer),
      error: Color(s.error),
      onError: Color(s.onError),
      errorContainer: Color(s.errorContainer),
      onErrorContainer: Color(s.onErrorContainer),
      surface: Color(s.surface),
      onSurface: Color(s.onSurface),
      onSurfaceVariant: Color(s.onSurfaceVariant),
      surfaceDim: Color(s.surfaceDim),
      surfaceBright: Color(s.surfaceBright),
      surfaceContainerLowest: Color(s.surfaceContainerLowest),
      surfaceContainerLow: Color(s.surfaceContainerLow),
      surfaceContainer: Color(s.surfaceContainer),
      surfaceContainerHigh: Color(s.surfaceContainerHigh),
      surfaceContainerHighest: Color(s.surfaceContainerHighest),
      inverseSurface: Color(s.inverseSurface),
      onInverseSurface: Color(s.inverseOnSurface),
      inversePrimary: Color(s.inversePrimary),
      outline: Color(s.outline),
      outlineVariant: Color(s.outlineVariant),
      shadow: Color(s.shadow),
      scrim: Color(s.scrim),
      surfaceTint: Color(s.surfaceTint),
    );
  }
}

/// 높은 neutral chroma로 surface에 seed hue를 강하게 반영하는 커스텀 스킴.
///
/// M3 기본 SchemeVibrant의 neutral chroma는 10 (거의 무색).
/// 이 스킴은 neutral 24 / neutralVariant 28로 surface 색감을 4배 강화한다.
class _SchemeVividTint extends DynamicScheme {
  // ignore: use_super_parameters — sourceColorHct referenced in initializer
  _SchemeVividTint({
    required Hct sourceColorHct,
    required super.isDark,
  }) : super(
          sourceColorHct: sourceColorHct,
          variant: Variant.vibrant,
          primaryPalette:
              TonalPalette.of(sourceColorHct.hue, _maxChroma(sourceColorHct)),
          secondaryPalette:
              TonalPalette.of((sourceColorHct.hue + 30) % 360, 24.0),
          tertiaryPalette:
              TonalPalette.of((sourceColorHct.hue + 60) % 360, 32.0),
          neutralPalette: TonalPalette.of(sourceColorHct.hue, 24.0),
          neutralVariantPalette: TonalPalette.of(sourceColorHct.hue, 28.0),
        );

  /// primary chroma: seed chroma와 48 중 큰 값.
  static double _maxChroma(Hct src) => src.chroma < 48.0 ? 48.0 : src.chroma;
}

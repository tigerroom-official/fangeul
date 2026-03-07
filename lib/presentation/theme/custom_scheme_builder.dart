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
    );
  }

  /// [DynamicScheme] convenience getters → Flutter [ColorScheme] 변환.
  ///
  /// primary/secondary/tertiary/error 계열은 DynamicScheme 그대로 사용하고,
  /// surface 계열 8개 슬롯 + surfaceDim/surfaceBright는 seed hue 기반
  /// [Hct.from]으로 직접 생성하여 tone을 M3 기본값보다 올린다.
  static ColorScheme _colorSchemeFromDynamic(
    DynamicScheme s,
    Brightness brightness,
  ) {
    final hue = s.sourceColorHct.hue;
    final isDark = brightness == Brightness.dark;
    final surfaces = _buildTintedSurfaces(hue, isDark);

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
      surface: surfaces.surface,
      onSurface: Color(s.onSurface),
      onSurfaceVariant: Color(s.onSurfaceVariant),
      surfaceDim: surfaces.surfaceDim,
      surfaceBright: surfaces.surfaceBright,
      surfaceContainerLowest: surfaces.surfaceContainerLowest,
      surfaceContainerLow: surfaces.surfaceContainerLow,
      surfaceContainer: surfaces.surfaceContainer,
      surfaceContainerHigh: surfaces.surfaceContainerHigh,
      surfaceContainerHighest: surfaces.surfaceContainerHighest,
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

  /// seed [hue] + [isDark] 기반으로 surface 계열 8색을 직접 생성한다.
  ///
  /// M3 기본 tone 대비 dark는 +4~8, light는 -2~-8 시프트하여
  /// 테마 색상 체감을 강화한다. chroma도 슬롯별로 차등 적용.
  static _TintedSurfaces _buildTintedSurfaces(double hue, bool isDark) {
    if (isDark) {
      return _TintedSurfaces(
        surfaceContainerLowest: _hctColor(hue, 16, 8),
        surfaceDim: _hctColor(hue, 18, 10),
        surface: _hctColor(hue, 20, 14),
        surfaceContainerLow: _hctColor(hue, 18, 16),
        surfaceContainer: _hctColor(hue, 22, 20),
        surfaceContainerHigh: _hctColor(hue, 24, 25),
        surfaceContainerHighest: _hctColor(hue, 26, 30),
        surfaceBright: _hctColor(hue, 24, 32),
      );
    }
    return _TintedSurfaces(
      surfaceContainerLowest: _hctColor(hue, 4, 99),
      surfaceBright: _hctColor(hue, 6, 98),
      surface: _hctColor(hue, 8, 96),
      surfaceContainerLow: _hctColor(hue, 10, 93),
      surfaceDim: _hctColor(hue, 14, 87),
      surfaceContainer: _hctColor(hue, 14, 90),
      surfaceContainerHigh: _hctColor(hue, 18, 86),
      surfaceContainerHighest: _hctColor(hue, 22, 82),
    );
  }

  /// HCT 색상 공간에서 직접 [Color]를 생성하는 헬퍼.
  static Color _hctColor(double h, double c, double t) =>
      Color(Hct.from(h, c, t).toInt());
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

/// surface 계열 8색을 묶어 전달하는 내부 DTO.
class _TintedSurfaces {
  _TintedSurfaces({
    required this.surface,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
  });

  final Color surface;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
}

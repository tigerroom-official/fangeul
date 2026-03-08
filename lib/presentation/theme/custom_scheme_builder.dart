import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// 유저 선택 seed color에서 [ColorScheme]을 직접 생성한다.
///
/// Material 3 [ColorScheme.fromSeed]의 HCT 알고리즘은 neutral chroma ~6으로
/// surface 채도를 극히 낮춰 테마 색상 변경 체감이 약하다. 이 빌더는
/// seed color의 HCT tone을 기준으로 surface를 직접 앵커링하여
/// "내가 고른 색 = 앱 배경색"을 체감시킨다.
///
/// brightness는 seed의 tone에서 자동 유도된다 (tone < 50 → dark).
/// 시스템 다크/라이트 모드와 완전히 독립적이다.
abstract final class CustomSchemeBuilder {
  /// [seedColor]로 풀 [ColorScheme]을 생성한다.
  ///
  /// brightness는 seed의 HCT tone에서 자동 유도된다.
  /// [textColorOverride]가 null이면 배경 luminance 기반 auto contrast를 적용한다.
  static ColorScheme build({
    required Color seedColor,
    Color? textColorOverride,
  }) {
    final src = Hct.fromInt(seedColor.toARGB32());
    final isDark = src.tone < 50;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    final scheme = _SchemeVividTint(
      sourceColorHct: src,
      isDark: isDark,
    );

    final cs = _colorSchemeFromDynamic(scheme, brightness, src);

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
  /// surface 계열은 seed의 HCT 좌표(hue, chroma, tone)를 기준으로
  /// 직접 앵커링하여 "내가 고른 색 = 앱 배경색"을 실현한다.
  static ColorScheme _colorSchemeFromDynamic(
    DynamicScheme s,
    Brightness brightness,
    Hct seed,
  ) {
    final surfaces = _buildSeedAnchoredSurfaces(
      seed.hue,
      seed.chroma,
      seed.tone,
    );

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

  /// seed HCT 좌표 기반으로 surface 계열 8색을 생성한다.
  ///
  /// surface의 tone을 seed의 tone에 앵커링하여 "내가 고른 색이 곧 배경색"을
  /// 실현한다. scaffold = surface(seed tone), AppBar = surfaceContainerLow(+2),
  /// card = surfaceContainer(+5). 전체 tone spread ≈17.
  ///
  /// chroma는 seed chroma의 85%를 균일 적용. 컨테이너 간 채도 차이 없이
  /// tone 차이만으로 계층 분리. 카드 경계는 outlineVariant로 구분.
  ///
  /// 오프셋 설계 근거: 2026-03-08 UX 패널 합의.
  /// `docs/discussions/2026-03-08-theme-surface-hierarchy-slots.md` 참조.
  static _TintedSurfaces _buildSeedAnchoredSurfaces(
    double hue,
    double seedChroma,
    double seedTone,
  ) {
    final isDark = seedTone < 50;
    // 채도: seed chroma의 85% 유지 → "내가 고른 색 = 앱 색" 체감.
    // 극저채도 seed(회색/흰/검정)는 최소 8 보장.
    final raw = seedChroma * 0.85;
    final sc = raw < 8.0 ? 8.0 : raw;

    if (isDark) {
      // 어두운 seed: 컨테이너가 점점 밝아지는 계층 (spread 17)
      return _TintedSurfaces(
        surfaceContainerLowest:
            _hctColor(hue, sc, (seedTone - 4).clamp(4, 90)),
        surfaceDim: _hctColor(hue, sc, (seedTone - 2).clamp(4, 90)),
        surface: _hctColor(hue, sc, seedTone),
        surfaceContainerLow: _hctColor(hue, sc, (seedTone + 2).clamp(4, 90)),
        surfaceContainer: _hctColor(hue, sc, (seedTone + 5).clamp(4, 90)),
        surfaceContainerHigh:
            _hctColor(hue, sc, (seedTone + 8).clamp(4, 90)),
        surfaceContainerHighest:
            _hctColor(hue, sc, (seedTone + 11).clamp(4, 90)),
        surfaceBright: _hctColor(hue, sc, (seedTone + 13).clamp(4, 90)),
      );
    }
    // 밝은 seed: 컨테이너가 점점 어두워지는 계층 (spread 17)
    return _TintedSurfaces(
      surfaceContainerLowest:
          _hctColor(hue, sc, (seedTone + 3).clamp(10, 99)),
      surfaceBright: _hctColor(hue, sc, (seedTone + 2).clamp(10, 99)),
      surface: _hctColor(hue, sc, seedTone),
      surfaceContainerLow: _hctColor(hue, sc, (seedTone - 2).clamp(10, 99)),
      surfaceDim: _hctColor(hue, sc, (seedTone - 7).clamp(10, 99)),
      surfaceContainer: _hctColor(hue, sc, (seedTone - 5).clamp(10, 99)),
      surfaceContainerHigh:
          _hctColor(hue, sc, (seedTone - 8).clamp(10, 99)),
      surfaceContainerHighest:
          _hctColor(hue, sc, (seedTone - 11).clamp(10, 99)),
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

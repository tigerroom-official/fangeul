import 'package:flutter/material.dart';

/// 유저 선택 seed color에서 [ColorScheme]을 직접 생성한다.
///
/// Material 3 [ColorScheme.fromSeed]의 HCT 알고리즘은 surface 채도를 ~5%로
/// 저감하여 테마 색상 변경 체감이 약하다. 이 빌더는 seed hue를 surface 전체에
/// 15~30% 채도로 반영하여 앱 전체가 선택 색상에 "젖는" 효과를 만든다.
abstract final class CustomSchemeBuilder {
  /// [seedColor] + [brightness]로 풀 [ColorScheme]을 생성한다.
  ///
  /// [textColorOverride]가 null이면 배경 luminance 기반 auto contrast를 적용한다.
  static ColorScheme build({
    required Color seedColor,
    required Brightness brightness,
    Color? textColorOverride,
  }) {
    final hsl = HSLColor.fromColor(seedColor);
    return brightness == Brightness.dark
        ? _buildDark(hsl, textColorOverride)
        : _buildLight(hsl, textColorOverride);
  }

  static ColorScheme _buildDark(HSLColor hsl, Color? textOverride) {
    final primary =
        hsl.withLightness(hsl.lightness.clamp(0.55, 0.70)).toColor();
    final onPrimary = textOverride ?? _autoContrast(primary);
    final surface = hsl
        .withLightness(0.10)
        .withSaturation((hsl.saturation * 0.25).clamp(0.0, 1.0))
        .toColor();

    return ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: hsl
          .withLightness(0.25)
          .withSaturation((hsl.saturation * 0.70).clamp(0.0, 1.0))
          .toColor(),
      onPrimaryContainer: textOverride ?? Colors.white,
      secondary: hsl
          .withHue((hsl.hue + 30) % 360)
          .withLightness(0.60)
          .withSaturation((hsl.saturation * 0.60).clamp(0.0, 1.0))
          .toColor(),
      onSecondary: textOverride ?? Colors.white,
      secondaryContainer: hsl
          .withHue((hsl.hue + 30) % 360)
          .withLightness(0.20)
          .withSaturation((hsl.saturation * 0.50).clamp(0.0, 1.0))
          .toColor(),
      onSecondaryContainer: textOverride ?? Colors.white,
      tertiary: hsl
          .withHue((hsl.hue + 60) % 360)
          .withLightness(0.60)
          .withSaturation((hsl.saturation * 0.50).clamp(0.0, 1.0))
          .toColor(),
      onTertiary: textOverride ?? Colors.white,
      error: const Color(0xFFCF6679),
      onError: Colors.black,
      surface: surface,
      onSurface: textOverride ?? Colors.white,
      onSurfaceVariant: textOverride != null
          ? Color.fromARGB(
              (textOverride.a * 0.78).round(),
              textOverride.r.round(),
              textOverride.g.round(),
              textOverride.b.round(),
            )
          : const Color(0xC8FFFFFF),
      surfaceContainerLowest: hsl
          .withLightness(0.06)
          .withSaturation((hsl.saturation * 0.15).clamp(0.0, 1.0))
          .toColor(),
      surfaceContainerLow: hsl
          .withLightness(0.12)
          .withSaturation((hsl.saturation * 0.20).clamp(0.0, 1.0))
          .toColor(),
      surfaceContainer: hsl
          .withLightness(0.15)
          .withSaturation((hsl.saturation * 0.22).clamp(0.0, 1.0))
          .toColor(),
      surfaceContainerHigh: hsl
          .withLightness(0.18)
          .withSaturation((hsl.saturation * 0.25).clamp(0.0, 1.0))
          .toColor(),
      surfaceContainerHighest: hsl
          .withLightness(0.22)
          .withSaturation((hsl.saturation * 0.28).clamp(0.0, 1.0))
          .toColor(),
      outline: hsl
          .withLightness(0.40)
          .withSaturation((hsl.saturation * 0.30).clamp(0.0, 1.0))
          .toColor(),
      outlineVariant: hsl
          .withLightness(0.25)
          .withSaturation((hsl.saturation * 0.20).clamp(0.0, 1.0))
          .toColor(),
    );
  }

  static ColorScheme _buildLight(HSLColor hsl, Color? textOverride) {
    final primary =
        hsl.withLightness(hsl.lightness.clamp(0.30, 0.45)).toColor();
    final surface = hsl
        .withLightness(0.96)
        .withSaturation((hsl.saturation * 0.12).clamp(0.0, 1.0))
        .toColor();

    return ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: textOverride ?? Colors.white,
      primaryContainer: hsl
          .withLightness(0.85)
          .withSaturation((hsl.saturation * 0.50).clamp(0.0, 1.0))
          .toColor(),
      onPrimaryContainer: textOverride ?? hsl.withLightness(0.15).toColor(),
      secondary: hsl
          .withHue((hsl.hue + 30) % 360)
          .withLightness(0.40)
          .withSaturation((hsl.saturation * 0.50).clamp(0.0, 1.0))
          .toColor(),
      onSecondary: textOverride ?? Colors.white,
      secondaryContainer: hsl
          .withHue((hsl.hue + 30) % 360)
          .withLightness(0.90)
          .withSaturation((hsl.saturation * 0.40).clamp(0.0, 1.0))
          .toColor(),
      onSecondaryContainer: textOverride ?? hsl.withLightness(0.15).toColor(),
      tertiary: hsl
          .withHue((hsl.hue + 60) % 360)
          .withLightness(0.40)
          .withSaturation((hsl.saturation * 0.40).clamp(0.0, 1.0))
          .toColor(),
      onTertiary: textOverride ?? Colors.white,
      error: const Color(0xFFB00020),
      onError: Colors.white,
      surface: surface,
      onSurface: textOverride ?? Colors.black87,
      onSurfaceVariant: textOverride != null
          ? Color.fromARGB(
              (textOverride.a * 0.78).round(),
              textOverride.r.round(),
              textOverride.g.round(),
              textOverride.b.round(),
            )
          : const Color(0xFF424242),
      surfaceContainerLowest: hsl
          .withLightness(0.99)
          .withSaturation((hsl.saturation * 0.05).clamp(0.0, 1.0))
          .toColor(),
      surfaceContainerLow: hsl
          .withLightness(0.95)
          .withSaturation((hsl.saturation * 0.10).clamp(0.0, 1.0))
          .toColor(),
      surfaceContainer: hsl
          .withLightness(0.93)
          .withSaturation((hsl.saturation * 0.12).clamp(0.0, 1.0))
          .toColor(),
      surfaceContainerHigh: hsl
          .withLightness(0.90)
          .withSaturation((hsl.saturation * 0.15).clamp(0.0, 1.0))
          .toColor(),
      surfaceContainerHighest: hsl
          .withLightness(0.87)
          .withSaturation((hsl.saturation * 0.18).clamp(0.0, 1.0))
          .toColor(),
      outline: hsl
          .withLightness(0.50)
          .withSaturation((hsl.saturation * 0.25).clamp(0.0, 1.0))
          .toColor(),
      outlineVariant: hsl
          .withLightness(0.80)
          .withSaturation((hsl.saturation * 0.15).clamp(0.0, 1.0))
          .toColor(),
    );
  }

  /// 배경색 luminance 기반 흑/백 자동 선택.
  static Color _autoContrast(Color background) {
    return background.computeLuminance() > 0.179
        ? Colors.black87
        : Colors.white;
  }
}

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:fangeul/presentation/theme/custom_scheme_builder.dart';
import 'package:fangeul/presentation/theme/palette_registry.dart';

part 'choeae_color_config.freezed.dart';

/// 최애색 설정 — 팔레트팩 선택 or 유저 커스텀.
///
/// [buildColorScheme]으로 brightness에 맞는 [ColorScheme]을 생성한다.
/// JSON 직렬화 불필요 — SharedPreferences 직렬화는 Notifier가 담당.
@freezed
sealed class ChoeaeColorConfig with _$ChoeaeColorConfig {
  /// 미리 정의된 팔레트팩.
  const factory ChoeaeColorConfig.palette(String packId) = ChoeaeColorPalette;

  /// 유저 커스텀 (IAP). [textColorOverride]가 null이면 auto contrast.
  ///
  /// [brightnessOverride]는 시스템 brightness를 무시하고 고정 brightness를 사용한다.
  /// 기본값 [Brightness.dark].
  const factory ChoeaeColorConfig.custom({
    required Color seedColor,
    Color? textColorOverride,
    @Default(Brightness.dark) Brightness brightnessOverride,
  }) = ChoeaeColorCustom;

  const ChoeaeColorConfig._();

  /// [brightness]에 따라 최종 [ColorScheme]을 생성한다.
  ///
  /// palette → [PaletteRegistry]에서 수동 디자인 scheme 반환.
  /// custom → [CustomSchemeBuilder]로 seed 기반 tinted scheme 생성.
  ///
  /// **주의:** custom 타입에서는 [brightness] 파라미터가 무시되고
  /// [ChoeaeColorCustom.brightnessOverride]가 사용된다.
  /// palette 타입에서만 [brightness]가 반영된다.
  ColorScheme buildColorScheme(Brightness brightness) {
    return switch (this) {
      ChoeaeColorPalette(:final packId) =>
        PaletteRegistry.get(packId).schemeFor(brightness),
      ChoeaeColorCustom(
        :final seedColor,
        :final textColorOverride,
        :final brightnessOverride,
      ) =>
        CustomSchemeBuilder.build(
          seedColor: seedColor,
          brightness: brightnessOverride,
          textColorOverride: textColorOverride,
        ),
    };
  }
}

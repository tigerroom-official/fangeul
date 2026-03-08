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
  /// brightness는 [seedColor]의 HCT tone에서 자동 유도된다 (tone < 50 → dark).
  /// 시스템 다크/라이트 모드와 완전히 독립적이다.
  ///
  /// [brightnessOverride]는 레거시 호환용으로 유지하되, scheme 생성 시 무시된다.
  const factory ChoeaeColorConfig.custom({
    required Color seedColor,
    Color? textColorOverride,
    @Default(Brightness.dark) Brightness brightnessOverride,
  }) = ChoeaeColorCustom;

  const ChoeaeColorConfig._();

  /// [brightness]에 따라 최종 [ColorScheme]을 생성한다.
  ///
  /// palette → [PaletteRegistry]에서 수동 디자인 scheme 반환.
  /// custom → [CustomSchemeBuilder]로 seed 기반 scheme 생성.
  ///
  /// **주의:** custom 타입에서는 [brightness] 파라미터가 무시된다.
  /// seed color의 HCT tone이 brightness를 자동 결정한다.
  ColorScheme buildColorScheme(Brightness brightness) {
    return switch (this) {
      ChoeaeColorPalette(:final packId) =>
        PaletteRegistry.get(packId).schemeFor(brightness),
      ChoeaeColorCustom(
        :final seedColor,
        :final textColorOverride,
      ) =>
        CustomSchemeBuilder.build(
          seedColor: seedColor,
          textColorOverride: textColorOverride,
        ),
    };
  }
}

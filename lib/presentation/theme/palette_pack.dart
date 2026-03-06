import 'package:flutter/material.dart';

/// 미리 디자인된 팔레트팩.
///
/// [ColorScheme.fromSeed] 미사용 — 모든 색상 수동 지정.
/// 각 팔레트의 surface 계열은 primary 색조를 반영하여
/// 앱 전체에 색상이 "스며드는" 효과를 낸다.
class PalettePack {
  /// 팔레트팩을 생성한다.
  const PalettePack({
    required this.id,
    required this.nameKey,
    required this.lightScheme,
    required this.darkScheme,
    required this.isPremium,
    required this.previewColor,
  });

  /// 고유 식별자 (e.g., 'purple_dream').
  final String id;

  /// l10n 키 (e.g., 'palettePurpleDream').
  final String nameKey;

  /// 라이트 모드 [ColorScheme].
  final ColorScheme lightScheme;

  /// 다크 모드 [ColorScheme].
  final ColorScheme darkScheme;

  /// 프리미엄 여부 (IAP 또는 보상형 해금 필요).
  final bool isPremium;

  /// 그리드 미리보기용 대표 색상.
  final Color previewColor;

  /// [brightness]에 따라 적절한 scheme 반환.
  ColorScheme schemeFor(Brightness brightness) =>
      brightness == Brightness.dark ? darkScheme : lightScheme;
}

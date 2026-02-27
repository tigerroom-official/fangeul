import 'package:flutter/material.dart';

/// Fangeul 텍스트 스타일 토큰.
///
/// NotoSansKR 번들 폰트 기반. 오프라인 우선.
/// [koreanDisplay] / [koreanSubtitle]은 데일리 카드·공유 카드 전용.
abstract final class FangeulTextStyles {
  static const _fontFamily = 'NotoSansKR';

  /// Material 3 TextTheme — 모든 텍스트 역할에 NotoSansKR 적용.
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 32,
    ),
    displayMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 28,
    ),
    displaySmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 24,
    ),
    headlineLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 22,
    ),
    headlineMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
    headlineSmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 18,
    ),
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 18,
    ),
    titleMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 16,
    ),
    titleSmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    ),
    bodySmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 12,
    ),
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    labelMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 12,
    ),
    labelSmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 10,
    ),
  );

  /// 한글 대형 디스플레이 — 데일리 카드, 공유 카드 중앙 텍스트.
  static const koreanDisplay = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 40,
    height: 1.3,
  );

  /// 한글 서브타이틀 — 발음, 번역 표시.
  static const koreanSubtitle = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
  );
}

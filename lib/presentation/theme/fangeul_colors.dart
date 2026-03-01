import 'package:flutter/material.dart';

/// Fangeul 컬러 토큰.
///
/// 다크/라이트 모드별 surface, 공유 액센트, 팬덤 컬러를 정의한다.
/// 모든 컬러는 패널 토론 결정사항 기반 (docs/discussions/2026-02-27-visual-identity.md).
abstract final class FangeulColors {
  // ── 다크 모드 ──

  /// 가장 깊은 배경 (Scaffold)
  static const darkBackground = Color(0xFF0F0F1A);

  /// 카드, 시트 배경 (딥 네이비)
  static const darkSurface = Color(0xFF1E1E2E);

  /// 컨테이너 배경
  static const darkSurfaceContainer = Color(0xFF282840);

  /// 높은 엘리베이션 컨테이너
  static const darkSurfaceContainerHigh = Color(0xFF323250);

  /// 주 텍스트 (할로 효과 방지, WCAG AA)
  static const darkOnSurface = Color(0xFFE8E8F0);

  /// 보조 텍스트
  static const darkOnSurfaceVariant = Color(0xFFA0A0B8);

  /// 경계선
  static const darkOutline = Color(0xFF4A4A60);

  /// 약한 경계선
  static const darkOutlineVariant = Color(0xFF353550);

  // ── 라이트 모드 ──

  /// 가장 밝은 배경 (Scaffold)
  static const lightBackground = Color(0xFFFAFAFE);

  /// 카드, 시트 배경
  static const lightSurface = Color(0xFFFFFFFF);

  /// 컨테이너 배경
  static const lightSurfaceContainer = Color(0xFFF0F0F8);

  /// 높은 엘리베이션 컨테이너
  static const lightSurfaceContainerHigh = Color(0xFFE8E8F0);

  /// 주 텍스트
  static const lightOnSurface = Color(0xFF1E1E2E);

  /// 보조 텍스트
  static const lightOnSurfaceVariant = Color(0xFF5A5A70);

  /// 경계선
  static const lightOutline = Color(0xFFB0B0C0);

  /// 약한 경계선
  static const lightOutlineVariant = Color(0xFFD8D8E4);

  // ── 액센트 (팬덤 독립) ──

  /// 틸 — 다크 모드 프라이머리. 밝은 배경에서는 [primaryLight] 사용.
  static const primary = Color(0xFF4ECDC4);

  /// 틸 — 라이트 모드 프라이머리. 흰 배경 WCAG AA 충족 (대비 5.5:1).
  static const primaryLight = Color(0xFF0F766E);

  /// 틸 다크 컨테이너 (다크 모드)
  static const primaryContainerDark = Color(0xFF1A3A38);

  /// 틸 라이트 컨테이너 (라이트 모드)
  static const primaryContainerLight = Color(0xFFD4F5F2);

  /// 웜 옐로 — 다크 모드 CTA/강조. 밝은 배경에서는 [secondaryLight] 사용.
  static const secondary = Color(0xFFFFE66D);

  /// 앰버 — 라이트 모드 CTA/강조. 흰 배경 WCAG AA 충족 (대비 5.0:1).
  static const secondaryLight = Color(0xFFB45309);

  /// 코랄 — 경고, 하트
  static const tertiary = Color(0xFFFF6B6B);

  // ── 팬덤 컬러 (공유 카드 테마, v1.1) ──

  /// 팬덤 퍼플
  static const fandomPurple = Color(0xFFA855F7);

  /// 팬덤 핑크
  static const fandomPink = Color(0xFFEC4899);

  /// 팬덤 그린
  static const fandomGreen = Color(0xFF22C55E);

  /// 팬덤 블루
  static const fandomBlue = Color(0xFF3B82F6);

  /// 팬덤 오렌지
  static const fandomOrange = Color(0xFFF97316);

  /// 팬덤 실버
  static const fandomSilver = Color(0xFF94A3B8);
}

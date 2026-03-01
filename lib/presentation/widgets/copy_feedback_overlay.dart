import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 복사 성공 피드백 — confetti burst + 진동.
///
/// [trigger]를 호출하면:
/// 1. `HapticFeedback.mediumImpact()` 진동
/// 2. 접근성 애니메이션 비활성이 아닌 경우 confetti burst 표시
///
/// 저사양 SEA 디바이스를 고려하여 Canvas 기반 `confetti` 패키지 사용.
/// 빠른 연속 탭 시 중복 오버레이 방지 (쓰로틀링).
class CopyFeedback {
  CopyFeedback._();

  /// 중복 방지 — 진행 중인 confetti가 있으면 새로 생성하지 않는다.
  static bool _active = false;

  /// 복사 피드백을 실행한다.
  static void trigger(BuildContext context) {
    HapticFeedback.mediumImpact();

    final disableAnimations = MediaQuery.of(context).disableAnimations;
    if (disableAnimations) return;

    _showConfettiBurst(context);
  }

  static void _showConfettiBurst(BuildContext context) {
    if (_active) return;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    _active = true;
    final controller = ConfettiController(
      duration: const Duration(milliseconds: 300),
    );

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Align(
        alignment: Alignment.center,
        child: ConfettiWidget(
          confettiController: controller,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 12,
          maxBlastForce: 15,
          minBlastForce: 5,
          emissionFrequency: 1.0,
          gravity: 0.3,
          minimumSize: const Size(5, 3),
          maximumSize: const Size(10, 5),
          colors: _confettiColors,
        ),
      ),
    );

    overlay.insert(entry);
    controller.play();

    // 파티클 낙하 완료 후 자동 정리 — mounted 가드로 해제된 오버레이 크래시 방지.
    Timer(const Duration(milliseconds: 1500), () {
      if (entry.mounted) {
        entry.remove();
        entry.dispose();
      }
      controller.dispose();
      _active = false;
    });
  }

  /// 축하 confetti 색상 팔레트 — 밝고 경쾌한 파스텔 톤.
  static const _confettiColors = [
    Color(0xFFFF6B9D), // 핑크
    Color(0xFFFFA07A), // 살몬
    Color(0xFFFFD700), // 골드
    Color(0xFF87CEEB), // 스카이블루
    Color(0xFFDDA0DD), // 플럼
    Color(0xFF98FB98), // 민트
  ];
}

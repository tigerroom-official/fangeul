import 'package:flutter/services.dart';

import 'package:fangeul/platform/bubble_state.dart';

/// 플로팅 버블 Platform Channel 래퍼.
///
/// Kotlin FloatingBubbleService와 MethodChannel로 통신한다.
/// 모든 메서드는 PlatformException을 안전하게 처리한다.
class FloatingBubbleChannel {
  static const _channel = MethodChannel(
    'com.tigerroom.fangeul/floating_bubble',
  );

  /// 버블을 화면에 표시한다.
  ///
  /// 오버레이 권한이 없으면 `false` 반환.
  Future<bool> showBubble() async {
    try {
      final result = await _channel.invokeMethod<bool>('showBubble');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// 버블을 화면에서 숨기고 서비스를 중지한다.
  Future<bool> hideBubble() async {
    try {
      final result = await _channel.invokeMethod<bool>('hideBubble');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// 오버레이 권한 부여 여부를 확인한다.
  Future<bool> isOverlayPermissionGranted() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isOverlayPermissionGranted',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// 시스템 오버레이 권한 설정 화면을 연다.
  Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod<void>('requestOverlayPermission');
    } on PlatformException {
      // 무시 — 설정 화면 열기 실패 시 사용자에게 수동 안내
    }
  }

  /// 현재 버블 상태를 조회한다.
  Future<BubbleState> getBubbleState() async {
    try {
      final result = await _channel.invokeMethod<String>('getBubbleState');
      return BubbleState.fromString(result ?? 'off');
    } on PlatformException {
      return BubbleState.off;
    }
  }
}

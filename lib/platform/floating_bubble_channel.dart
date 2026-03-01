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
  static const _eventChannel = EventChannel(
    'com.tigerroom.fangeul/floating_bubble_events',
  );

  /// 버블 상태 변경 스트림.
  ///
  /// Kotlin [FloatingBubbleService]에서 상태 변경 시 이벤트를 수신한다.
  Stream<BubbleState> get stateStream => _eventChannel
      .receiveBroadcastStream()
      .map((event) => BubbleState.fromString(event as String? ?? 'off'));

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
  ///
  /// 사용자가 설정 화면에서 돌아오면 권한 부여 여부를 반환한다.
  Future<bool> requestOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'requestOverlayPermission',
      );
      return result ?? false;
    } on PlatformException {
      return false;
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

  /// 배터리 최적화가 해제되어 있는지 확인한다.
  ///
  /// `true` — 배터리 최적화 제외 상태 (버블 서비스 안정).
  /// `false` — 최적화 적용 중 (OEM 프로세스 킬 위험).
  Future<bool> isBatteryOptimizationDisabled() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isBatteryOptimizationDisabled',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// 배터리 최적화 해제를 시스템에 요청한다.
  ///
  /// `ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` Intent를 실행하여
  /// 사용자에게 배터리 최적화 해제 동의 다이얼로그를 표시한다.
  Future<bool> requestIgnoreBatteryOptimization() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'requestIgnoreBatteryOptimization',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}

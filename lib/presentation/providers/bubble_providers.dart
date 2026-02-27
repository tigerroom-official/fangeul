import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/platform/bubble_state.dart';
import 'package:fangeul/platform/floating_bubble_channel.dart';

part 'bubble_providers.g.dart';

/// FloatingBubbleChannel Provider.
@riverpod
FloatingBubbleChannel floatingBubbleChannel(FloatingBubbleChannelRef ref) {
  return FloatingBubbleChannel();
}

/// 버블 상태 Notifier.
///
/// [FloatingBubbleChannel]을 통해 네이티브 버블 서비스를 제어하고
/// 현재 상태를 [BubbleState]로 관리한다.
@riverpod
class BubbleNotifier extends _$BubbleNotifier {
  @override
  BubbleState build() => BubbleState.off;

  FloatingBubbleChannel get _channel => ref.read(floatingBubbleChannelProvider);

  /// 버블을 표시한다.
  ///
  /// 오버레이 권한이 없으면 상태 변경 없이 반환.
  Future<void> show() async {
    final success = await _channel.showBubble();
    if (success) {
      state = BubbleState.showing;
    }
  }

  /// 버블을 숨기고 서비스를 중지한다.
  Future<void> hide() async {
    await _channel.hideBubble();
    state = BubbleState.off;
  }

  /// 오버레이 권한 부여 여부를 확인한다.
  Future<bool> checkPermission() {
    return _channel.isOverlayPermissionGranted();
  }

  /// 시스템 오버레이 권한 설정을 요청한다.
  Future<void> requestPermission() {
    return _channel.requestOverlayPermission();
  }

  /// 네이티브에서 상태를 동기화한다.
  Future<void> sync() async {
    state = await _channel.getBubbleState();
  }
}

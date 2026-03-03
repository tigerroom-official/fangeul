import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_state_provider.g.dart';

/// 세션 동안 배너 광고 숨김 여부.
///
/// 보상형 광고 1회 시청 시 true로 전환. 앱 프로세스 종료 시 리셋.
/// keepAlive: 위젯 unmount 후에도 세션 동안 상태 유지.
@Riverpod(keepAlive: true)
class SessionBannerHidden extends _$SessionBannerHidden {
  @override
  bool build() => false;

  /// 보상형 시청 후 세션 배너 숨김.
  void hide() => state = true;
}

/// 전환 트리거 팝업 이번 세션에서 표시 여부.
///
/// 세션 당 1회만 표시. keepAlive: 위젯 unmount 후에도 유지.
@Riverpod(keepAlive: true)
class SessionConversionShown extends _$SessionConversionShown {
  @override
  bool build() => false;

  /// 팝업 표시 후 설정.
  void markShown() => state = true;
}

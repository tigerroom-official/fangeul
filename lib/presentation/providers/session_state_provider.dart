import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_state_provider.g.dart';

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

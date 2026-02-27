import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'keyboard_providers.freezed.dart';
part 'keyboard_providers.g.dart';

/// CAPS 키 모드.
///
/// 쌍자음 입력 시 Shift 동작을 제어한다.
enum CapsMode {
  /// 비활성.
  off,

  /// 원샷 — 다음 1글자만 쌍자음, 이후 자동 해제.
  oneShot,

  /// 잠금 — 다시 누를 때까지 유지.
  locked,
}

/// 키보드 상태.
///
/// CAPS 모드를 포함하며, 향후 키보드 관련 상태를 확장할 수 있다.
/// 동기 토글 상태이므로 sealed class (initial/loading/success/error)
/// 패턴 대신 단순 freezed data class를 사용한다.
@freezed
class KeyboardState with _$KeyboardState {
  /// Creates a [KeyboardState].
  const factory KeyboardState({
    @Default(CapsMode.off) CapsMode capsMode,
  }) = _KeyboardState;

  const KeyboardState._();

  /// CAPS가 활성 상태(oneShot 또는 locked)인지 여부.
  bool get isShifted => capsMode != CapsMode.off;
}

/// 키보드 상태 관리 Notifier.
///
/// CAPS 토글과 원샷 소비를 담당한다.
/// [KoreanKeyboard] 위젯과 변환기 화면에서 사용한다.
@riverpod
class KeyboardNotifier extends _$KeyboardNotifier {
  @override
  KeyboardState build() => const KeyboardState();

  /// CAPS 토글: off → oneShot → locked → off.
  void toggleCaps() {
    state = state.copyWith(
      capsMode: switch (state.capsMode) {
        CapsMode.off => CapsMode.oneShot,
        CapsMode.oneShot => CapsMode.locked,
        CapsMode.locked => CapsMode.off,
      },
    );
  }

  /// 원샷 모드 소비. locked 모드에서는 무시.
  ///
  /// 키 입력 후 호출하여 oneShot 상태를 자동 해제한다.
  void consumeOneShot() {
    if (state.capsMode == CapsMode.oneShot) {
      state = state.copyWith(capsMode: CapsMode.off);
    }
  }
}

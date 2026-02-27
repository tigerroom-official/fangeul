/// 플로팅 버블 상태.
///
/// Kotlin FloatingBubbleService의 상태를 Dart에서 표현한다.
enum BubbleState {
  /// 버블 비활성
  off,

  /// 버블 화면에 표시 중
  showing,

  /// 팝업(MiniConverter) 열려있음
  popup;

  /// 문자열에서 [BubbleState]로 변환.
  ///
  /// Kotlin MethodChannel에서 전달되는 문자열을 파싱한다.
  /// 알 수 없는 값은 [BubbleState.off]로 기본 처리.
  static BubbleState fromString(String value) {
    return BubbleState.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BubbleState.off,
    );
  }
}

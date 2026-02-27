/// 한글 음절의 초성/중성/종성을 나타내는 불변 데이터 클래스.
///
/// 유니코드 한글 블록의 자모 분해 결과를 담는다.
/// [initial]은 초성(ㄱ~ㅎ), [medial]은 중성(ㅏ~ㅣ),
/// [final_]은 종성(빈 문자열이면 종성 없음)이다.
class Jamo {
  /// Creates a [Jamo] with the given initial, medial, and final consonant.
  const Jamo({
    required this.initial,
    required this.medial,
    required this.final_,
  });

  /// 초성 (ㄱ~ㅎ)
  final String initial;

  /// 중성 (ㅏ~ㅣ)
  final String medial;

  /// 종성 (빈 문자열이면 종성 없음)
  final String final_;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Jamo &&
        other.initial == initial &&
        other.medial == medial &&
        other.final_ == final_;
  }

  @override
  int get hashCode => Object.hash(initial, medial, final_);

  @override
  String toString() => 'Jamo($initial, $medial, $final_)';
}

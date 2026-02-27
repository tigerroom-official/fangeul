import 'package:fangeul/core/engines/jamo.dart';

/// 한글 유니코드 자모 분해/조합 엔진.
///
/// Unicode Hangul Syllables 블록 (U+AC00~U+D7A3) 기반으로
/// 초성/중성/종성을 분해하고 조합한다.
/// 순수 Dart로 구현되며 Flutter 의존성이 없다.
class HangulEngine {
  HangulEngine._();

  /// 한글 음절 시작 코드포인트 (가 = 0xAC00)
  static const int _syllableBase = 0xAC00;

  /// 한글 음절 끝 코드포인트 (힣 = 0xD7A3)
  static const int _syllableEnd = 0xD7A3;

  /// 중성 개수
  static const int _medialCount = 21;

  /// 종성 개수 (종성 없음 포함)
  static const int _finalCount = 28;

  /// 초성 목록 (19개)
  static const List<String> initials = [
    'ㄱ',
    'ㄲ',
    'ㄴ',
    'ㄷ',
    'ㄸ',
    'ㄹ',
    'ㅁ',
    'ㅂ',
    'ㅃ',
    'ㅅ',
    'ㅆ',
    'ㅇ',
    'ㅈ',
    'ㅉ',
    'ㅊ',
    'ㅋ',
    'ㅌ',
    'ㅍ',
    'ㅎ',
  ];

  /// 중성 목록 (21개)
  static const List<String> medials = [
    'ㅏ',
    'ㅐ',
    'ㅑ',
    'ㅒ',
    'ㅓ',
    'ㅔ',
    'ㅕ',
    'ㅖ',
    'ㅗ',
    'ㅘ',
    'ㅙ',
    'ㅚ',
    'ㅛ',
    'ㅜ',
    'ㅝ',
    'ㅞ',
    'ㅟ',
    'ㅠ',
    'ㅡ',
    'ㅢ',
    'ㅣ',
  ];

  /// 종성 목록 (28개, 인덱스 0 = 종성 없음)
  static const List<String> finals = [
    '',
    'ㄱ',
    'ㄲ',
    'ㄳ',
    'ㄴ',
    'ㄵ',
    'ㄶ',
    'ㄷ',
    'ㄹ',
    'ㄺ',
    'ㄻ',
    'ㄼ',
    'ㄽ',
    'ㄾ',
    'ㄿ',
    'ㅀ',
    'ㅁ',
    'ㅂ',
    'ㅄ',
    'ㅅ',
    'ㅆ',
    'ㅇ',
    'ㅈ',
    'ㅊ',
    'ㅋ',
    'ㅌ',
    'ㅍ',
    'ㅎ',
  ];

  /// [charCode]가 한글 완성형 음절인지 판별한다.
  static bool isSyllable(int charCode) {
    return charCode >= _syllableBase && charCode <= _syllableEnd;
  }

  /// 한글 문자열을 자모로 분해한다.
  ///
  /// 한글 완성형 음절만 분해하며, 비한글 문자는 무시한다.
  /// 예: '한글' → [Jamo(ㅎ,ㅏ,ㄴ), Jamo(ㄱ,ㅡ,ㄹ)]
  static List<Jamo> decompose(String text) {
    final result = <Jamo>[];
    for (final rune in text.runes) {
      if (!isSyllable(rune)) continue;

      final offset = rune - _syllableBase;
      final initialIdx = offset ~/ (_medialCount * _finalCount);
      final medialIdx = (offset % (_medialCount * _finalCount)) ~/ _finalCount;
      final finalIdx = offset % _finalCount;

      result.add(Jamo(
        initial: initials[initialIdx],
        medial: medials[medialIdx],
        final_: finals[finalIdx],
      ));
    }
    return result;
  }

  /// 초성, 중성, 종성 인덱스로 한글 음절을 조합한다.
  ///
  /// 예: compose(18, 0, 4) → '한' (ㅎ=18, ㅏ=0, ㄴ=4)
  static String compose(int initialIdx, int medialIdx, int finalIdx) {
    final code = _syllableBase +
        (initialIdx * _medialCount + medialIdx) * _finalCount +
        finalIdx;
    return String.fromCharCode(code);
  }

  /// [Jamo] 객체로부터 한글 음절을 조합한다.
  static String composeFromJamo(Jamo jamo) {
    final initialIdx = initials.indexOf(jamo.initial);
    final medialIdx = medials.indexOf(jamo.medial);
    final finalIdx = finals.indexOf(jamo.final_);

    if (initialIdx == -1 || medialIdx == -1 || finalIdx == -1) {
      return '';
    }

    return compose(initialIdx, medialIdx, finalIdx);
  }

  /// 자모 리스트를 한글 문자열로 조합한다.
  static String composeAll(List<Jamo> jamos) {
    final buffer = StringBuffer();
    for (final jamo in jamos) {
      buffer.write(composeFromJamo(jamo));
    }
    return buffer.toString();
  }
}

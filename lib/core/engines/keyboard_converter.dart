import 'package:fangeul/core/engines/hangul_engine.dart';

/// 영↔한 키보드 위치 변환기.
///
/// 두벌식 표준 자판 레이아웃 기반으로 영문 키 입력을
/// 한글 자모로 매핑한 뒤, [HangulEngine]을 이용해 음절로 조합한다.
class KeyboardConverter {
  KeyboardConverter._();

  // ── 영문 → 자모 매핑 (두벌식 표준) ──

  /// 영문 키 → 한글 자모 매핑 (일반 + Shift)
  static const Map<String, String> _engToJamo = {
    // 일반 (소문자)
    'q': 'ㅂ', 'w': 'ㅈ', 'e': 'ㄷ', 'r': 'ㄱ', 't': 'ㅅ',
    'y': 'ㅛ', 'u': 'ㅕ', 'i': 'ㅑ', 'o': 'ㅐ', 'p': 'ㅔ',
    'a': 'ㅁ', 's': 'ㄴ', 'd': 'ㅇ', 'f': 'ㄹ', 'g': 'ㅎ',
    'h': 'ㅗ', 'j': 'ㅓ', 'k': 'ㅏ', 'l': 'ㅣ',
    'z': 'ㅋ', 'x': 'ㅌ', 'c': 'ㅊ', 'v': 'ㅍ',
    'b': 'ㅠ', 'n': 'ㅜ', 'm': 'ㅡ',
    // Shift (대문자) — 쌍자음 + 추가 모음
    'Q': 'ㅃ', 'W': 'ㅉ', 'E': 'ㄸ', 'R': 'ㄲ', 'T': 'ㅆ',
    'O': 'ㅒ', 'P': 'ㅖ',
  };

  /// 자모 → 영문 키 역매핑
  static final Map<String, String> _jamoToEng = () {
    final map = <String, String>{};
    _engToJamo.forEach((eng, jamo) {
      if (eng == eng.toLowerCase() || !map.containsKey(jamo)) {
        map[jamo] = eng;
      }
    });
    return map;
  }();

  // ── 자모 분류 ──

  static const Set<String> _initialConsonants = {
    'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ',
    'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
  };

  static const Set<String> _vowels = {
    'ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ',
    'ㅘ', 'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ',
    'ㅢ', 'ㅣ',
  };

  /// 종성으로 쓸 수 있는 자음 → 종성 인덱스 매핑
  static const Map<String, int> _finalConsonantIdx = {
    'ㄱ': 1, 'ㄲ': 2, 'ㄳ': 3, 'ㄴ': 4, 'ㄵ': 5, 'ㄶ': 6,
    'ㄷ': 7, 'ㄹ': 8, 'ㄺ': 9, 'ㄻ': 10, 'ㄼ': 11, 'ㄽ': 12,
    'ㄾ': 13, 'ㄿ': 14, 'ㅀ': 15, 'ㅁ': 16, 'ㅂ': 17, 'ㅄ': 18,
    'ㅅ': 19, 'ㅆ': 20, 'ㅇ': 21, 'ㅈ': 22, 'ㅊ': 23,
    'ㅋ': 24, 'ㅌ': 25, 'ㅍ': 26, 'ㅎ': 27,
  };

  /// 겹받침 조합 테이블: (첫 자음, 둘째 자음) → 겹받침
  static const Map<String, Map<String, String>> _doubleFinals = {
    'ㄱ': {'ㅅ': 'ㄳ'},
    'ㄴ': {'ㅈ': 'ㄵ', 'ㅎ': 'ㄶ'},
    'ㄹ': {
      'ㄱ': 'ㄺ', 'ㅁ': 'ㄻ', 'ㅂ': 'ㄼ', 'ㅅ': 'ㄽ',
      'ㅌ': 'ㄾ', 'ㅍ': 'ㄿ', 'ㅎ': 'ㅀ',
    },
    'ㅂ': {'ㅅ': 'ㅄ'},
  };

  /// 겹받침 → (첫 자음, 둘째 자음) 분리
  static const Map<String, List<String>> _doubleFinalSplit = {
    'ㄳ': ['ㄱ', 'ㅅ'], 'ㄵ': ['ㄴ', 'ㅈ'], 'ㄶ': ['ㄴ', 'ㅎ'],
    'ㄺ': ['ㄹ', 'ㄱ'], 'ㄻ': ['ㄹ', 'ㅁ'], 'ㄼ': ['ㄹ', 'ㅂ'],
    'ㄽ': ['ㄹ', 'ㅅ'], 'ㄾ': ['ㄹ', 'ㅌ'], 'ㄿ': ['ㄹ', 'ㅍ'],
    'ㅀ': ['ㄹ', 'ㅎ'], 'ㅄ': ['ㅂ', 'ㅅ'],
  };

  /// 복합 모음 조합 테이블
  static const Map<String, Map<String, String>> _compoundVowels = {
    'ㅗ': {'ㅏ': 'ㅘ', 'ㅐ': 'ㅙ', 'ㅣ': 'ㅚ'},
    'ㅜ': {'ㅓ': 'ㅝ', 'ㅔ': 'ㅞ', 'ㅣ': 'ㅟ'},
    'ㅡ': {'ㅣ': 'ㅢ'},
  };

  /// 영문 입력을 한글로 변환한다.
  ///
  /// 두벌식 표준 자판 레이아웃 기준으로 영문 키를 한글 자모로
  /// 매핑한 뒤 음절을 조합한다.
  /// 예: 'gksrmf' → '한글'
  static String engToKor(String input) {
    if (input.isEmpty) return '';

    final jamos = <String>[];
    for (final char in input.split('')) {
      final jamo = _engToJamo[char];
      if (jamo != null) {
        jamos.add(jamo);
      } else {
        jamos.add(char);
      }
    }

    return _assembleJamos(jamos);
  }

  /// 한글 입력을 영문으로 변환한다.
  ///
  /// 한글 음절을 자모로 분해한 뒤, 각 자모를 영문 키로 역매핑한다.
  /// 예: '한글' → 'gksrmf'
  static String korToEng(String input) {
    if (input.isEmpty) return '';

    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);

      if (HangulEngine.isSyllable(rune)) {
        final jamos = HangulEngine.decompose(char);
        for (final jamo in jamos) {
          buffer.write(_jamoToEng[jamo.initial] ?? '');
          buffer.write(_jamoToEng[jamo.medial] ?? '');
          if (jamo.final_.isNotEmpty) {
            final split = _doubleFinalSplit[jamo.final_];
            if (split != null) {
              buffer.write(_jamoToEng[split[0]] ?? '');
              buffer.write(_jamoToEng[split[1]] ?? '');
            } else {
              buffer.write(_jamoToEng[jamo.final_] ?? '');
            }
          }
        }
      } else if (_jamoToEng.containsKey(char)) {
        buffer.write(_jamoToEng[char]);
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  // ── 자모 → 음절 조합 FSM ──

  static String _assembleJamos(List<String> jamos) {
    final buffer = StringBuffer();
    var i = 0;

    while (i < jamos.length) {
      final current = jamos[i];

      if (!_initialConsonants.contains(current)) {
        if (_vowels.contains(current)) {
          buffer.write(current);
          i++;
        } else {
          buffer.write(current);
          i++;
        }
        continue;
      }

      // 초성 자음 발견
      final initialJamo = current;
      final initialIdx = HangulEngine.initials.indexOf(initialJamo);
      if (initialIdx == -1) {
        buffer.write(current);
        i++;
        continue;
      }

      // 다음이 모음인지 확인
      if (i + 1 >= jamos.length || !_vowels.contains(jamos[i + 1])) {
        buffer.write(current);
        i++;
        continue;
      }

      // 중성 모음
      var medialJamo = jamos[i + 1];
      i += 2;

      // 복합 모음 확인
      if (i < jamos.length && _compoundVowels.containsKey(medialJamo)) {
        final nextChar = jamos[i];
        final compound = _compoundVowels[medialJamo]?[nextChar];
        if (compound != null) {
          medialJamo = compound;
          i++;
        }
      }

      final medialIdx = HangulEngine.medials.indexOf(medialJamo);
      if (medialIdx == -1) {
        buffer.write(initialJamo);
        buffer.write(medialJamo);
        continue;
      }

      // 종성 확인
      var finalIdx = 0;

      if (i < jamos.length && _initialConsonants.contains(jamos[i])) {
        final possibleFinal = jamos[i];
        final possibleFinalIdx = _finalConsonantIdx[possibleFinal];

        if (possibleFinalIdx != null) {
          if (i + 1 < jamos.length && _vowels.contains(jamos[i + 1])) {
            // 다음에 모음 → 이 자음은 다음 음절의 초성
          } else if (i + 1 < jamos.length &&
              _initialConsonants.contains(jamos[i + 1])) {
            // 다음도 자음 → 겹받침 가능성 확인
            final nextConsonant = jamos[i + 1];
            final doubleFinal =
                _doubleFinals[possibleFinal]?[nextConsonant];

            if (doubleFinal != null) {
              final doubleFinalIdx = _finalConsonantIdx[doubleFinal];
              if (doubleFinalIdx != null) {
                if (i + 2 < jamos.length &&
                    _vowels.contains(jamos[i + 2])) {
                  // 겹받침 다음에 모음 → 첫 자음만 종성
                  finalIdx = possibleFinalIdx;
                  i++;
                } else {
                  // 겹받침 확정
                  finalIdx = doubleFinalIdx;
                  i += 2;
                }
              }
            } else {
              // 겹받침 불가 → 단일 종성
              finalIdx = possibleFinalIdx;
              i++;
            }
          } else {
            // 문자열 끝 → 종성 확정
            finalIdx = possibleFinalIdx;
            i++;
          }
        }
      }

      buffer.write(HangulEngine.compose(initialIdx, medialIdx, finalIdx));
    }

    return buffer.toString();
  }
}

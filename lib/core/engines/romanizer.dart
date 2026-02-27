import 'package:fangeul/core/engines/hangul_engine.dart';

/// 한글 → 로마자 발음 변환기.
///
/// 국립국어원 로마자 표기법(2000년 고시) 기반으로
/// 한글 텍스트를 로마자(Latin) 표기로 변환한다.
/// 2-pass 방식: 전처리(발음 규칙 적용) → 로마자 매핑.
class Romanizer {
  Romanizer._();

  // ── 초성 로마자 매핑 ──

  static const Map<String, String> _initialRoman = {
    'ㄱ': 'g', 'ㄲ': 'kk', 'ㄴ': 'n', 'ㄷ': 'd', 'ㄸ': 'tt',
    'ㄹ': 'r', 'ㅁ': 'm', 'ㅂ': 'b', 'ㅃ': 'pp',
    'ㅅ': 's', 'ㅆ': 'ss', 'ㅇ': '', 'ㅈ': 'j', 'ㅉ': 'jj',
    'ㅊ': 'ch', 'ㅋ': 'k', 'ㅌ': 't', 'ㅍ': 'p', 'ㅎ': 'h',
  };

  // ── 중성 로마자 매핑 ──

  static const Map<String, String> _medialRoman = {
    'ㅏ': 'a', 'ㅐ': 'ae', 'ㅑ': 'ya', 'ㅒ': 'yae',
    'ㅓ': 'eo', 'ㅔ': 'e', 'ㅕ': 'yeo', 'ㅖ': 'ye',
    'ㅗ': 'o', 'ㅘ': 'wa', 'ㅙ': 'wae', 'ㅚ': 'oe',
    'ㅛ': 'yo', 'ㅜ': 'u', 'ㅝ': 'wo', 'ㅞ': 'we',
    'ㅟ': 'wi', 'ㅠ': 'yu', 'ㅡ': 'eu', 'ㅢ': 'ui',
    'ㅣ': 'i',
  };

  // ── 종성 로마자 매핑 ──

  static const Map<String, String> _finalRoman = {
    '': '', 'ㄱ': 'k', 'ㄲ': 'k', 'ㄳ': 'k', 'ㄴ': 'n',
    'ㄵ': 'n', 'ㄶ': 'n', 'ㄷ': 't', 'ㄹ': 'l',
    'ㄺ': 'k', 'ㄻ': 'm', 'ㄼ': 'l', 'ㄽ': 'l',
    'ㄾ': 'l', 'ㄿ': 'l', 'ㅀ': 'l', 'ㅁ': 'm',
    'ㅂ': 'p', 'ㅄ': 'p', 'ㅅ': 't', 'ㅆ': 't',
    'ㅇ': 'ng', 'ㅈ': 't', 'ㅊ': 't', 'ㅋ': 'k',
    'ㅌ': 't', 'ㅍ': 'p', 'ㅎ': 't',
  };

  // ── 겹받침 분리 테이블 ──

  static const Map<String, List<String>> _doubleFinalSplit = {
    'ㄳ': ['ㄱ', 'ㅅ'], 'ㄵ': ['ㄴ', 'ㅈ'], 'ㄶ': ['ㄴ', 'ㅎ'],
    'ㄺ': ['ㄹ', 'ㄱ'], 'ㄻ': ['ㄹ', 'ㅁ'], 'ㄼ': ['ㄹ', 'ㅂ'],
    'ㄽ': ['ㄹ', 'ㅅ'], 'ㄾ': ['ㄹ', 'ㅌ'], 'ㄿ': ['ㄹ', 'ㅍ'],
    'ㅀ': ['ㄹ', 'ㅎ'], 'ㅄ': ['ㅂ', 'ㅅ'],
  };

  // ── 발음 변화 규칙 테이블 (테이블 드리븐) ──

  /// 비음화: 종성 + 초성(ㄴ,ㅁ) → 변환된 [종성, 초성]
  static const Map<String, Map<String, List<String>>> _nasalization = {
    'ㄱ': {'ㄴ': ['ㅇ', 'ㄴ'], 'ㅁ': ['ㅇ', 'ㅁ']},
    'ㄲ': {'ㄴ': ['ㅇ', 'ㄴ'], 'ㅁ': ['ㅇ', 'ㅁ']},
    'ㄳ': {'ㄴ': ['ㅇ', 'ㄴ'], 'ㅁ': ['ㅇ', 'ㅁ']},
    'ㄺ': {'ㄴ': ['ㅇ', 'ㄴ'], 'ㅁ': ['ㅇ', 'ㅁ']},
    'ㄷ': {'ㄴ': ['ㄴ', 'ㄴ'], 'ㅁ': ['ㄴ', 'ㅁ']},
    'ㅅ': {'ㄴ': ['ㄴ', 'ㄴ'], 'ㅁ': ['ㄴ', 'ㅁ']},
    'ㅆ': {'ㄴ': ['ㄴ', 'ㄴ'], 'ㅁ': ['ㄴ', 'ㅁ']},
    'ㅈ': {'ㄴ': ['ㄴ', 'ㄴ'], 'ㅁ': ['ㄴ', 'ㅁ']},
    'ㅊ': {'ㄴ': ['ㄴ', 'ㄴ'], 'ㅁ': ['ㄴ', 'ㅁ']},
    'ㅌ': {'ㄴ': ['ㄴ', 'ㄴ'], 'ㅁ': ['ㄴ', 'ㅁ']},
    'ㅂ': {'ㄴ': ['ㅁ', 'ㄴ'], 'ㅁ': ['ㅁ', 'ㅁ']},
    'ㅄ': {'ㄴ': ['ㅁ', 'ㄴ'], 'ㅁ': ['ㅁ', 'ㅁ']},
    'ㅍ': {'ㄴ': ['ㅁ', 'ㄴ'], 'ㅁ': ['ㅁ', 'ㅁ']},
    'ㄿ': {'ㄴ': ['ㅁ', 'ㄴ'], 'ㅁ': ['ㅁ', 'ㅁ']},
  };

  /// 격음화 결과 매핑: 대표음 → 격음
  static const Map<String, String> _aspirationMap = {
    'ㄱ': 'ㅋ', 'ㄷ': 'ㅌ', 'ㅂ': 'ㅍ', 'ㅈ': 'ㅊ',
  };

  /// 구개음화: ㄷ/ㅌ종성 + ㅣ → ㅈ/ㅊ
  static const Map<String, String> _palatalization = {
    'ㄷ': 'ㅈ',
    'ㅌ': 'ㅊ',
  };

  /// 경음화: 초성 → 된소리
  static const Map<String, String> _fortition = {
    'ㄱ': 'ㄲ', 'ㄷ': 'ㄸ', 'ㅂ': 'ㅃ', 'ㅅ': 'ㅆ', 'ㅈ': 'ㅉ',
  };

  /// 경음화 트리거 종성 대표음
  static const Set<String> _fortitionTriggers = {'ㄱ', 'ㄷ', 'ㅂ'};

  /// 한글 텍스트를 로마자로 변환한다.
  ///
  /// 국립국어원 로마자 표기법 기반으로 발음 변화 규칙을 적용한다.
  /// 예: '사랑해요' → 'saranghaeyo'
  static String romanize(String text) {
    if (text.isEmpty) return '';

    // Pass 1: 텍스트 → 토큰 리스트 + 발음 규칙 적용
    final tokens = _preprocess(text);

    // Pass 2: 토큰 → 로마자
    return _toRoman(tokens);
  }

  /// Pass 1: 텍스트를 토큰 리스트로 변환하고 발음 규칙을 적용한다.
  static List<_Token> _preprocess(String text) {
    final tokens = <_Token>[];

    for (final rune in text.runes) {
      if (HangulEngine.isSyllable(rune)) {
        final jamos = HangulEngine.decompose(String.fromCharCode(rune));
        if (jamos.isNotEmpty) {
          final j = jamos[0];
          tokens.add(_SyllableInfo(
            initial: j.initial,
            medial: j.medial,
            final_: j.final_,
          ));
        }
      } else {
        tokens.add(_LiteralToken(String.fromCharCode(rune)));
      }
    }

    // 인접 음절 경계에서 발음 규칙 적용
    for (var i = 0; i < tokens.length - 1; i++) {
      final curr = tokens[i];
      final next = tokens[i + 1];
      if (curr is _SyllableInfo && next is _SyllableInfo) {
        _applyRules(curr, next);
      }
    }

    return tokens;
  }

  /// 인접 두 음절에 발음 변화 규칙을 적용한다.
  ///
  /// 터미널 규칙(연음, 격음화, 구개음화)은 적용 후 즉시 반환.
  /// 논터미널 규칙(ㄹ비음화, 유음화, 비음화, 경음화)은 체이닝 허용.
  static void _applyRules(_SyllableInfo curr, _SyllableInfo next) {
    if (curr.final_.isEmpty) return;

    // ── 터미널 규칙 (하나만 적용되면 종료) ──

    // 1. 연음법칙 (+ post-liaison 구개음화)
    if (_applyLiaison(curr, next)) return;

    // 2. 격음화
    if (_applyAspiration(curr, next)) return;

    // 3. 구개음화 (비연음 케이스, 드묾)
    if (_applyPalatalization(curr, next)) return;

    // ── 논터미널 규칙 (체이닝 허용) ──

    // 4. 유음화 (ㄹ+ㄴ→ㄹ+ㄹ, ㄴ+ㄹ→ㄹ+ㄹ)
    if (_applyLiquidization(curr, next)) return;

    // 5. ㄹ 비음화 (비ㄹㄴ 종성 + ㄹ초성 → ㄹ→ㄴ)
    //    short-circuit 하지 않음 — 비음화와 체이닝 가능
    _applyRieulNasalization(curr, next);

    // 6. 비음화 (ㄹ비음화 결과와 체이닝: 독립 ㄱ+ㄹ→ㄱ+ㄴ→ㅇ+ㄴ)
    if (_applyNasalization(curr, next)) return;

    // 7. 경음화
    _applyFortition(curr, next);
  }

  /// 연음법칙: 종성 + ㅇ초성 → 종성이 다음 초성으로 이동.
  ///
  /// 이동된 자음에 대해 구개음화도 함께 처리한다.
  /// 예: 같이(ㅌ+ㅇㅣ) → 연음 후 ㅌ+ㅣ → 구개음화 → ㅊ+ㅣ = gachi
  static bool _applyLiaison(_SyllableInfo curr, _SyllableInfo next) {
    if (next.initial != 'ㅇ') return false;

    String movedConsonant;
    final split = _doubleFinalSplit[curr.final_];
    if (split != null) {
      // 겹받침: 첫 자음은 종성, 둘째 자음은 연음
      curr.final_ = split[0];
      movedConsonant = split[1];
    } else {
      // 단일 종성 → 전부 연음
      movedConsonant = curr.final_;
      curr.final_ = '';
    }

    // post-liaison 구개음화: 이동된 ㄷ/ㅌ + ㅣ → ㅈ/ㅊ
    if (next.medial == 'ㅣ') {
      final palatalized = _palatalization[movedConsonant];
      if (palatalized != null) {
        next.initial = palatalized;
        return true;
      }
    }

    next.initial = movedConsonant;
    return true;
  }

  /// 격음화: 자음종성 + ㅎ초성 → 격음 / ㅎ종성 + 자음초성 → 격음.
  ///
  /// 대표음(effectiveFinal)을 기반으로 격음 가능 여부를 판단한다.
  /// 예: 축하(ㄱ+ㅎ→ㅋ), 못하다(ㅅ→ㄷ+ㅎ→ㅌ), 좋다(ㅎ+ㄷ→ㅌ)
  static bool _applyAspiration(_SyllableInfo curr, _SyllableInfo next) {
    // Path 1: ㅎ 포함 종성 + 자음 초성 → 격음
    final isHFinal =
        curr.final_ == 'ㅎ' ||
        curr.final_ == 'ㄶ' ||
        curr.final_ == 'ㅀ';

    if (isHFinal) {
      final aspirated = _aspirationMap[next.initial];
      if (aspirated == null) return false;

      if (curr.final_ == 'ㄶ') {
        curr.final_ = 'ㄴ';
      } else if (curr.final_ == 'ㅀ') {
        curr.final_ = 'ㄹ';
      } else {
        curr.final_ = '';
      }
      next.initial = aspirated;
      return true;
    }

    // Path 2: 자음 종성 + ㅎ 초성 → 격음
    if (next.initial != 'ㅎ') return false;

    final effectiveFinal = _getEffectiveFinal(curr.final_);
    final aspirated = _aspirationMap[effectiveFinal];
    if (aspirated == null) return false;

    // 겹받침이면 첫 자음만 남김
    final split = _doubleFinalSplit[curr.final_];
    if (split != null) {
      curr.final_ = split[0];
    } else {
      curr.final_ = '';
    }
    next.initial = aspirated;
    return true;
  }

  /// 구개음화: ㄷ/ㅌ종성 + ㅣ모음 → ㅈ/ㅊ (비연음 케이스).
  static bool _applyPalatalization(_SyllableInfo curr, _SyllableInfo next) {
    if (next.medial != 'ㅣ') return false;

    final effectiveFinal = _getEffectiveFinal(curr.final_);
    final palatalized = _palatalization[effectiveFinal];
    if (palatalized == null) return false;

    next.initial = palatalized;
    curr.final_ = '';
    return true;
  }

  /// 비음화: 종성(ㄱ,ㄷ,ㅂ계열) + 초성(ㄴ,ㅁ) → 종성비음화.
  static bool _applyNasalization(_SyllableInfo curr, _SyllableInfo next) {
    final nasalized = _nasalization[curr.final_]?[next.initial];
    if (nasalized == null) return false;

    curr.final_ = nasalized[0];
    next.initial = nasalized[1];
    return true;
  }

  /// ㄹ 비음화: 비(ㄹ,ㄴ)종성 + ㄹ초성 → ㄹ→ㄴ.
  ///
  /// 유음화(ㄹ+ㄴ, ㄴ+ㄹ)와 겹치지 않도록, ㄹ/ㄴ 종성은 제외한다.
  /// 비음화와 체이닝 가능하므로 short-circuit하지 않는다.
  /// 예: 종로(ㅇ+ㄹ→ㅇ+ㄴ), 독립(ㄱ+ㄹ→ㄱ+ㄴ→비음화→ㅇ+ㄴ)
  static bool _applyRieulNasalization(
    _SyllableInfo curr,
    _SyllableInfo next,
  ) {
    if (next.initial != 'ㄹ') return false;

    final effectiveFinal = _getEffectiveFinal(curr.final_);
    // ㄹ/ㄴ 종성은 유음화 영역
    if (effectiveFinal == 'ㄹ' || effectiveFinal == 'ㄴ') return false;

    next.initial = 'ㄴ';
    return true;
  }

  /// 유음화: ㄹ종성+ㄴ초성 → ㄴ→ㄹ / ㄴ종성+ㄹ초성 → 둘 다 ㄹ.
  ///
  /// 예: 설날(ㄹ+ㄴ→ㄹ+ㄹ), 신라(ㄴ+ㄹ→ㄹ+ㄹ)
  static bool _applyLiquidization(_SyllableInfo curr, _SyllableInfo next) {
    final effectiveFinal = _getEffectiveFinal(curr.final_);

    // ㄹ종성 + ㄴ초성 → ㄴ→ㄹ
    if (effectiveFinal == 'ㄹ' && next.initial == 'ㄴ') {
      next.initial = 'ㄹ';
      return true;
    }

    // ㄴ종성 + ㄹ초성 → 둘 다 ㄹ
    if (effectiveFinal == 'ㄴ' && next.initial == 'ㄹ') {
      curr.final_ = 'ㄹ';
      return true;
    }

    return false;
  }

  /// 경음화: 종성(ㄱ,ㄷ,ㅂ) + 초성(ㄱ,ㄷ,ㅂ,ㅅ,ㅈ) → 된소리.
  ///
  /// 예: 학교(ㄱ+ㄱ→ㄱ+ㄲ), 식당(ㄱ+ㄷ→ㄱ+ㄸ)
  static bool _applyFortition(_SyllableInfo curr, _SyllableInfo next) {
    final effectiveFinal = _getEffectiveFinal(curr.final_);

    if (!_fortitionTriggers.contains(effectiveFinal)) return false;

    final fortified = _fortition[next.initial];
    if (fortified == null) return false;

    next.initial = fortified;
    return true;
  }

  /// Pass 2: 전처리된 토큰 리스트를 로마자 문자열로 변환한다.
  ///
  /// ㄹ초성이 ㄹ종성 뒤에 올 때(유음화/겹ㄹ) 'l'로 표기한다.
  /// 국립국어원 표기법: ㄹㄹ → 'll' (예: 설날→seollal)
  static String _toRoman(List<_Token> tokens) {
    final buffer = StringBuffer();
    for (var i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      if (token is _SyllableInfo) {
        // ㄹ초성이 ㄹ종성 뒤에 올 때 → 'l' (유음화/겹ㄹ)
        if (token.initial == 'ㄹ' &&
            i > 0 &&
            tokens[i - 1] is _SyllableInfo &&
            (tokens[i - 1] as _SyllableInfo).final_ == 'ㄹ') {
          buffer.write('l');
        } else {
          buffer.write(_initialRoman[token.initial] ?? '');
        }
        buffer.write(_medialRoman[token.medial] ?? '');
        if (token.final_.isNotEmpty) {
          buffer.write(_finalRoman[token.final_] ?? '');
        }
      } else if (token is _LiteralToken) {
        buffer.write(token.value);
      }
    }
    return buffer.toString();
  }

  /// 종성의 대표음을 반환한다.
  ///
  /// 겹받침은 대표 자음으로, 장애음은 대표음(ㅅ→ㄷ 등)으로 변환한다.
  static String _getEffectiveFinal(String finalCons) {
    const effectiveMap = {
      // 겹받침
      'ㄳ': 'ㄱ', 'ㄵ': 'ㄴ', 'ㄶ': 'ㄴ', 'ㄺ': 'ㄱ',
      'ㄻ': 'ㅁ', 'ㄼ': 'ㄹ', 'ㄽ': 'ㄹ', 'ㄾ': 'ㄹ',
      'ㄿ': 'ㄹ', 'ㅀ': 'ㄹ', 'ㅄ': 'ㅂ',
      // 장애음 중화 (대표음)
      'ㄲ': 'ㄱ',
      'ㅅ': 'ㄷ', 'ㅆ': 'ㄷ', 'ㅈ': 'ㄷ', 'ㅊ': 'ㄷ', 'ㅌ': 'ㄷ',
      'ㅎ': 'ㄷ',
      'ㅍ': 'ㅂ',
    };
    return effectiveMap[finalCons] ?? finalCons;
  }
}

/// 토큰 베이스 클래스.
sealed class _Token {}

/// 한글 음절의 mutable 래퍼. Pass 1에서 발음 규칙 적용 시 변경된다.
class _SyllableInfo extends _Token {
  /// Creates a mutable syllable info for preprocessing.
  _SyllableInfo({
    required this.initial,
    required this.medial,
    required this.final_,
  });

  /// 초성 (발음 규칙 적용 후 변경될 수 있음)
  String initial;

  /// 중성
  String medial;

  /// 종성 (발음 규칙 적용 후 변경될 수 있음)
  String final_;
}

/// 비한글 문자 토큰.
class _LiteralToken extends _Token {
  /// Creates a literal (non-hangul) token.
  _LiteralToken(this.value);

  /// 원본 문자
  final String value;
}

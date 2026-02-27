import 'package:fangeul/core/engines/hangul_engine.dart';

/// 한글 엔진들이 공유하는 자모 데이터 테이블.
///
/// 겹받침 분리/조합, 복합 모음 분리/조합, 종성 역인덱스 등
/// 여러 엔진([KeyboardConverter], [Romanizer])에서 공통으로 사용하는
/// 테이블을 한 곳에 모아 중복과 drift 위험을 제거한다.
class HangulTables {
  HangulTables._();

  /// 겹받침 → [첫 자음, 둘째 자음] 분리 테이블.
  ///
  /// 예: 'ㄳ' → ['ㄱ', 'ㅅ']
  static const Map<String, List<String>> doubleFinalSplit = {
    'ㄳ': ['ㄱ', 'ㅅ'],
    'ㄵ': ['ㄴ', 'ㅈ'],
    'ㄶ': ['ㄴ', 'ㅎ'],
    'ㄺ': ['ㄹ', 'ㄱ'],
    'ㄻ': ['ㄹ', 'ㅁ'],
    'ㄼ': ['ㄹ', 'ㅂ'],
    'ㄽ': ['ㄹ', 'ㅅ'],
    'ㄾ': ['ㄹ', 'ㅌ'],
    'ㄿ': ['ㄹ', 'ㅍ'],
    'ㅀ': ['ㄹ', 'ㅎ'],
    'ㅄ': ['ㅂ', 'ㅅ'],
  };

  /// 겹받침 조합 테이블: (첫 자음, 둘째 자음) → 겹받침.
  ///
  /// 예: 'ㄱ' + 'ㅅ' → 'ㄳ'
  static const Map<String, Map<String, String>> doubleFinalCombine = {
    'ㄱ': {'ㅅ': 'ㄳ'},
    'ㄴ': {'ㅈ': 'ㄵ', 'ㅎ': 'ㄶ'},
    'ㄹ': {
      'ㄱ': 'ㄺ',
      'ㅁ': 'ㄻ',
      'ㅂ': 'ㄼ',
      'ㅅ': 'ㄽ',
      'ㅌ': 'ㄾ',
      'ㅍ': 'ㄿ',
      'ㅎ': 'ㅀ',
    },
    'ㅂ': {'ㅅ': 'ㅄ'},
  };

  /// 복합 모음 조합 테이블: (첫 모음, 둘째 모음) → 복합 모음.
  ///
  /// 예: 'ㅗ' + 'ㅏ' → 'ㅘ'
  static const Map<String, Map<String, String>> compoundVowelCombine = {
    'ㅗ': {'ㅏ': 'ㅘ', 'ㅐ': 'ㅙ', 'ㅣ': 'ㅚ'},
    'ㅜ': {'ㅓ': 'ㅝ', 'ㅔ': 'ㅞ', 'ㅣ': 'ㅟ'},
    'ㅡ': {'ㅣ': 'ㅢ'},
  };

  /// 복합 모음 → [첫 모음, 둘째 모음] 분리 테이블.
  ///
  /// [compoundVowelCombine]의 역매핑. korToEng 변환 시 사용.
  /// 예: 'ㅘ' → ['ㅗ', 'ㅏ']
  static const Map<String, List<String>> compoundVowelSplit = {
    'ㅘ': ['ㅗ', 'ㅏ'],
    'ㅙ': ['ㅗ', 'ㅐ'],
    'ㅚ': ['ㅗ', 'ㅣ'],
    'ㅝ': ['ㅜ', 'ㅓ'],
    'ㅞ': ['ㅜ', 'ㅔ'],
    'ㅟ': ['ㅜ', 'ㅣ'],
    'ㅢ': ['ㅡ', 'ㅣ'],
  };

  /// 종성 문자 → 종성 인덱스 역매핑.
  ///
  /// [HangulEngine.finals]에서 자동 생성. 종성 없음('')은 제외.
  static final Map<String, int> finalConsonantIndex = () {
    final map = <String, int>{};
    for (var i = 1; i < HangulEngine.finals.length; i++) {
      map[HangulEngine.finals[i]] = i;
    }
    return map;
  }();
}

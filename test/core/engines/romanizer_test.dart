import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/engines/romanizer.dart';

void main() {
  group('Romanizer — 기본 자모 매핑', () {
    test('should romanize 가 to ga', () {
      expect(Romanizer.romanize('가'), equals('ga'));
    });

    test('should romanize 나 to na', () {
      expect(Romanizer.romanize('나'), equals('na'));
    });

    test('should romanize 한 to han', () {
      expect(Romanizer.romanize('한'), equals('han'));
    });

    test('should return empty string for empty input', () {
      expect(Romanizer.romanize(''), equals(''));
    });

    test('should pass through non-hangul characters', () {
      expect(Romanizer.romanize('123'), equals('123'));
    });

    test('should handle spaces', () {
      expect(Romanizer.romanize('가 나'), equals('ga na'));
    });
  });

  group('Romanizer — 연음법칙', () {
    test('should apply liaison: 음악 → eumak', () {
      expect(Romanizer.romanize('음악'), equals('eumak'));
    });

    test('should apply liaison: 먹어 → meogeo', () {
      expect(Romanizer.romanize('먹어'), equals('meogeo'));
    });

    test('should apply liaison: 없어요 → eopseoyo', () {
      expect(Romanizer.romanize('없어요'), equals('eopseoyo'));
    });
  });

  group('Romanizer — 비음화', () {
    test('should apply nasalization: 합니다 → hamnida', () {
      expect(Romanizer.romanize('합니다'), equals('hamnida'));
    });

    test('should apply nasalization: 국물 → gungmul', () {
      expect(Romanizer.romanize('국물'), equals('gungmul'));
    });

    test('should apply nasalization: 읽는 → ingneun', () {
      expect(Romanizer.romanize('읽는'), equals('ingneun'));
    });
  });

  group('Romanizer — 격음화', () {
    test('should apply aspiration: 좋다 → jota', () {
      expect(Romanizer.romanize('좋다'), equals('jota'));
    });

    test('should apply aspiration: 놓다 → nota', () {
      expect(Romanizer.romanize('놓다'), equals('nota'));
    });

    test('should apply aspiration: 축하 → chuka', () {
      expect(Romanizer.romanize('축하'), equals('chuka'));
    });
  });

  group('Romanizer — 구개음화', () {
    test('should apply palatalization: 같이 → gachi', () {
      expect(Romanizer.romanize('같이'), equals('gachi'));
    });

    test('should apply palatalization: 굳이 → guji', () {
      expect(Romanizer.romanize('굳이'), equals('guji'));
    });

    test('should apply palatalization: 해돋이 → haedoji', () {
      expect(Romanizer.romanize('해돋이'), equals('haedoji'));
    });
  });

  group('Romanizer — 경음화', () {
    test('should apply fortition: 학교 → hakkkyo', () {
      expect(Romanizer.romanize('학교'), equals('hakkkyo'));
    });

    test('should apply fortition: 식당 → sikttang', () {
      expect(Romanizer.romanize('식당'), equals('sikttang'));
    });

    test('should apply fortition: 입구 → ipkku', () {
      expect(Romanizer.romanize('입구'), equals('ipkku'));
    });
  });

  group('Romanizer — ㄹ 비음화', () {
    test('should apply ㄹ-nasalization: 심리 → simni', () {
      expect(Romanizer.romanize('심리'), equals('simni'));
    });

    test('should apply ㄹ-nasalization: 종로 → jongno', () {
      expect(Romanizer.romanize('종로'), equals('jongno'));
    });

    test('should apply ㄹ-nasalization: 정류장 → jeongnyujang', () {
      expect(Romanizer.romanize('정류장'), equals('jeongnyujang'));
    });
  });

  group('Romanizer — 유음화', () {
    test('should apply liquidization: 설날 → seollal', () {
      expect(Romanizer.romanize('설날'), equals('seollal'));
    });

    test('should apply liquidization: 칼날 → kallal', () {
      expect(Romanizer.romanize('칼날'), equals('kallal'));
    });

    test('should apply liquidization: 신라 → silla', () {
      expect(Romanizer.romanize('신라'), equals('silla'));
    });
  });

  group('Romanizer — 규칙 중첩', () {
    test('should handle liaison with compound final: 읽어요 → ilgeoyo', () {
      expect(Romanizer.romanize('읽어요'), equals('ilgeoyo'));
    });

    test('should handle aspiration: 못하다 → motada', () {
      expect(Romanizer.romanize('못하다'), equals('motada'));
    });

    test('should handle nasalization chain: 독립 → dongnip', () {
      expect(Romanizer.romanize('독립'), equals('dongnip'));
    });
  });

  group('Romanizer — ㅇ종성 연음 예외', () {
    test('should not liaison ㅇ final: 강아지 → gangaji', () {
      expect(Romanizer.romanize('강아지'), equals('gangaji'));
    });

    test('should not liaison ㅇ final: 영어 → yeongeo', () {
      expect(Romanizer.romanize('영어'), equals('yeongeo'));
    });
  });

  group('Romanizer — ㅎ탈락', () {
    test('should drop ㅎ before ㅇ: 좋아 → joa', () {
      expect(Romanizer.romanize('좋아'), equals('joa'));
    });

    test('should drop ㅎ before ㅇ: 놓아 → noa', () {
      expect(Romanizer.romanize('놓아'), equals('noa'));
    });

    test('should drop ㅎ in ㄶ before ㅇ: 많이 → mani', () {
      expect(Romanizer.romanize('많이'), equals('mani'));
    });

    test('should drop ㅎ in ㅀ before ㅇ: 잃어 → ireo', () {
      expect(Romanizer.romanize('잃어'), equals('ireo'));
    });

    test('should drop ㅎ in ㄶ before ㅇ: 않아 → ana', () {
      expect(Romanizer.romanize('않아'), equals('ana'));
    });
  });

  group('Romanizer — 실사용 문구', () {
    test('should romanize 사랑해요 → saranghaeyo', () {
      expect(Romanizer.romanize('사랑해요'), equals('saranghaeyo'));
    });

    test('should romanize 안녕하세요 → annyeonghaseyo', () {
      expect(Romanizer.romanize('안녕하세요'), equals('annyeonghaseyo'));
    });

    test('should romanize 감사합니다 → gamsahamnida', () {
      expect(Romanizer.romanize('감사합니다'), equals('gamsahamnida'));
    });

    test('should romanize 화이팅 → hwaiting', () {
      expect(Romanizer.romanize('화이팅'), equals('hwaiting'));
    });

    test('should romanize 보고 싶어요 → bogo sipeoyo', () {
      expect(Romanizer.romanize('보고 싶어요'), equals('bogo sipeoyo'));
    });
  });

  group('Romanizer — 낱자모 필터링', () {
    test('should return empty for standalone consonants', () {
      expect(Romanizer.romanize('ㅎㅎㅎㅎ'), equals(''));
    });

    test('should return empty for standalone vowels', () {
      expect(Romanizer.romanize('ㅣㅣㅣ'), equals(''));
    });

    test('should return empty for mixed standalone jamo', () {
      expect(Romanizer.romanize('ㅏㅏㅏㅏ'), equals(''));
    });

    test('should romanize complete syllables and skip trailing jamo', () {
      expect(Romanizer.romanize('사랑ㅎ'), equals('sarang'));
    });

    test('should romanize complete syllables and skip leading jamo', () {
      expect(Romanizer.romanize('ㅎ사랑'), equals('sarang'));
    });

    test('should keep non-Korean literals while skipping jamo', () {
      expect(Romanizer.romanize('ㅎhello'), equals('hello'));
    });

    test('should handle mixed syllables and jamo in sequence', () {
      expect(Romanizer.romanize('한ㅎ글'), equals('hangeul'));
    });
  });
}

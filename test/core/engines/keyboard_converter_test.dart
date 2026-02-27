import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/engines/keyboard_converter.dart';

void main() {
  group('KeyboardConverter.engToKor', () {
    test('should convert gksrmf to 한글', () {
      expect(KeyboardConverter.engToKor('gksrmf'), equals('한글'));
    });

    test('should convert tkfkdgody to 사랑해요', () {
      expect(KeyboardConverter.engToKor('tkfkdgody'), equals('사랑해요'));
    });

    test('should convert dkssudgktpdy to 안녕하세요', () {
      expect(KeyboardConverter.engToKor('dkssudgktpdy'), equals('안녕하세요'));
    });

    test('should handle shift for double consonants (ㅃ)', () {
      expect(KeyboardConverter.engToKor('Qkf'), equals('빨'));
    });

    test('should handle shift for double consonants (ㄲ)', () {
      expect(KeyboardConverter.engToKor('Rnf'), equals('꿀'));
    });

    test('should handle shift vowel ㅒ when O pressed', () {
      expect(KeyboardConverter.engToKor('sO'), equals('냬'));
    });

    test('should handle shift vowel ㅖ when P pressed', () {
      expect(KeyboardConverter.engToKor('sP'), equals('녜'));
    });

    test('should handle double final consonants (겹받침)', () {
      expect(KeyboardConverter.engToKor('ekfr'), equals('닭'));
    });

    test('should pass through non-mappable characters', () {
      expect(KeyboardConverter.engToKor('123!'), equals('123!'));
    });

    test('should handle mixed input', () {
      expect(KeyboardConverter.engToKor('gksrmf123'), equals('한글123'));
    });

    test('should return empty string for empty input', () {
      expect(KeyboardConverter.engToKor(''), equals(''));
    });

    test('should handle spaces', () {
      expect(KeyboardConverter.engToKor('gks rmf'), equals('한 글'));
    });

    test('should handle single vowel input', () {
      expect(KeyboardConverter.engToKor('k'), equals('ㅏ'));
    });

    test('should handle single consonant input', () {
      expect(KeyboardConverter.engToKor('r'), equals('ㄱ'));
    });
  });

  group('KeyboardConverter.korToEng', () {
    test('should convert 한글 to gksrmf', () {
      expect(KeyboardConverter.korToEng('한글'), equals('gksrmf'));
    });

    test('should convert 사랑해요 to tkfkdgody', () {
      expect(KeyboardConverter.korToEng('사랑해요'), equals('tkfkdgody'));
    });

    test('should convert 안녕하세요 to dkssudgktpdy', () {
      expect(KeyboardConverter.korToEng('안녕하세요'), equals('dkssudgktpdy'));
    });

    test('should handle double final consonants', () {
      expect(KeyboardConverter.korToEng('닭'), equals('ekfr'));
    });

    test('should pass through non-hangul characters', () {
      expect(KeyboardConverter.korToEng('123!'), equals('123!'));
    });

    test('should handle spaces', () {
      expect(KeyboardConverter.korToEng('한 글'), equals('gks rmf'));
    });

    test('should return empty string for empty input', () {
      expect(KeyboardConverter.korToEng(''), equals(''));
    });
  });

  group('KeyboardConverter.korToEng — 복합 모음', () {
    test('should convert 와 to dhk when compound vowel ㅘ', () {
      expect(KeyboardConverter.korToEng('와'), equals('dhk'));
    });

    test('should convert 의 to dml when compound vowel ㅢ', () {
      expect(KeyboardConverter.korToEng('의'), equals('dml'));
    });

    test('should convert 뭐 to anj when compound vowel ㅝ', () {
      expect(KeyboardConverter.korToEng('뭐'), equals('anj'));
    });

    test('should convert 위 to dnl when compound vowel ㅟ', () {
      expect(KeyboardConverter.korToEng('위'), equals('dnl'));
    });

    test('should round-trip 화이팅 through korToEng→engToKor', () {
      const original = '화이팅';
      final eng = KeyboardConverter.korToEng(original);
      final back = KeyboardConverter.engToKor(eng);
      expect(back, equals(original));
    });

    test('should round-trip 의사 through korToEng→engToKor', () {
      const original = '의사';
      final eng = KeyboardConverter.korToEng(original);
      final back = KeyboardConverter.engToKor(eng);
      expect(back, equals(original));
    });
  });

  group('KeyboardConverter round-trip', () {
    test('should round-trip eng→kor→eng', () {
      const original = 'gksrmf';
      final kor = KeyboardConverter.engToKor(original);
      final back = KeyboardConverter.korToEng(kor);
      expect(back, equals(original));
    });

    test('should round-trip kor→eng→kor', () {
      const original = '사랑해요';
      final eng = KeyboardConverter.korToEng(original);
      final back = KeyboardConverter.engToKor(eng);
      expect(back, equals(original));
    });
  });
}

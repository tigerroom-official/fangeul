import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/engines/hangul_engine.dart';
import 'package:fangeul/core/engines/jamo.dart';

void main() {
  group('HangulEngine.decompose', () {
    test('should decompose 가 into ㄱ, ㅏ, (없음)', () {
      final result = HangulEngine.decompose('가');
      expect(
          result, equals([const Jamo(initial: 'ㄱ', medial: 'ㅏ', final_: '')]));
    });

    test('should decompose 한 into ㅎ, ㅏ, ㄴ', () {
      final result = HangulEngine.decompose('한');
      expect(
          result, equals([const Jamo(initial: 'ㅎ', medial: 'ㅏ', final_: 'ㄴ')]));
    });

    test('should decompose 글 into ㄱ, ㅡ, ㄹ', () {
      final result = HangulEngine.decompose('글');
      expect(
          result, equals([const Jamo(initial: 'ㄱ', medial: 'ㅡ', final_: 'ㄹ')]));
    });

    test('should decompose multi-char 한글 into two Jamo', () {
      final result = HangulEngine.decompose('한글');
      expect(result.length, equals(2));
      expect(result[0],
          equals(const Jamo(initial: 'ㅎ', medial: 'ㅏ', final_: 'ㄴ')));
      expect(result[1],
          equals(const Jamo(initial: 'ㄱ', medial: 'ㅡ', final_: 'ㄹ')));
    });

    test('should handle double final consonant ㄺ (닭)', () {
      final result = HangulEngine.decompose('닭');
      expect(
          result, equals([const Jamo(initial: 'ㄷ', medial: 'ㅏ', final_: 'ㄺ')]));
    });

    test('should handle double final consonant ㄳ (몫)', () {
      final result = HangulEngine.decompose('몫');
      expect(
          result, equals([const Jamo(initial: 'ㅁ', medial: 'ㅗ', final_: 'ㄳ')]));
    });

    test('should return empty list for empty string', () {
      final result = HangulEngine.decompose('');
      expect(result, isEmpty);
    });

    test('should skip non-hangul characters', () {
      final result = HangulEngine.decompose('A1!');
      expect(result, isEmpty);
    });

    test('should decompose mixed input keeping only hangul', () {
      final result = HangulEngine.decompose('가A나');
      expect(result.length, equals(2));
    });
  });

  group('HangulEngine.compose', () {
    test('should compose ㄱ+ㅏ into 가', () {
      final result = HangulEngine.compose(0, 0, 0);
      expect(result, equals('가'));
    });

    test('should compose ㅎ+ㅏ+ㄴ into 한', () {
      final result = HangulEngine.compose(18, 0, 4);
      expect(result, equals('한'));
    });

    test('should compose ㄱ+ㅡ+ㄹ into 글', () {
      final result = HangulEngine.compose(0, 18, 8);
      expect(result, equals('글'));
    });

    test('should compose ㄷ+ㅏ+ㄺ into 닭', () {
      final result = HangulEngine.compose(3, 0, 9);
      expect(result, equals('닭'));
    });
  });

  group('HangulEngine.composeFromJamo', () {
    test('should compose Jamo back to original syllable', () {
      const jamo = Jamo(initial: 'ㅎ', medial: 'ㅏ', final_: 'ㄴ');
      expect(HangulEngine.composeFromJamo(jamo), equals('한'));
    });

    test('should return empty string for invalid jamo', () {
      const jamo = Jamo(initial: 'X', medial: 'ㅏ', final_: '');
      expect(HangulEngine.composeFromJamo(jamo), equals(''));
    });
  });

  group('HangulEngine round-trip', () {
    test('should decompose and recompose to original', () {
      const original = '한글사랑해요';
      final jamos = HangulEngine.decompose(original);
      final recomposed = HangulEngine.composeAll(jamos);
      expect(recomposed, equals(original));
    });

    test('should round-trip all double final consonants', () {
      const words = '닭몫없값삶넓읽';
      final jamos = HangulEngine.decompose(words);
      final recomposed = HangulEngine.composeAll(jamos);
      expect(recomposed, equals(words));
    });
  });
}

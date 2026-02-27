import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/engines/hangul_engine.dart';
import 'package:fangeul/core/engines/hangul_tables.dart';

void main() {
  group('HangulTables — doubleFinalSplit', () {
    test('should contain all 11 double finals', () {
      expect(HangulTables.doubleFinalSplit.length, equals(11));
    });

    test('should split ㄳ into [ㄱ, ㅅ]', () {
      expect(HangulTables.doubleFinalSplit['ㄳ'], equals(['ㄱ', 'ㅅ']));
    });

    test('should split ㅀ into [ㄹ, ㅎ]', () {
      expect(HangulTables.doubleFinalSplit['ㅀ'], equals(['ㄹ', 'ㅎ']));
    });
  });

  group('HangulTables — doubleFinalCombine', () {
    test('should be inverse of doubleFinalSplit', () {
      for (final entry in HangulTables.doubleFinalSplit.entries) {
        final first = entry.value[0];
        final second = entry.value[1];
        expect(
          HangulTables.doubleFinalCombine[first]?[second],
          equals(entry.key),
        );
      }
    });
  });

  group('HangulTables — compoundVowelCombine', () {
    test('should combine ㅗ+ㅏ into ㅘ', () {
      expect(HangulTables.compoundVowelCombine['ㅗ']?['ㅏ'], equals('ㅘ'));
    });

    test('should combine ㅡ+ㅣ into ㅢ', () {
      expect(HangulTables.compoundVowelCombine['ㅡ']?['ㅣ'], equals('ㅢ'));
    });
  });

  group('HangulTables — compoundVowelSplit', () {
    test('should contain all 7 compound vowels', () {
      expect(HangulTables.compoundVowelSplit.length, equals(7));
    });

    test('should split ㅘ into [ㅗ, ㅏ]', () {
      expect(HangulTables.compoundVowelSplit['ㅘ'], equals(['ㅗ', 'ㅏ']));
    });

    test('should be inverse of compoundVowelCombine', () {
      for (final entry in HangulTables.compoundVowelSplit.entries) {
        final first = entry.value[0];
        final second = entry.value[1];
        expect(
          HangulTables.compoundVowelCombine[first]?[second],
          equals(entry.key),
        );
      }
    });
  });

  group('HangulTables — finalConsonantIndex', () {
    test('should contain 27 entries (excluding empty final)', () {
      expect(HangulTables.finalConsonantIndex.length, equals(27));
    });

    test('should match HangulEngine.finals indices', () {
      for (var i = 1; i < HangulEngine.finals.length; i++) {
        expect(
          HangulTables.finalConsonantIndex[HangulEngine.finals[i]],
          equals(i),
        );
      }
    });
  });
}

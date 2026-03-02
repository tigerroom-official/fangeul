import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/presentation/providers/template_phrase_provider.dart';

void main() {
  group('Template filtering', () {
    test('should not include template phrases in tag-filtered results', () {
      final phrases = [
        const Phrase(
          ko: '사랑해요',
          roman: 'saranghaeyo',
          context: 'love',
          tags: ['love'],
          translations: {'en': 'I love you'},
          situation: 'daily',
        ),
        const Phrase(
          ko: '{{group_name}} 사랑해요!',
          roman: '{{group_name}} saranghaeyo!',
          context: 'template',
          tags: ['love'],
          translations: {'en': 'I love {{group_name}}!'},
          situation: 'daily',
          isTemplate: true,
        ),
      ];

      final filtered = phrases.where((p) => !p.isTemplate).toList();
      expect(filtered.length, 1);
      expect(filtered.first.ko, '사랑해요');
      expect(filtered.any((p) => p.ko.contains('{{group_name}}')), isFalse);
    });
  });

  group('PhrasesScreen filter sentinel logic', () {
    // Test the filter resolution logic used in PhrasesScreen.build()
    // These are pure logic tests, not widget tests.

    bool isMyIdolSelected(String? selectedTag, bool hasIdol) {
      return selectedTag == '__my_idol__' || (selectedTag == null && hasIdol);
    }

    bool isAllSelected(String? selectedTag, bool hasIdol) {
      return selectedTag == '__all__' || (selectedTag == null && !hasIdol);
    }

    test('should default to myIdol when idol is set and tag is null', () {
      expect(isMyIdolSelected(null, true), isTrue);
      expect(isAllSelected(null, true), isFalse);
    });

    test('should default to all when idol is not set and tag is null', () {
      expect(isMyIdolSelected(null, false), isFalse);
      expect(isAllSelected(null, false), isTrue);
    });

    test('should select myIdol when sentinel is __my_idol__', () {
      expect(isMyIdolSelected('__my_idol__', true), isTrue);
      expect(isMyIdolSelected('__my_idol__', false), isTrue);
      expect(isAllSelected('__my_idol__', true), isFalse);
    });

    test('should select all when sentinel is __all__', () {
      expect(isAllSelected('__all__', true), isTrue);
      expect(isAllSelected('__all__', false), isTrue);
      expect(isMyIdolSelected('__all__', true), isFalse);
    });

    test('should select tag when a tag string is provided', () {
      expect(isMyIdolSelected('love', true), isFalse);
      expect(isAllSelected('love', true), isFalse);
      expect(isMyIdolSelected('love', false), isFalse);
      expect(isAllSelected('love', false), isFalse);
    });

    test('should resolve explicit 전체 correctly for idol user', () {
      // When idol user explicitly taps "전체", store __all__ not null
      // null would resolve back to myIdol
      expect(isMyIdolSelected('__all__', true), isFalse);
      expect(isAllSelected('__all__', true), isTrue);
    });
  });

  group('PhrasesScreen template resolution', () {
    test('should resolve template phrases with idol name', () {
      const phrase = Phrase(
        ko: '{{group_name}} 사랑해요!',
        roman: '{{group_name}} saranghaeyo!',
        context: 'template',
        tags: ['love'],
        translations: {'en': 'I love {{group_name}}!'},
        situation: 'daily',
        isTemplate: true,
      );

      final resolved = resolveTemplatePhrase(phrase, 'DaySix');
      expect(resolved.ko, 'DaySix 사랑해요!');
      expect(resolved.roman, 'DaySix saranghaeyo!');
      expect(resolved.translations['en'], 'I love DaySix!');
      expect(resolved.ko.contains('{{group_name}}'), isFalse);
    });

    test('should return original phrase when not a template', () {
      const phrase = Phrase(
        ko: '사랑해요',
        roman: 'saranghaeyo',
        context: 'love',
        tags: ['love'],
        translations: {'en': 'I love you'},
        situation: 'daily',
      );

      final result = resolveTemplatePhrase(phrase, 'DaySix');
      expect(result.ko, '사랑해요');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/presentation/providers/template_phrase_provider.dart';

void main() {
  group('resolveTemplatePhrases', () {
    test('should replace {{group_name}} with idol name', () {
      final phrase = Phrase(
        ko: '{{group_name}} 사랑해요!',
        roman: '{{group_name}} saranghaeyo!',
        context: 'Template love',
        isTemplate: true,
      );

      final resolved = resolveTemplatePhrase(phrase, 'BTS');
      expect(resolved.ko, 'BTS 사랑해요!');
      expect(resolved.roman, 'BTS saranghaeyo!');
      expect(resolved.isTemplate, true); // 유지
    });

    test('should replace in translations too', () {
      final phrase = Phrase(
        ko: '{{group_name}} 화이팅!',
        roman: '{{group_name}} hwaiting!',
        context: 'Template',
        translations: {'en': 'Go {{group_name}}!'},
        isTemplate: true,
      );

      final resolved = resolveTemplatePhrase(phrase, 'TWICE');
      expect(resolved.translations['en'], 'Go TWICE!');
    });

    test('should not modify non-template phrases', () {
      final phrase = Phrase(
        ko: '사랑해요',
        roman: 'saranghaeyo',
        context: 'Love',
        isTemplate: false,
      );

      final resolved = resolveTemplatePhrase(phrase, 'BTS');
      expect(resolved.ko, '사랑해요'); // 변경 없음
    });

    test('should filter template phrases when idol is null', () {
      final phrases = [
        Phrase(ko: '사랑해요', roman: 'saranghaeyo', context: 'A'),
        Phrase(
          ko: '{{group_name}} 화이팅!',
          roman: '',
          context: 'B',
          isTemplate: true,
        ),
      ];

      final filtered = filterAndResolveTemplates(phrases, null);
      expect(filtered, hasLength(1));
      expect(filtered.first.ko, '사랑해요');
    });

    test('should resolve template phrases when idol is set', () {
      final phrases = [
        Phrase(ko: '사랑해요', roman: 'saranghaeyo', context: 'A'),
        Phrase(
          ko: '{{group_name}} 화이팅!',
          roman: '{{group_name}} hwaiting!',
          context: 'B',
          isTemplate: true,
        ),
      ];

      final resolved = filterAndResolveTemplates(phrases, 'BTS');
      expect(resolved, hasLength(2));
      expect(resolved[1].ko, 'BTS 화이팅!');
    });
  });
}

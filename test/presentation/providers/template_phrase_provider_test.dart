import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/core/entities/phrase_pack.dart';
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

  group('member name support', () {
    test('should replace {{member_name}} with member name', () {
      final phrase = Phrase(
        ko: '{{member_name}} 생일 축하해요!',
        roman: '{{member_name}} saengil chukahaeyo!',
        context: 'Birthday member template',
        translations: {'en': 'Happy birthday {{member_name}}!'},
        isTemplate: true,
      );

      final resolved = resolveTemplatePhrase(
        phrase,
        'BTS',
        memberName: 'Jimin',
      );
      expect(resolved.ko, 'Jimin 생일 축하해요!');
      expect(resolved.roman, 'Jimin saengil chukahaeyo!');
      expect(resolved.translations['en'], 'Happy birthday Jimin!');
    });

    test('should replace both {{group_name}} and {{member_name}}', () {
      final phrase = Phrase(
        ko: '{{group_name}} {{member_name}} 사랑해요!',
        roman: '{{group_name}} {{member_name}} saranghaeyo!',
        context: 'Dual template',
        translations: {
          'en': 'I love {{group_name}} {{member_name}}!',
          'ja': '{{group_name}}の{{member_name}}大好き!',
        },
        isTemplate: true,
      );

      final resolved = resolveTemplatePhrase(
        phrase,
        'TWICE',
        memberName: 'Nayeon',
      );
      expect(resolved.ko, 'TWICE Nayeon 사랑해요!');
      expect(resolved.roman, 'TWICE Nayeon saranghaeyo!');
      expect(resolved.translations['en'], 'I love TWICE Nayeon!');
      expect(resolved.translations['ja'], 'TWICEのNayeon大好き!');
    });

    test('should not replace {{member_name}} when memberName is null', () {
      final phrase = Phrase(
        ko: '{{group_name}} {{member_name}} 화이팅!',
        roman: '{{group_name}} {{member_name}} hwaiting!',
        context: 'Dual template',
        isTemplate: true,
      );

      final resolved = resolveTemplatePhrase(phrase, 'BTS');
      expect(resolved.ko, 'BTS {{member_name}} 화이팅!');
      expect(resolved.roman, 'BTS {{member_name}} hwaiting!');
    });
  });

  group('needsMemberName', () {
    test('should return true for member template', () {
      final phrase = Phrase(
        ko: '{{member_name}} 최고!',
        roman: '',
        context: 'Member template',
        isTemplate: true,
      );

      expect(needsMemberName(phrase), isTrue);
    });

    test('should return false for group-only template', () {
      final phrase = Phrase(
        ko: '{{group_name}} 화이팅!',
        roman: '',
        context: 'Group template',
        isTemplate: true,
      );

      expect(needsMemberName(phrase), isFalse);
    });

    test('should return false for non-template', () {
      final phrase = Phrase(
        ko: '사랑해요',
        roman: 'saranghaeyo',
        context: 'Plain phrase',
      );

      expect(needsMemberName(phrase), isFalse);
    });

    test('should return false for non-template containing slot literal', () {
      final phrase = Phrase(
        ko: '템플릿 예시: {{member_name}}',
        roman: '',
        context: 'Explainer',
        isTemplate: false,
      );

      expect(needsMemberName(phrase), isFalse);
    });
  });

  group('collectAndResolveTemplates', () {
    final testPacks = [
      PhrasePack(
        id: 'basic',
        name: 'Basic',
        nameKo: '기본',
        phrases: [
          const Phrase(ko: '사랑해요', roman: 'saranghaeyo', context: 'A'),
          const Phrase(
            ko: '{{group_name}} 화이팅!',
            roman: '{{group_name}} hwaiting!',
            context: 'Group template',
            isTemplate: true,
          ),
          const Phrase(
            ko: '{{member_name}} 최고!',
            roman: '{{member_name}} choego!',
            context: 'Member template',
            isTemplate: true,
          ),
          const Phrase(
            ko: '{{group_name}} {{member_name}} 사랑해!',
            roman: '{{group_name}} {{member_name}} saranghae!',
            context: 'Dual template',
            isTemplate: true,
          ),
        ],
      ),
    ];

    test('should collect only group templates when memberName is null', () {
      final result = collectAndResolveTemplates(testPacks, 'BTS');
      expect(result, hasLength(1));
      expect(result[0].ko, 'BTS 화이팅!');
    });

    test('should collect all templates when memberName is set', () {
      final result = collectAndResolveTemplates(
        testPacks,
        'BTS',
        memberName: '정국',
      );
      expect(result, hasLength(3));
    });

    test('should put member templates first when memberFirst is true', () {
      final result = collectAndResolveTemplates(
        testPacks,
        'BTS',
        memberName: '정국',
        memberFirst: true,
      );
      expect(result, hasLength(3));
      // 멤버 전용 2개 먼저
      expect(result[0].ko, '정국 최고!');
      expect(result[1].ko, 'BTS 정국 사랑해!');
      // 그룹 전용 1개 뒤에
      expect(result[2].ko, 'BTS 화이팅!');
    });

    test('should not reorder when memberFirst is false', () {
      final result = collectAndResolveTemplates(
        testPacks,
        'BTS',
        memberName: '정국',
        memberFirst: false,
      );
      expect(result, hasLength(3));
      // 원본 순서 유지: group → member → dual
      expect(result[0].ko, 'BTS 화이팅!');
      expect(result[1].ko, '정국 최고!');
      expect(result[2].ko, 'BTS 정국 사랑해!');
    });

    test('should ignore memberFirst when memberName is null', () {
      final result = collectAndResolveTemplates(
        testPacks,
        'BTS',
        memberFirst: true,
      );
      // memberName null → 멤버 템플릿 제외, memberFirst 무시
      expect(result, hasLength(1));
      expect(result[0].ko, 'BTS 화이팅!');
    });
  });

  group('filterAndResolveTemplates member support', () {
    test('should filter member templates when memberName is null', () {
      final phrases = [
        Phrase(ko: '사랑해요', roman: 'saranghaeyo', context: 'A'),
        Phrase(
          ko: '{{group_name}} 화이팅!',
          roman: '{{group_name}} hwaiting!',
          context: 'B',
          isTemplate: true,
        ),
        Phrase(
          ko: '{{member_name}} 생일 축하해!',
          roman: '{{member_name}} saengil chukahae!',
          context: 'C',
          isTemplate: true,
        ),
      ];

      final resolved = filterAndResolveTemplates(phrases, 'BTS');
      expect(resolved, hasLength(2));
      expect(resolved[0].ko, '사랑해요');
      expect(resolved[1].ko, 'BTS 화이팅!');
    });

    test('should include member templates when memberName is set', () {
      final phrases = [
        Phrase(ko: '사랑해요', roman: 'saranghaeyo', context: 'A'),
        Phrase(
          ko: '{{group_name}} 화이팅!',
          roman: '{{group_name}} hwaiting!',
          context: 'B',
          isTemplate: true,
        ),
        Phrase(
          ko: '{{member_name}} 생일 축하해!',
          roman: '{{member_name}} saengil chukahae!',
          context: 'C',
          isTemplate: true,
        ),
      ];

      final resolved = filterAndResolveTemplates(
        phrases,
        'BTS',
        memberName: 'V',
      );
      expect(resolved, hasLength(3));
      expect(resolved[0].ko, '사랑해요');
      expect(resolved[1].ko, 'BTS 화이팅!');
      expect(resolved[2].ko, 'V 생일 축하해!');
    });
  });
}

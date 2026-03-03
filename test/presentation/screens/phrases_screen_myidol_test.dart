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

  group('PhrasesScreen filter sentinel logic — with member', () {
    // Updated filter logic: member takes priority over idol on default (null tag).
    bool isMemberSelected(String? selectedTag, bool hasMember) {
      return selectedTag == '__my_member__' ||
          (selectedTag == null && hasMember);
    }

    bool isMyIdolSelected(String? selectedTag, bool hasIdol, bool hasMember) {
      return selectedTag == '__my_idol__' ||
          (selectedTag == null && hasIdol && !hasMember);
    }

    bool isAllSelected(String? selectedTag, bool hasIdol) {
      return selectedTag == '__all__' || (selectedTag == null && !hasIdol);
    }

    test('should default to member when member is set and tag is null', () {
      expect(isMemberSelected(null, true), isTrue);
      expect(isMyIdolSelected(null, true, true), isFalse);
      expect(isAllSelected(null, true), isFalse);
    });

    test('should default to idol when idol set but no member', () {
      expect(isMemberSelected(null, false), isFalse);
      expect(isMyIdolSelected(null, true, false), isTrue);
      expect(isAllSelected(null, true), isFalse);
    });

    test('should select member when sentinel is __my_member__', () {
      expect(isMemberSelected('__my_member__', true), isTrue);
      expect(isMemberSelected('__my_member__', false), isTrue);
      expect(isMyIdolSelected('__my_member__', true, true), isFalse);
    });

    test('should select idol when sentinel is __my_idol__ even with member',
        () {
      expect(isMyIdolSelected('__my_idol__', true, true), isTrue);
      expect(isMemberSelected('__my_idol__', true), isFalse);
    });

    test('should not select member when tag is a regular tag', () {
      expect(isMemberSelected('love', true), isFalse);
      expect(isMyIdolSelected('love', true, true), isFalse);
      expect(isAllSelected('love', true), isFalse);
    });
  });

  group('PhrasesScreen member template filtering', () {
    test('should filter member-only templates from group view', () {
      final phrases = [
        const Phrase(
          ko: '{{group_name}} 사랑해요!',
          roman: '{{group_name}} saranghaeyo!',
          context: 'template',
          tags: ['love'],
          translations: {'en': 'I love {{group_name}}!'},
          situation: 'daily',
          isTemplate: true,
        ),
        const Phrase(
          ko: '{{member_name}}아 생일 축하해!',
          roman: '{{member_name}}a saengil chukhahae!',
          context: 'template',
          tags: ['birthday'],
          translations: {'en': 'Happy birthday {{member_name}}!'},
          situation: 'birthday',
          isTemplate: true,
        ),
      ];

      // When member is set, group view should exclude member templates
      final groupOnly = phrases
          .where((p) => p.isTemplate)
          .where((p) => !needsMemberName(p))
          .toList();
      expect(groupOnly.length, 1);
      expect(groupOnly.first.ko, contains('{{group_name}}'));
    });

    test('should include only member templates in member view', () {
      final phrases = [
        const Phrase(
          ko: '{{group_name}} 사랑해요!',
          roman: '{{group_name}} saranghaeyo!',
          context: 'template',
          tags: ['love'],
          translations: {'en': 'I love {{group_name}}!'},
          situation: 'daily',
          isTemplate: true,
        ),
        const Phrase(
          ko: '{{member_name}}아 생일 축하해!',
          roman: '{{member_name}}a saengil chukhahae!',
          context: 'template',
          tags: ['birthday'],
          translations: {'en': 'Happy birthday {{member_name}}!'},
          situation: 'birthday',
          isTemplate: true,
        ),
      ];

      // Member view: only templates that need member_name
      final memberOnly = phrases
          .where((p) => p.isTemplate && needsMemberName(p))
          .map((p) => resolveTemplatePhrase(p, 'BTS', memberName: '정국'))
          .toList();
      expect(memberOnly.length, 1);
      expect(memberOnly.first.ko, '정국아 생일 축하해!');
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

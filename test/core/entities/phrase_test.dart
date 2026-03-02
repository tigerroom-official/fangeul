import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/core/entities/phrase_pack.dart';

void main() {
  group('Phrase', () {
    test('should create from JSON with all fields', () {
      final json = {
        'ko': '사랑해요',
        'roman': 'saranghaeyo',
        'context': 'General love expression',
        'tags': ['love', 'daily'],
        'translations': {'en': 'I love you', 'id': 'Aku cinta kamu'},
      };

      final phrase = Phrase.fromJson(json);

      expect(phrase.ko, '사랑해요');
      expect(phrase.roman, 'saranghaeyo');
      expect(phrase.context, 'General love expression');
      expect(phrase.tags, ['love', 'daily']);
      expect(phrase.translations['en'], 'I love you');
      expect(phrase.translations['id'], 'Aku cinta kamu');
    });

    test('should parse situation field from JSON', () {
      final json = {
        'ko': '생일 축하해요!',
        'roman': 'saengil chukahaeyo!',
        'context': 'Happy birthday',
        'tags': ['birthday'],
        'situation': 'birthday',
      };

      final phrase = Phrase.fromJson(json);

      expect(phrase.situation, 'birthday');
    });

    test('should use default values for optional fields', () {
      final json = {
        'ko': '사랑해요',
        'roman': 'saranghaeyo',
        'context': 'test',
      };

      final phrase = Phrase.fromJson(json);

      expect(phrase.tags, isEmpty);
      expect(phrase.translations, isEmpty);
      expect(phrase.situation, isNull);
    });

    test('should round-trip through JSON', () {
      final original = const Phrase(
        ko: '화이팅!',
        roman: 'hwaiting!',
        context: 'Encouragement',
        tags: ['cheer'],
        translations: {'en': 'Fighting!'},
      );

      final json = original.toJson();
      final restored = Phrase.fromJson(json);

      expect(restored, original);
    });

    test('should parse isTemplate field from JSON', () {
      final json = {
        'ko': '{{group_name}} 컴백 축하해요!',
        'roman': '{{group_name}} keombaek chukahaeyo!',
        'context': 'Template: comeback congratulations',
        'tags': ['comeback'],
        'translations': {'en': 'Congratulations on {{group_name}} comeback!'},
        'situation': 'comeback',
        'is_template': true,
      };
      final phrase = Phrase.fromJson(json);
      expect(phrase.isTemplate, true);
      expect(phrase.ko, contains('{{group_name}}'));
    });

    test('should default isTemplate to false', () {
      final json = {
        'ko': '사랑해요',
        'roman': 'saranghaeyo',
        'context': 'Love',
        'tags': <String>[],
        'translations': <String, String>{},
      };
      final phrase = Phrase.fromJson(json);
      expect(phrase.isTemplate, false);
    });

    test('should serialize to snake_case JSON', () {
      const phrase = Phrase(
        ko: '사랑해요',
        roman: 'saranghaeyo',
        context: 'test',
      );

      final json = phrase.toJson();
      // build.yaml에서 field_rename: snake 설정
      expect(json.containsKey('ko'), isTrue);
      expect(json.containsKey('roman'), isTrue);
      expect(json.containsKey('context'), isTrue);
    });
  });

  group('PhrasePack', () {
    test('should create from JSON with all fields', () {
      final json = {
        'id': 'basic_love',
        'name': 'Love & Support',
        'name_ko': '사랑 & 응원',
        'is_free': true,
        'phrases': [
          {
            'ko': '사랑해요',
            'roman': 'saranghaeyo',
            'context': 'test',
          },
        ],
      };

      final pack = PhrasePack.fromJson(json);

      expect(pack.id, 'basic_love');
      expect(pack.name, 'Love & Support');
      expect(pack.nameKo, '사랑 & 응원');
      expect(pack.isFree, isTrue);
      expect(pack.unlockType, isNull);
      expect(pack.phrases, hasLength(1));
      expect(pack.phrases.first.ko, '사랑해요');
    });

    test('should handle paid pack with unlock_type', () {
      final json = {
        'id': 'birthday_pack',
        'name': 'Birthday Messages',
        'name_ko': '생일 축하',
        'is_free': false,
        'unlock_type': 'rewarded_ad',
        'phrases': [],
      };

      final pack = PhrasePack.fromJson(json);

      expect(pack.isFree, isFalse);
      expect(pack.unlockType, 'rewarded_ad');
    });

    test('should use default values for optional fields', () {
      final json = {
        'id': 'test',
        'name': 'Test',
        'name_ko': '테스트',
      };

      final pack = PhrasePack.fromJson(json);

      expect(pack.isFree, isTrue);
      expect(pack.unlockType, isNull);
      expect(pack.phrases, isEmpty);
    });

    test('should round-trip through JSON', () {
      final original = const PhrasePack(
        id: 'test_pack',
        name: 'Test Pack',
        nameKo: '테스트 팩',
        isFree: false,
        unlockType: 'rewarded_ad',
        phrases: [
          Phrase(ko: '테스트', roman: 'teseuteu', context: 'test'),
        ],
      );

      // 완전한 JSON 왕복: toJson → jsonEncode → jsonDecode → fromJson
      final jsonStr = jsonEncode(original.toJson());
      final restored =
          PhrasePack.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);

      expect(restored, original);
    });

    test('should deserialize name_ko from snake_case', () {
      final jsonStr = '{"id":"test","name":"Test","name_ko":"테스트"}';
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final pack = PhrasePack.fromJson(json);

      expect(pack.nameKo, '테스트');
    });
  });
}

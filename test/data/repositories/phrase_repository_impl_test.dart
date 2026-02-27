import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/data/datasources/phrase_local_datasource.dart';
import 'package:fangeul/data/repositories/phrase_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PhraseRepositoryImpl repository;
  late PhraseLocalDataSource dataSource;

  final testPackJson = jsonEncode({
    'id': 'test_pack',
    'name': 'Test Pack',
    'name_ko': '테스트 팩',
    'is_free': true,
    'phrases': [
      {
        'ko': '사랑해요',
        'roman': 'saranghaeyo',
        'context': 'Love',
        'tags': ['love'],
        'translations': {'en': 'I love you'},
      },
      {
        'ko': '화이팅!',
        'roman': 'hwaiting!',
        'context': 'Cheer',
        'tags': ['cheer'],
        'translations': {'en': 'Fighting!'},
      },
    ],
  });

  setUp(() {
    // TestDefaultBinaryMessenger를 사용하여 에셋 번들을 모킹
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      final key = utf8.decode(message!.buffer.asUint8List());
      if (key.contains('basic_love') ||
          key.contains('birthday_pack') ||
          key.contains('comeback_pack') ||
          key.contains('daily_pack')) {
        return ByteData.sublistView(utf8.encode(testPackJson));
      }
      return null;
    });

    dataSource = PhraseLocalDataSource();
    repository = PhraseRepositoryImpl(dataSource);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  group('PhraseRepositoryImpl', () {
    test('should load all packs via getAllPacks', () async {
      final packs = await repository.getAllPacks();

      expect(packs, isNotEmpty);
      expect(packs.first.id, 'test_pack');
      expect(packs.first.phrases, hasLength(2));
    });

    test('should return phrases with correct data', () async {
      final packs = await repository.getAllPacks();
      final phrase = packs.first.phrases.first;

      expect(phrase.ko, '사랑해요');
      expect(phrase.roman, 'saranghaeyo');
      expect(phrase.tags, ['love']);
      expect(phrase.translations['en'], 'I love you');
    });

    test('should cache packs after first load', () async {
      final packs1 = await repository.getAllPacks();
      final packs2 = await repository.getAllPacks();

      expect(packs1.length, packs2.length);
    });
  });
}

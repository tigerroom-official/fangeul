import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/core/entities/phrase_pack.dart';
import 'package:fangeul/core/repositories/phrase_repository.dart';
import 'package:fangeul/core/usecases/get_phrases_usecase.dart';
import 'package:fangeul/core/usecases/get_phrases_by_tag_usecase.dart';

class MockPhraseRepository extends Mock implements PhraseRepository {}

void main() {
  late MockPhraseRepository mockRepository;
  late GetPhrasesUseCase getPhrasesUseCase;
  late GetPhrasesByTagUseCase getPhrasesByTagUseCase;

  setUp(() {
    mockRepository = MockPhraseRepository();
    getPhrasesUseCase = GetPhrasesUseCase(mockRepository);
    getPhrasesByTagUseCase = GetPhrasesByTagUseCase(mockRepository);
  });

  final testPacks = [
    const PhrasePack(
      id: 'basic_love',
      name: 'Love & Support',
      nameKo: '사랑 & 응원',
      phrases: [
        Phrase(
          ko: '사랑해요',
          roman: 'saranghaeyo',
          context: 'Love',
          tags: ['love', 'daily'],
        ),
        Phrase(
          ko: '화이팅!',
          roman: 'hwaiting!',
          context: 'Encouragement',
          tags: ['cheer'],
        ),
      ],
    ),
    const PhrasePack(
      id: 'daily_pack',
      name: 'Daily',
      nameKo: '일상',
      phrases: [
        Phrase(
          ko: '안녕하세요',
          roman: 'annyeonghaseyo',
          context: 'Greeting',
          tags: ['greeting', 'daily'],
        ),
      ],
    ),
  ];

  group('GetPhrasesUseCase', () {
    test('should return all packs from repository', () async {
      when(() => mockRepository.getAllPacks())
          .thenAnswer((_) async => testPacks);

      final result = await getPhrasesUseCase.execute();

      expect(result, hasLength(2));
      expect(result[0].id, 'basic_love');
      expect(result[1].id, 'daily_pack');
      verify(() => mockRepository.getAllPacks()).called(1);
    });

    test('should return empty list when no packs exist', () async {
      when(() => mockRepository.getAllPacks()).thenAnswer((_) async => []);

      final result = await getPhrasesUseCase.execute();

      expect(result, isEmpty);
    });
  });

  group('GetPhrasesByTagUseCase', () {
    test('should return phrases matching tag across all packs', () async {
      when(() => mockRepository.getAllPacks())
          .thenAnswer((_) async => testPacks);

      final result = await getPhrasesByTagUseCase.execute('daily');

      expect(result, hasLength(2));
      expect(result[0].ko, '사랑해요');
      expect(result[1].ko, '안녕하세요');
    });

    test('should return empty list when no phrases match tag', () async {
      when(() => mockRepository.getAllPacks())
          .thenAnswer((_) async => testPacks);

      final result = await getPhrasesByTagUseCase.execute('birthday');

      expect(result, isEmpty);
    });

    test('should return phrases only from matching tag', () async {
      when(() => mockRepository.getAllPacks())
          .thenAnswer((_) async => testPacks);

      final result = await getPhrasesByTagUseCase.execute('cheer');

      expect(result, hasLength(1));
      expect(result.first.ko, '화이팅!');
    });
  });
}

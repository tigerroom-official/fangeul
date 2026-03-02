import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/core/entities/phrase_pack.dart';
import 'package:fangeul/core/repositories/phrase_repository.dart';
import 'package:fangeul/core/usecases/get_phrases_by_situation_usecase.dart';

class MockPhraseRepository extends Mock implements PhraseRepository {}

void main() {
  late MockPhraseRepository mockRepository;
  late GetPhrasesBySituationUseCase useCase;

  setUp(() {
    mockRepository = MockPhraseRepository();
    useCase = GetPhrasesBySituationUseCase(mockRepository);
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
          situation: 'daily',
        ),
        Phrase(
          ko: '힘내세요!',
          roman: 'himnaeseyo!',
          context: 'Encouragement',
          tags: ['cheer'],
          situation: 'support',
        ),
      ],
    ),
    const PhrasePack(
      id: 'birthday_pack',
      name: 'Birthday',
      nameKo: '생일',
      phrases: [
        Phrase(
          ko: '생일 축하해요!',
          roman: 'saengil chukahaeyo!',
          context: 'Happy birthday',
          tags: ['birthday'],
          situation: 'birthday',
        ),
      ],
    ),
    const PhrasePack(
      id: 'mixed',
      name: 'Mixed',
      nameKo: '혼합',
      phrases: [
        Phrase(
          ko: '노래 좋아요',
          roman: 'norae joayo',
          context: 'Praise',
          tags: ['praise'],
          // situation is null
        ),
      ],
    ),
  ];

  group('GetPhrasesBySituationUseCase', () {
    test('should return phrases matching situation across all packs', () async {
      when(() => mockRepository.getAllPacks())
          .thenAnswer((_) async => testPacks);

      final result = await useCase.execute('daily');

      expect(result, hasLength(1));
      expect(result.first.ko, '사랑해요');
    });

    test('should return birthday phrases from birthday pack', () async {
      when(() => mockRepository.getAllPacks())
          .thenAnswer((_) async => testPacks);

      final result = await useCase.execute('birthday');

      expect(result, hasLength(1));
      expect(result.first.ko, '생일 축하해요!');
    });

    test('should return support phrases only', () async {
      when(() => mockRepository.getAllPacks())
          .thenAnswer((_) async => testPacks);

      final result = await useCase.execute('support');

      expect(result, hasLength(1));
      expect(result.first.ko, '힘내세요!');
    });

    test('should return empty list when no phrases match situation', () async {
      when(() => mockRepository.getAllPacks())
          .thenAnswer((_) async => testPacks);

      final result = await useCase.execute('concert');

      expect(result, isEmpty);
    });

    test('should exclude phrases with null situation', () async {
      when(() => mockRepository.getAllPacks())
          .thenAnswer((_) async => testPacks);

      // "노래 좋아요" has null situation, should not appear in any filter
      final daily = await useCase.execute('daily');
      final support = await useCase.execute('support');
      final birthday = await useCase.execute('birthday');

      final allResults = [...daily, ...support, ...birthday];
      expect(
        allResults.every((p) => p.ko != '노래 좋아요'),
        isTrue,
      );
    });

    test('should return empty list when repository has no packs', () async {
      when(() => mockRepository.getAllPacks()).thenAnswer((_) async => []);

      final result = await useCase.execute('daily');

      expect(result, isEmpty);
    });
  });
}

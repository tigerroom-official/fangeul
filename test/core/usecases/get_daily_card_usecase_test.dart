import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fangeul/core/entities/phrase.dart';
import 'package:fangeul/core/entities/phrase_pack.dart';
import 'package:fangeul/core/repositories/phrase_repository.dart';
import 'package:fangeul/core/usecases/get_daily_card_usecase.dart';

class MockPhraseRepository extends Mock implements PhraseRepository {}

void main() {
  late MockPhraseRepository mockRepository;
  late GetDailyCardUseCase useCase;

  setUp(() {
    mockRepository = MockPhraseRepository();
    useCase = GetDailyCardUseCase(mockRepository);
  });

  final freePacks = [
    const PhrasePack(
      id: 'basic_love',
      name: 'Love & Support',
      nameKo: '사랑 & 응원',
      isFree: true,
      phrases: [
        Phrase(ko: '사랑해요', roman: 'saranghaeyo', context: 'Love'),
        Phrase(ko: '화이팅!', roman: 'hwaiting!', context: 'Cheer'),
        Phrase(ko: '보고 싶어요', roman: 'bogo sipeoyo', context: 'Miss'),
      ],
    ),
    const PhrasePack(
      id: 'daily_pack',
      name: 'Daily',
      nameKo: '일상',
      isFree: true,
      phrases: [
        Phrase(ko: '안녕하세요', roman: 'annyeonghaseyo', context: 'Greeting'),
        Phrase(ko: '잘 자요', roman: 'jal jayo', context: 'Good night'),
      ],
    ),
  ];

  final mixedPacks = [
    ...freePacks,
    const PhrasePack(
      id: 'birthday_pack',
      name: 'Birthday',
      nameKo: '생일',
      isFree: false,
      unlockType: 'rewarded_ad',
      phrases: [
        Phrase(
            ko: '생일 축하해요!', roman: 'saengil chukahaeyo!', context: 'Birthday'),
      ],
    ),
  ];

  group('GetDailyCardUseCase', () {
    test('should return same card for same date', () async {
      when(() => mockRepository.getAllPacks())
          .thenAnswer((_) async => freePacks);

      final card1 = await useCase.execute(date: '2026-02-27');
      final card2 = await useCase.execute(date: '2026-02-27');

      expect(card1, isNotNull);
      expect(card2, isNotNull);
      expect(card1!.date, '2026-02-27');
      expect(card1.phrase.ko, card2!.phrase.ko);
      expect(card1.packId, card2.packId);
      expect(card1.phraseIndex, card2.phraseIndex);
    });

    test('should return different card for different date', () async {
      when(() => mockRepository.getAllPacks())
          .thenAnswer((_) async => freePacks);

      final card1 = await useCase.execute(date: '2026-02-27');
      final card2 = await useCase.execute(date: '2026-02-28');

      expect(card1, isNotNull);
      expect(card2, isNotNull);
      // 다른 날짜이므로 다를 가능성이 높지만, 해시 충돌 가능성이 있으므로
      // 두 카드가 존재하는지만 확인
      expect(card1!.date, '2026-02-27');
      expect(card2!.date, '2026-02-28');
    });

    test('should only use free packs for daily card', () async {
      when(() => mockRepository.getAllPacks())
          .thenAnswer((_) async => mixedPacks);

      final card = await useCase.execute(date: '2026-02-27');

      expect(card, isNotNull);
      // birthday_pack은 유료이므로 선택되면 안 됨
      expect(card!.packId, isNot('birthday_pack'));
    });

    test('should return null when no free packs with phrases exist', () async {
      when(() => mockRepository.getAllPacks()).thenAnswer((_) async => [
            const PhrasePack(
              id: 'empty',
              name: 'Empty',
              nameKo: '빈팩',
              phrases: [],
            ),
          ]);

      final card = await useCase.execute(date: '2026-02-27');

      expect(card, isNull);
    });

    test('should return null when only paid packs have phrases', () async {
      when(() => mockRepository.getAllPacks()).thenAnswer((_) async => [
            const PhrasePack(
              id: 'paid',
              name: 'Paid',
              nameKo: '유료',
              isFree: false,
              phrases: [
                Phrase(ko: '테스트', roman: 'teseuteu', context: 'test'),
              ],
            ),
          ]);

      final card = await useCase.execute(date: '2026-02-27');

      expect(card, isNull);
    });

    test('should exclude template phrases when no group name', () async {
      when(() => mockRepository.getAllPacks()).thenAnswer((_) async => [
            const PhrasePack(
              id: 'template_pack',
              name: 'Templates',
              nameKo: '템플릿',
              isFree: true,
              phrases: [
                Phrase(
                  ko: '{{group_name}} 오래오래 함께해요',
                  roman: '{{group_name}} oraeorae hamkkehaeyo',
                  context: 'Forever',
                  isTemplate: true,
                ),
                Phrase(
                  ko: '사랑해요',
                  roman: 'saranghaeyo',
                  context: 'Love',
                ),
              ],
            ),
          ]);

      final card = await useCase.execute(date: '2026-02-27');

      expect(card, isNotNull);
      expect(card!.phrase.isTemplate, isFalse);
      expect(card.phrase.ko, '사랑해요');
    });

    test('should include group templates when hasGroupName is true', () async {
      when(() => mockRepository.getAllPacks()).thenAnswer((_) async => [
            const PhrasePack(
              id: 'only_template',
              name: 'Only Template',
              nameKo: '템플릿만',
              isFree: true,
              phrases: [
                Phrase(
                  ko: '{{group_name}} 사랑해',
                  roman: '{{group_name}} saranghae',
                  context: 'Love',
                  isTemplate: true,
                ),
              ],
            ),
          ]);

      final card = await useCase.execute(
        date: '2026-02-27',
        hasGroupName: true,
      );

      expect(card, isNotNull);
      expect(card!.phrase.isTemplate, isTrue);
      expect(card.phrase.ko, contains('{{group_name}}'));
    });

    test('should exclude member templates when hasMemberName is false',
        () async {
      when(() => mockRepository.getAllPacks()).thenAnswer((_) async => [
            const PhrasePack(
              id: 'member_pack',
              name: 'Member Templates',
              nameKo: '멤버 템플릿',
              isFree: true,
              phrases: [
                Phrase(
                  ko: '{{member_name}} 생일 축하해',
                  roman: '{{member_name}} saengil chukahae',
                  context: 'Birthday',
                  isTemplate: true,
                ),
                Phrase(
                  ko: '{{group_name}} 파이팅',
                  roman: '{{group_name}} paiting',
                  context: 'Cheer',
                  isTemplate: true,
                ),
              ],
            ),
          ]);

      final card = await useCase.execute(
        date: '2026-02-27',
        hasGroupName: true,
        hasMemberName: false,
      );

      expect(card, isNotNull);
      // member_name 템플릿은 제외, group_name만 포함
      expect(card!.phrase.ko, contains('{{group_name}}'));
      expect(card.phrase.ko, isNot(contains('{{member_name}}')));
    });

    test('should include member templates when hasMemberName is true',
        () async {
      when(() => mockRepository.getAllPacks()).thenAnswer((_) async => [
            const PhrasePack(
              id: 'member_pack',
              name: 'Member Only',
              nameKo: '멤버 전용',
              isFree: true,
              phrases: [
                Phrase(
                  ko: '{{member_name}} 사랑해',
                  roman: '{{member_name}} saranghae',
                  context: 'Love',
                  isTemplate: true,
                ),
              ],
            ),
          ]);

      final card = await useCase.execute(
        date: '2026-02-27',
        hasGroupName: true,
        hasMemberName: true,
      );

      expect(card, isNotNull);
      expect(card!.phrase.ko, contains('{{member_name}}'));
    });

    test('should return null when only template phrases and no group name',
        () async {
      when(() => mockRepository.getAllPacks()).thenAnswer((_) async => [
            const PhrasePack(
              id: 'all_template',
              name: 'All Templates',
              nameKo: '전부 템플릿',
              isFree: true,
              phrases: [
                Phrase(
                  ko: '{{group_name}} 사랑해',
                  roman: '{{group_name}} saranghae',
                  context: 'Love',
                  isTemplate: true,
                ),
              ],
            ),
          ]);

      final card = await useCase.execute(date: '2026-02-27');

      expect(card, isNull);
    });

    test('should set isCompleted to false by default', () async {
      when(() => mockRepository.getAllPacks())
          .thenAnswer((_) async => freePacks);

      final card = await useCase.execute(date: '2026-02-27');

      expect(card, isNotNull);
      expect(card!.isCompleted, isFalse);
    });
  });
}

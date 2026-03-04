import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/core/repositories/monetization_repository.dart';
import 'package:fangeul/core/usecases/check_honeymoon_usecase.dart';

class MockMonetizationRepository extends Mock
    implements MonetizationRepository {}

void main() {
  late MockMonetizationRepository mockRepository;
  late CheckHoneymoonUseCase useCase;

  setUp(() {
    mockRepository = MockMonetizationRepository();
    useCase = CheckHoneymoonUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(const MonetizationState());
  });

  group('CheckHoneymoonUseCase', () {
    test('should set install date if null (first launch)', () async {
      when(() => mockRepository.load())
          .thenAnswer((_) async => const MonetizationState());
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      final now = DateTime(2026, 3, 1);
      final result = await useCase.execute(now: now);

      expect(result.installDate, '2026-03-01');
      expect(result.honeymoonActive, true);
      verify(() => mockRepository.save(any())).called(1);
    });

    test('should keep honeymoon active within 14 days (Day 3)', () async {
      final installDate = DateTime(2026, 3, 1);
      final now = installDate.add(const Duration(days: 3));

      when(() => mockRepository.load()).thenAnswer(
        (_) async => const MonetizationState(
          installDate: '2026-03-01',
          honeymoonActive: true,
        ),
      );

      final result = await useCase.execute(now: now);

      expect(result.honeymoonActive, true);
      expect(result.favoriteSlotLimit, 0);
      verifyNever(() => mockRepository.save(any()));
    });

    test(
        'should end honeymoon after Day 13 (Day 14+) — set honeymoonActive=false, favoriteSlotLimit=5',
        () async {
      final now = DateTime(2026, 3, 15); // Day 14

      when(() => mockRepository.load()).thenAnswer(
        (_) async => const MonetizationState(
          installDate: '2026-03-01',
          honeymoonActive: true,
        ),
      );
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      final result = await useCase.execute(now: now);

      expect(result.honeymoonActive, false);
      expect(result.favoriteSlotLimit, 5);
      verify(() => mockRepository.save(any())).called(1);
    });

    test('should not re-apply if already ended', () async {
      final now = DateTime(2026, 3, 15);

      when(() => mockRepository.load()).thenAnswer(
        (_) async => const MonetizationState(
          installDate: '2026-03-01',
          honeymoonActive: false,
          favoriteSlotLimit: 5,
        ),
      );

      final result = await useCase.execute(now: now);

      expect(result.honeymoonActive, false);
      expect(result.favoriteSlotLimit, 5);
      verifyNever(() => mockRepository.save(any()));
    });

    test('should keep honeymoon active on Day 0', () async {
      final now = DateTime(2026, 3, 1); // Same as install date

      when(() => mockRepository.load()).thenAnswer(
        (_) async => const MonetizationState(
          installDate: '2026-03-01',
          honeymoonActive: true,
        ),
      );

      final result = await useCase.execute(now: now);

      expect(result.honeymoonActive, true);
      expect(result.favoriteSlotLimit, 0);
      verifyNever(() => mockRepository.save(any()));
    });

    test('should keep honeymoon on Day 13 but end on Day 14', () async {
      when(() => mockRepository.load()).thenAnswer(
        (_) async => const MonetizationState(
          installDate: '2026-03-01',
          honeymoonActive: true,
        ),
      );
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Day 13 — still honeymoon
      final day13 = DateTime(2026, 3, 14);
      final result13 = await useCase.execute(now: day13);
      expect(result13.honeymoonActive, true);
      expect(result13.favoriteSlotLimit, 0);

      // Day 14 — honeymoon ends
      final day14 = DateTime(2026, 3, 15);
      final result14 = await useCase.execute(now: day14);
      expect(result14.honeymoonActive, false);
      expect(result14.favoriteSlotLimit, 5);
    });

    test('should use custom honeymoonDays when provided', () async {
      final fiveDaysLater = DateTime(2026, 3, 6); // Day 5

      when(() => mockRepository.load()).thenAnswer(
        (_) async => const MonetizationState(
          installDate: '2026-03-01',
          honeymoonActive: true,
        ),
      );
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      final customUseCase =
          CheckHoneymoonUseCase(mockRepository, honeymoonDays: 3);
      final result = await customUseCase.execute(now: fiveDaysLater);
      expect(result.honeymoonActive, false);
    });

    test('should use custom defaultSlotLimit when provided', () async {
      final fiveDaysLater = DateTime(2026, 3, 6); // Day 5

      when(() => mockRepository.load()).thenAnswer(
        (_) async => const MonetizationState(
          installDate: '2026-03-01',
          honeymoonActive: true,
        ),
      );
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      final customUseCase = CheckHoneymoonUseCase(
        mockRepository,
        honeymoonDays: 3,
        defaultSlotLimit: 10,
      );
      final result = await customUseCase.execute(now: fiveDaysLater);
      expect(result.favoriteSlotLimit, 10);
    });
  });
}

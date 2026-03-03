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

    test('should keep honeymoon active within 7 days (Day 3)', () async {
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

    test('should end honeymoon after Day 6 (Day 7+) — set honeymoonActive=false, favoriteSlotLimit=3',
        () async {
      final now = DateTime(2026, 3, 8); // Day 7

      when(() => mockRepository.load()).thenAnswer(
        (_) async => const MonetizationState(
          installDate: '2026-03-01',
          honeymoonActive: true,
        ),
      );
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      final result = await useCase.execute(now: now);

      expect(result.honeymoonActive, false);
      expect(result.favoriteSlotLimit, 3);
      verify(() => mockRepository.save(any())).called(1);
    });

    test('should not re-apply if already ended', () async {
      final now = DateTime(2026, 3, 15);

      when(() => mockRepository.load()).thenAnswer(
        (_) async => const MonetizationState(
          installDate: '2026-03-01',
          honeymoonActive: false,
          favoriteSlotLimit: 3,
        ),
      );

      final result = await useCase.execute(now: now);

      expect(result.honeymoonActive, false);
      expect(result.favoriteSlotLimit, 3);
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

    test('should keep honeymoon on Day 6 but end on Day 7', () async {
      when(() => mockRepository.load()).thenAnswer(
        (_) async => const MonetizationState(
          installDate: '2026-03-01',
          honeymoonActive: true,
        ),
      );
      when(() => mockRepository.save(any())).thenAnswer((_) async {});

      // Day 6 — still honeymoon
      final day6 = DateTime(2026, 3, 7);
      final result6 = await useCase.execute(now: day6);
      expect(result6.honeymoonActive, true);
      expect(result6.favoriteSlotLimit, 0);

      // Day 7 — honeymoon ends
      final day7 = DateTime(2026, 3, 8);
      final result7 = await useCase.execute(now: day7);
      expect(result7.honeymoonActive, false);
      expect(result7.favoriteSlotLimit, 3);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fangeul/core/entities/user_progress.dart';
import 'package:fangeul/core/repositories/user_progress_repository.dart';
import 'package:fangeul/core/usecases/update_streak_usecase.dart';

class MockUserProgressRepository extends Mock
    implements UserProgressRepository {}

void main() {
  late MockUserProgressRepository mockRepository;
  late UpdateStreakUseCase useCase;

  setUp(() {
    mockRepository = MockUserProgressRepository();
    useCase = UpdateStreakUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(const UserProgress());
  });

  group('UpdateStreakUseCase', () {
    test('should start streak at 1 for first use', () async {
      when(() => mockRepository.getProgress())
          .thenAnswer((_) async => const UserProgress());
      when(() => mockRepository.saveProgress(any())).thenAnswer((_) async {});

      final now = DateTime(2026, 2, 27, 10, 0);
      final result = await useCase.execute(now: now);

      expect(result.streak, 1);
      expect(result.totalStreakDays, 1);
      expect(result.lastCompletedDate, '2026-02-27');
      verify(() => mockRepository.saveProgress(any())).called(1);
    });

    test('should increment streak when completing consecutive day', () async {
      when(() => mockRepository.getProgress()).thenAnswer(
        (_) async => const UserProgress(
          streak: 3,
          totalStreakDays: 5,
          lastCompletedDate: '2026-02-26',
          lastTimestamp: 1000,
        ),
      );
      when(() => mockRepository.saveProgress(any())).thenAnswer((_) async {});

      final now = DateTime(2026, 2, 27, 10, 0);
      final result = await useCase.execute(now: now);

      expect(result.streak, 4);
      expect(result.totalStreakDays, 6);
      expect(result.lastCompletedDate, '2026-02-27');
    });

    test('should not update when completing same day twice', () async {
      when(() => mockRepository.getProgress()).thenAnswer(
        (_) async => const UserProgress(
          streak: 3,
          totalStreakDays: 5,
          lastCompletedDate: '2026-02-27',
          lastTimestamp: 1000,
        ),
      );

      final now = DateTime(2026, 2, 27, 15, 0);
      final result = await useCase.execute(now: now);

      expect(result.streak, 3);
      expect(result.lastCompletedDate, '2026-02-27');
      verifyNever(() => mockRepository.saveProgress(any()));
    });

    test('should reset streak when skipping a day without freeze', () async {
      when(() => mockRepository.getProgress()).thenAnswer(
        (_) async => const UserProgress(
          streak: 5,
          totalStreakDays: 10,
          lastCompletedDate: '2026-02-25',
          lastTimestamp: 1000,
          freezeCount: 0,
        ),
      );
      when(() => mockRepository.saveProgress(any())).thenAnswer((_) async {});

      final now = DateTime(2026, 2, 27, 10, 0);
      final result = await useCase.execute(now: now);

      expect(result.streak, 1);
      expect(result.totalStreakDays, 11);
    });

    test('should use freeze when skipping exactly one day', () async {
      when(() => mockRepository.getProgress()).thenAnswer(
        (_) async => const UserProgress(
          streak: 5,
          totalStreakDays: 10,
          lastCompletedDate: '2026-02-25',
          lastTimestamp: 1000,
          freezeCount: 2,
        ),
      );
      when(() => mockRepository.saveProgress(any())).thenAnswer((_) async {});

      final now = DateTime(2026, 2, 27, 10, 0);
      final result = await useCase.execute(now: now);

      expect(result.streak, 6);
      expect(result.totalStreakDays, 11);
      expect(result.freezeCount, 1);
    });

    test('should reset streak when skipping 2+ days even with freeze',
        () async {
      when(() => mockRepository.getProgress()).thenAnswer(
        (_) async => const UserProgress(
          streak: 5,
          totalStreakDays: 10,
          lastCompletedDate: '2026-02-24',
          lastTimestamp: 1000,
          freezeCount: 2,
        ),
      );
      when(() => mockRepository.saveProgress(any())).thenAnswer((_) async {});

      final now = DateTime(2026, 2, 27, 10, 0);
      final result = await useCase.execute(now: now);

      expect(result.streak, 1);
      expect(result.totalStreakDays, 11);
    });

    test('should not update when timestamp goes backwards', () async {
      when(() => mockRepository.getProgress()).thenAnswer(
        (_) async => UserProgress(
          streak: 3,
          totalStreakDays: 5,
          lastCompletedDate: '2026-02-27',
          lastTimestamp: DateTime(2026, 2, 27, 12, 0).millisecondsSinceEpoch,
        ),
      );

      final now = DateTime(2026, 2, 26, 10, 0);
      final result = await useCase.execute(now: now);

      expect(result.streak, 3);
      verifyNever(() => mockRepository.saveProgress(any()));
    });
  });
}

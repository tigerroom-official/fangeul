import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fangeul/core/entities/user_progress.dart';
import 'package:fangeul/data/datasources/user_progress_local_datasource.dart';
import 'package:fangeul/data/repositories/user_progress_repository_impl.dart';

class MockUserProgressLocalDataSource extends Mock
    implements UserProgressLocalDataSource {}

void main() {
  late MockUserProgressLocalDataSource mockDataSource;
  late UserProgressRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockUserProgressLocalDataSource();
    repository = UserProgressRepositoryImpl(mockDataSource);
  });

  setUpAll(() {
    registerFallbackValue(const UserProgress());
  });

  group('UserProgressRepositoryImpl', () {
    test('should load progress from data source', () async {
      const progress = UserProgress(streak: 5, totalStreakDays: 10);
      when(() => mockDataSource.load()).thenAnswer((_) async => progress);

      final result = await repository.getProgress();

      expect(result.streak, 5);
      expect(result.totalStreakDays, 10);
      verify(() => mockDataSource.load()).called(1);
    });

    test('should save progress to data source', () async {
      const progress = UserProgress(streak: 3);
      when(() => mockDataSource.save(any())).thenAnswer((_) async {});

      await repository.saveProgress(progress);

      verify(() => mockDataSource.save(progress)).called(1);
    });

    test('should return default progress when no data saved', () async {
      when(() => mockDataSource.load())
          .thenAnswer((_) async => const UserProgress());

      final result = await repository.getProgress();

      expect(result.streak, 0);
      expect(result.totalStreakDays, 0);
      expect(result.lastCompletedDate, isNull);
    });

    test(
        'should return false for checkAndUpdateStreak when already completed today',
        () async {
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      when(() => mockDataSource.load()).thenAnswer(
        (_) async => UserProgress(lastCompletedDate: todayStr),
      );

      final result = await repository.checkAndUpdateStreak();

      expect(result, isFalse);
    });

    test(
        'should return true for checkAndUpdateStreak when not yet completed today',
        () async {
      when(() => mockDataSource.load()).thenAnswer(
        (_) async => const UserProgress(lastCompletedDate: '2026-02-26'),
      );

      final result = await repository.checkAndUpdateStreak();

      expect(result, isTrue);
    });
  });
}

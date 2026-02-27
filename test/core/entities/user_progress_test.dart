import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/entities/user_progress.dart';

void main() {
  group('UserProgress', () {
    test('should create with default values', () {
      const progress = UserProgress();

      expect(progress.streak, 0);
      expect(progress.totalStreakDays, 0);
      expect(progress.lastCompletedDate, isNull);
      expect(progress.freezeCount, 0);
      expect(progress.lastTimestamp, 0);
      expect(progress.unlockedPackIds, isEmpty);
      expect(progress.collectedCardIds, isEmpty);
      expect(progress.starDust, 0);
    });

    test('should create with custom values', () {
      const progress = UserProgress(
        streak: 5,
        totalStreakDays: 10,
        lastCompletedDate: '2026-02-27',
        freezeCount: 2,
        lastTimestamp: 1000000,
        unlockedPackIds: ['birthday_pack'],
        collectedCardIds: ['card_001'],
        starDust: 100,
      );

      expect(progress.streak, 5);
      expect(progress.totalStreakDays, 10);
      expect(progress.lastCompletedDate, '2026-02-27');
      expect(progress.freezeCount, 2);
      expect(progress.lastTimestamp, 1000000);
      expect(progress.unlockedPackIds, ['birthday_pack']);
      expect(progress.collectedCardIds, ['card_001']);
      expect(progress.starDust, 100);
    });

    test('should support copyWith for immutable updates', () {
      const original = UserProgress(streak: 3, totalStreakDays: 5);
      final updated = original.copyWith(streak: 4, totalStreakDays: 6);

      expect(original.streak, 3);
      expect(original.totalStreakDays, 5);
      expect(updated.streak, 4);
      expect(updated.totalStreakDays, 6);
    });

    test('should have value equality', () {
      const a = UserProgress(streak: 1, lastCompletedDate: '2026-02-27');
      const b = UserProgress(streak: 1, lastCompletedDate: '2026-02-27');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('should not be equal with different values', () {
      const a = UserProgress(streak: 1);
      const b = UserProgress(streak: 2);

      expect(a, isNot(b));
    });
  });
}

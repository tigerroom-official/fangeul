import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:fangeul/core/entities/monetization_state.dart';

void main() {
  group('MonetizationState', () {
    test('should create with default values', () {
      const state = MonetizationState();

      expect(state.installDate, isNull);
      expect(state.honeymoonActive, isTrue);
      expect(state.favoriteSlotLimit, 0);
      expect(state.ttsPlayCount, 0);
      expect(state.ttsLastResetDate, isNull);
      expect(state.adWatchCount, 0);
      expect(state.adLastResetDate, isNull);
      expect(state.lastAdWatchTimestamp, 0);
      expect(state.unlockExpiresAt, 0);
      expect(state.purchasedPackIds, isEmpty);
      expect(state.ddayUnlockedDates, isEmpty);
      expect(state.lastTimestamp, 0);
    });

    test('should round-trip through JSON (toJson -> fromJson)', () {
      const original = MonetizationState(
        installDate: '2026-03-01',
        honeymoonActive: false,
        favoriteSlotLimit: 5,
        ttsPlayCount: 5,
        ttsLastResetDate: '2026-03-04',
        adWatchCount: 2,
        adLastResetDate: '2026-03-04',
        lastAdWatchTimestamp: 1709500000000,
        unlockExpiresAt: 1709514400000,
        purchasedPackIds: ['color_purple_dream', 'color_golden_hour'],
        ddayUnlockedDates: ['2026-03-09_evt001', '2026-06-13_evt002'],
        lastTimestamp: 1709500001000,
      );

      final jsonStr = jsonEncode(original.toJson());
      final restored = MonetizationState.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>,
      );

      expect(restored, original);
    });

    test('should support copyWith for key fields', () {
      const original = MonetizationState(
        honeymoonActive: true,
        favoriteSlotLimit: 0,
        adWatchCount: 0,
      );

      final updated = original.copyWith(
        honeymoonActive: false,
        favoriteSlotLimit: 5,
        adWatchCount: 1,
        adLastResetDate: '2026-03-04',
      );

      // 원본 불변 확인
      expect(original.honeymoonActive, isTrue);
      expect(original.favoriteSlotLimit, 0);
      expect(original.adWatchCount, 0);
      expect(original.adLastResetDate, isNull);

      // 업데이트 확인
      expect(updated.honeymoonActive, isFalse);
      expect(updated.favoriteSlotLimit, 5);
      expect(updated.adWatchCount, 1);
      expect(updated.adLastResetDate, '2026-03-04');
    });

    test('should serialize List<String> purchasedPackIds correctly', () {
      const state = MonetizationState(
        purchasedPackIds: ['pack_a', 'pack_b', 'pack_c'],
      );

      final json = state.toJson();
      expect(json['purchased_pack_ids'], ['pack_a', 'pack_b', 'pack_c']);

      final restored = MonetizationState.fromJson(json);
      expect(restored.purchasedPackIds, ['pack_a', 'pack_b', 'pack_c']);
    });

    test('should serialize List<String> ddayUnlockedDates correctly', () {
      const state = MonetizationState(
        ddayUnlockedDates: ['2026-03-09_evt001', '2026-06-13_evt002'],
      );

      final json = state.toJson();
      expect(
        json['dday_unlocked_dates'],
        ['2026-03-09_evt001', '2026-06-13_evt002'],
      );

      final restored = MonetizationState.fromJson(json);
      expect(restored.ddayUnlockedDates, [
        '2026-03-09_evt001',
        '2026-06-13_evt002',
      ]);
    });

    test('should have value equality', () {
      const a = MonetizationState(
        installDate: '2026-03-01',
        adWatchCount: 2,
      );
      const b = MonetizationState(
        installDate: '2026-03-01',
        adWatchCount: 2,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('should not be equal with different values', () {
      const a = MonetizationState(adWatchCount: 1);
      const b = MonetizationState(adWatchCount: 2);

      expect(a, isNot(b));
    });

    test('should handle empty lists in JSON round-trip', () {
      const state = MonetizationState();
      final json = state.toJson();

      expect(json['purchased_pack_ids'], isEmpty);
      expect(json['dday_unlocked_dates'], isEmpty);

      final restored = MonetizationState.fromJson(json);
      expect(restored.purchasedPackIds, isEmpty);
      expect(restored.ddayUnlockedDates, isEmpty);
      expect(restored, state);
    });
  });
}

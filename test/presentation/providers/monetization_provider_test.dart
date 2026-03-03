import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/data/datasources/monetization_local_datasource.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late ProviderContainer container;
  late MockFlutterSecureStorage mockStorage;

  /// 저장된 데이터가 없는 기본 상태로 컨테이너를 초기화한다.
  void setUpDefault() {
    mockStorage = MockFlutterSecureStorage();
    when(() => mockStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        monetizationStorageProvider.overrideWithValue(mockStorage),
      ],
    );
  }

  /// 특정 [MonetizationState]가 저장된 상태로 컨테이너를 초기화한다.
  void setUpWithState(MonetizationState initialState) {
    mockStorage = MockFlutterSecureStorage();
    final dataSource = MonetizationLocalDataSource(mockStorage);
    final dataStr = jsonEncode(initialState.toJson());
    final sig = dataSource.computeHmac(dataStr);

    when(() => mockStorage.read(key: MonetizationLocalDataSource.dataKey))
        .thenAnswer((_) async => dataStr);
    when(() => mockStorage.read(key: MonetizationLocalDataSource.sigKey))
        .thenAnswer((_) async => sig);
    when(() => mockStorage.write(
        key: any(named: 'key'),
        value: any(named: 'value'))).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        monetizationStorageProvider.overrideWithValue(mockStorage),
      ],
    );
  }

  tearDown(() => container.dispose());

  group('MonetizationNotifier', () {
    group('initial load', () {
      test('should initialize honeymoon with install date when no stored data',
          () async {
        setUpDefault();

        final state = await container.read(monetizationNotifierProvider.future);

        expect(state.honeymoonActive, true);
        expect(state.adWatchCount, 0);
        expect(state.ttsPlayCount, 0);
        expect(state.favoriteSlotLimit, 0);
        // build()에서 CheckHoneymoonUseCase가 설치일을 자동 설정
        expect(state.installDate, isNotNull);
        expect(state.installDate, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
        expect(state.purchasedPackIds, isEmpty);
        expect(state.ddayUnlockedDates, isEmpty);
        expect(state.unlockExpiresAt, 0);
      });

      test('should end honeymoon when install date is 7+ days ago', () async {
        setUpWithState(const MonetizationState(
          installDate: '2026-02-01',
          honeymoonActive: true,
          favoriteSlotLimit: 0,
        ));

        final state = await container.read(monetizationNotifierProvider.future);

        // Day 7 이상 → 허니문 종료
        expect(state.honeymoonActive, false);
        expect(state.favoriteSlotLimit, 3);
      });

      test('should keep honeymoon active within 7 days', () async {
        // 오늘 날짜로 설치
        final now = DateTime.now();
        final y = now.year.toString().padLeft(4, '0');
        final m = now.month.toString().padLeft(2, '0');
        final d = now.day.toString().padLeft(2, '0');
        final todayStr = '$y-$m-$d';

        setUpWithState(MonetizationState(
          installDate: todayStr,
          honeymoonActive: true,
          favoriteSlotLimit: 0,
        ));

        final state = await container.read(monetizationNotifierProvider.future);

        // Day 0 → 허니문 유지
        expect(state.honeymoonActive, true);
        expect(state.favoriteSlotLimit, 0);
      });
    });

    group('ensureInstallDate', () {
      test('should set install date on first call', () async {
        setUpDefault();

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        await notifier.ensureInstallDate();

        final state = await container.read(monetizationNotifierProvider.future);
        expect(state.installDate, isNotNull);
        // yyyy-MM-dd 형식 확인
        expect(state.installDate, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      });

      test('should not overwrite existing install date', () async {
        setUpWithState(const MonetizationState(installDate: '2026-01-01'));

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        await notifier.ensureInstallDate();

        final state = await container.read(monetizationNotifierProvider.future);
        expect(state.installDate, '2026-01-01');
      });
    });

    group('recordAdWatch', () {
      test('should increment ad watch count', () async {
        setUpDefault();

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        final result = await notifier.recordAdWatch();

        expect(result, true);
        final state = await container.read(monetizationNotifierProvider.future);
        expect(state.adWatchCount, 1);
      });

      test('should return false at daily limit (3)', () async {
        final now = DateTime.now();
        final y = now.year.toString().padLeft(4, '0');
        final m = now.month.toString().padLeft(2, '0');
        final d = now.day.toString().padLeft(2, '0');
        final todayStr = '$y-$m-$d';

        setUpWithState(MonetizationState(
          adWatchCount: 3,
          adLastResetDate: todayStr,
          // 쿨다운이 지난 과거 타임스탬프
          lastAdWatchTimestamp: now.millisecondsSinceEpoch - (10 * 60 * 1000),
        ));

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        final result = await notifier.recordAdWatch();

        expect(result, false);
      });

      test('should respect 5-min cooldown', () async {
        final now = DateTime.now();
        final y = now.year.toString().padLeft(4, '0');
        final m = now.month.toString().padLeft(2, '0');
        final d = now.day.toString().padLeft(2, '0');
        final todayStr = '$y-$m-$d';

        setUpWithState(MonetizationState(
          adWatchCount: 1,
          adLastResetDate: todayStr,
          // 1분 전 시청 → 쿨다운 미경과
          lastAdWatchTimestamp: now.millisecondsSinceEpoch - (1 * 60 * 1000),
        ));

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        final result = await notifier.recordAdWatch();

        expect(result, false);
      });

      test('should reset count when date changes', () async {
        setUpWithState(const MonetizationState(
          adWatchCount: 3,
          adLastResetDate: '2026-01-01',
          lastAdWatchTimestamp: 0,
        ));

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        // 오늘은 2026-01-01이 아니므로 카운트 리셋
        final result = await notifier.recordAdWatch();

        expect(result, true);
        final state = await container.read(monetizationNotifierProvider.future);
        expect(state.adWatchCount, 1);
      });
    });

    group('activateRewardedUnlock', () {
      test('should set approximately 4h expiry', () async {
        setUpDefault();

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        final beforeMs = DateTime.now().millisecondsSinceEpoch;
        await notifier.activateRewardedUnlock();
        final afterMs = DateTime.now().millisecondsSinceEpoch;

        final state = await container.read(monetizationNotifierProvider.future);
        expect(state.unlockExpiresAt, greaterThan(0));

        // 만료 시각이 now+4h 이내인지 확인 (자정이 더 빠를 수 있음)
        final maxExpiry = afterMs + MonetizationNotifier.unlockDurationMs;
        expect(state.unlockExpiresAt, lessThanOrEqualTo(maxExpiry));
        expect(
          state.unlockExpiresAt,
          greaterThanOrEqualTo(beforeMs),
        );
      });
    });

    group('computeUnlockExpiry', () {
      test('should cap at midnight when less than 4h away', () async {
        setUpDefault();

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        // 23:00 → 자정까지 1시간, 4시간보다 짧음
        final lateNight = DateTime(2026, 3, 4, 23, 0, 0);
        final expiry = notifier.computeUnlockExpiry(now: lateNight);

        final nextMidnight = DateTime(2026, 3, 5);
        expect(expiry, nextMidnight.millisecondsSinceEpoch);
      });

      test('should use 4h when midnight is further away', () async {
        setUpDefault();

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        // 10:00 → 자정까지 14시간, 4시간보다 김
        final morning = DateTime(2026, 3, 4, 10, 0, 0);
        final expiry = notifier.computeUnlockExpiry(now: morning);

        final expectedMs = morning.millisecondsSinceEpoch +
            MonetizationNotifier.unlockDurationMs;
        expect(expiry, expectedMs);
      });
    });

    group('addPurchasedPack', () {
      test('should add pack idempotently', () async {
        setUpDefault();

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        await notifier.addPurchasedPack('pack_purple_dream');
        await notifier.addPurchasedPack('pack_purple_dream');
        await notifier.addPurchasedPack('pack_golden_hour');

        final state = await container.read(monetizationNotifierProvider.future);
        expect(
            state.purchasedPackIds, ['pack_purple_dream', 'pack_golden_hour']);
      });
    });

    group('endHoneymoon', () {
      test('should set honeymoonActive=false and favoriteSlotLimit=3',
          () async {
        setUpDefault();

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        // 초기: honeymoonActive=true, favoriteSlotLimit=0
        await notifier.endHoneymoon();

        final state = await container.read(monetizationNotifierProvider.future);
        expect(state.honeymoonActive, false);
        expect(state.favoriteSlotLimit, 3);
      });
    });

    group('checkDailyReset', () {
      test('should reset ad and TTS counts when date changes', () async {
        setUpWithState(const MonetizationState(
          adWatchCount: 3,
          adLastResetDate: '2026-03-01',
          ttsPlayCount: 5,
          ttsLastResetDate: '2026-03-01',
        ));

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        // 다른 날짜 전달
        await notifier.checkDailyReset(now: DateTime(2026, 3, 4));

        final state = await container.read(monetizationNotifierProvider.future);
        expect(state.adWatchCount, 0);
        expect(state.ttsPlayCount, 0);
        expect(state.adLastResetDate, '2026-03-04');
        expect(state.ttsLastResetDate, '2026-03-04');
      });

      test('should not update when date is same', () async {
        setUpWithState(const MonetizationState(
          adWatchCount: 2,
          adLastResetDate: '2026-03-04',
          ttsPlayCount: 3,
          ttsLastResetDate: '2026-03-04',
        ));

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        await notifier.checkDailyReset(now: DateTime(2026, 3, 4));

        final state = await container.read(monetizationNotifierProvider.future);
        // 값이 유지되어야 함
        expect(state.adWatchCount, 2);
        expect(state.ttsPlayCount, 3);
      });
    });

    group('activateDdayUnlock', () {
      test('should record and activate 24h unlock', () async {
        setUpDefault();

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        final result = await notifier.activateDdayUnlock(
          date: '2026-03-04',
          eventId: 'bts_debut',
        );

        expect(result, true);
        final state = await container.read(monetizationNotifierProvider.future);
        expect(state.ddayUnlockedDates, contains('2026-03-04_bts_debut'));
        expect(state.unlockExpiresAt, greaterThan(0));
      });

      test('should prevent duplicate event', () async {
        setUpWithState(const MonetizationState(
          ddayUnlockedDates: ['2026-03-04_bts_debut'],
        ));

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        final result = await notifier.activateDdayUnlock(
          date: '2026-03-04',
          eventId: 'bts_debut',
        );

        expect(result, false);
      });

      test('should reject when time manipulation detected', () async {
        // lastTimestamp를 먼 미래로 설정 → 현재 시간보다 크면 조작 감지
        final futureTimestamp =
            DateTime.now().millisecondsSinceEpoch + (365 * 24 * 60 * 60 * 1000);
        setUpWithState(MonetizationState(
          lastTimestamp: futureTimestamp,
        ));

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        final result = await notifier.activateDdayUnlock(
          date: '2026-03-04',
          eventId: 'new_event',
        );

        expect(result, false);
      });
    });

    group('validateTimestamp', () {
      test('should accept future timestamp', () async {
        setUpWithState(const MonetizationState(lastTimestamp: 1000));

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        final result = await notifier.validateTimestamp(timestamp: 2000);

        expect(result, true);
      });

      test('should reject past timestamp', () async {
        setUpWithState(const MonetizationState(lastTimestamp: 5000));

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        final result = await notifier.validateTimestamp(timestamp: 3000);

        expect(result, false);
      });

      test('should accept equal timestamp', () async {
        setUpWithState(const MonetizationState(lastTimestamp: 5000));

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        final result = await notifier.validateTimestamp(timestamp: 5000);

        expect(result, true);
      });
    });

    group('recordTtsPlay', () {
      test('should increment TTS play count', () async {
        setUpDefault();

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        await notifier.recordTtsPlay();

        final state = await container.read(monetizationNotifierProvider.future);
        expect(state.ttsPlayCount, 1);
      });

      test('should auto reset TTS count on date change', () async {
        setUpWithState(const MonetizationState(
          ttsPlayCount: 5,
          ttsLastResetDate: '2026-01-01',
        ));

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        await notifier.recordTtsPlay();

        final state = await container.read(monetizationNotifierProvider.future);
        // 날짜가 바뀌었으므로 리셋 후 1이 되어야 함
        expect(state.ttsPlayCount, 1);
      });
    });

    group('getters', () {
      test('isAdLimitReached should return true at limit', () async {
        final now = DateTime.now();
        final y = now.year.toString().padLeft(4, '0');
        final m = now.month.toString().padLeft(2, '0');
        final d = now.day.toString().padLeft(2, '0');
        final todayStr = '$y-$m-$d';

        setUpWithState(MonetizationState(
          adWatchCount: 3,
          adLastResetDate: todayStr,
        ));

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        expect(notifier.isAdLimitReached, true);
      });

      test('isTtsLimitReached should return true at limit', () async {
        final now = DateTime.now();
        final y = now.year.toString().padLeft(4, '0');
        final m = now.month.toString().padLeft(2, '0');
        final d = now.day.toString().padLeft(2, '0');
        final todayStr = '$y-$m-$d';

        setUpWithState(MonetizationState(
          ttsPlayCount: 5,
          ttsLastResetDate: todayStr,
        ));

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        expect(notifier.isTtsLimitReached, true);
      });

      test('isAdLimitReached should return false on new day (cross-day reset)',
          () async {
        setUpWithState(const MonetizationState(
          adWatchCount: 3,
          adLastResetDate: '2026-01-01', // 과거 날짜
        ));

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        expect(notifier.isAdLimitReached, false);
      });

      test('isTtsLimitReached should return false on new day (cross-day reset)',
          () async {
        setUpWithState(const MonetizationState(
          ttsPlayCount: 5,
          ttsLastResetDate: '2026-01-01', // 과거 날짜
        ));

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        expect(notifier.isTtsLimitReached, false);
      });

      test('isUnlockActive should return true when not expired', () async {
        final futureExpiry =
            DateTime.now().millisecondsSinceEpoch + (2 * 60 * 60 * 1000);
        setUpWithState(MonetizationState(
          unlockExpiresAt: futureExpiry,
        ));

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        expect(notifier.isUnlockActive, true);
      });

      test('isUnlockActive should return false when expired', () async {
        final pastExpiry = DateTime.now().millisecondsSinceEpoch - (1000);
        setUpWithState(MonetizationState(
          unlockExpiresAt: pastExpiry,
        ));

        final notifier = container.read(monetizationNotifierProvider.notifier);
        await container.read(monetizationNotifierProvider.future);

        expect(notifier.isUnlockActive, false);
      });
    });
  });

  group('Convenience providers', () {
    test('isHoneymoon should return true for default state', () async {
      mockStorage = MockFlutterSecureStorage();
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      when(() => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'))).thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [
          monetizationStorageProvider.overrideWithValue(mockStorage),
        ],
      );

      // keepAlive notifier를 먼저 로드
      await container.read(monetizationNotifierProvider.future);

      // auto-dispose provider를 listen으로 유지
      final sub = container.listen(isHoneymoonProvider, (_, __) {});
      addTearDown(sub.close);

      expect(container.read(isHoneymoonProvider), true);
    });

    test('isHoneymoon should return false after endHoneymoon', () async {
      mockStorage = MockFlutterSecureStorage();
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      when(() => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'))).thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [
          monetizationStorageProvider.overrideWithValue(mockStorage),
        ],
      );

      final notifier = container.read(monetizationNotifierProvider.notifier);
      await container.read(monetizationNotifierProvider.future);

      await notifier.endHoneymoon();

      final sub = container.listen(isHoneymoonProvider, (_, __) {});
      addTearDown(sub.close);

      expect(container.read(isHoneymoonProvider), false);
    });

    test('isRewardedUnlockActive should reflect unlock state', () async {
      mockStorage = MockFlutterSecureStorage();
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      when(() => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'))).thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [
          monetizationStorageProvider.overrideWithValue(mockStorage),
        ],
      );

      final notifier = container.read(monetizationNotifierProvider.notifier);
      await container.read(monetizationNotifierProvider.future);

      // 초기: 해금 없음
      final sub = container.listen(isRewardedUnlockActiveProvider, (_, __) {});
      addTearDown(sub.close);

      expect(container.read(isRewardedUnlockActiveProvider), false);

      await notifier.activateRewardedUnlock();

      expect(container.read(isRewardedUnlockActiveProvider), true);
    });

    test('favoriteSlotLimit should reflect state', () async {
      mockStorage = MockFlutterSecureStorage();
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      when(() => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'))).thenAnswer((_) async {});

      container = ProviderContainer(
        overrides: [
          monetizationStorageProvider.overrideWithValue(mockStorage),
        ],
      );

      final notifier = container.read(monetizationNotifierProvider.notifier);
      await container.read(monetizationNotifierProvider.future);

      // 초기: 0 (허니문 = 무제한)
      final sub = container.listen(favoriteSlotLimitProvider, (_, __) {});
      addTearDown(sub.close);

      expect(container.read(favoriteSlotLimitProvider), 0);

      await notifier.endHoneymoon();

      expect(container.read(favoriteSlotLimitProvider), 3);
    });
  });
}

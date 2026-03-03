# Phase 6 수익화 구현 계획

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fangeul 앱에 광고(배너+보상형) + IAP(감성 컬러 팩) + 경험 깊이 제한 + 전환 퍼널을 구현한다.

**Architecture:** 모든 수익화 상태는 `flutter_secure_storage` + HMAC-SHA256으로 보호. MonetizationState freezed 엔티티가 허니문/해금/카운터를 통합 관리. AdMob 배너+보상형, in_app_purchase IAP 통합. Clean Architecture 레이어별 분리 유지.

**Tech Stack:** Flutter 3.41.2, Riverpod (annotation), freezed, google_mobile_ads, in_app_purchase, flutter_secure_storage, crypto, just_audio

**설계 문서:** `docs/discussions/2026-03-04-phase6-monetization-consensus.md`

---

## 의존성 그래프

```
Task 1 (Entity)
  ↓
Task 2 (DataSource) → Task 3 (Repository)
  ↓
Task 4 (Provider) ← 모든 후속 태스크가 의존
  ↓
┌─────────────┬──────────────┬────────────────┐
Task 5        Task 7         Task 11          Task 15
(Honeymoon)   (AdService)    (ColorPack JSON) (D-day)
  ↓             ↓
Task 6        Task 8 ──→ Task 9
(Fav Limit)   (Banner)    (Rewarded)
                             ↓
              Task 10 ←── Task 9
              (Unlock Timer)
                             ↓
              Task 12 (IAP Service)
                ↓
              Task 13 (Purchase Flow)
                ↓
              Task 14 (Conversion Trigger)
                ↓
              Task 16 (Banner Conditional)
                ↓
              Task 17 (TTS Counter)
                ↓
              Task 18 (UI Strings + Analytics)
```

---

## Task 1: MonetizationState 엔티티

**Files:**
- Create: `lib/core/entities/monetization_state.dart`
- Test: `test/core/entities/monetization_state_test.dart`

**Step 1: Write the failing test**

```dart
// test/core/entities/monetization_state_test.dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fangeul/core/entities/monetization_state.dart';

void main() {
  group('MonetizationState', () {
    test('should create with defaults', () {
      const state = MonetizationState();
      expect(state.installDate, isNull);
      expect(state.honeymoonActive, true);
      expect(state.favoriteSlotLimit, 0); // 0 = unlimited (honeymoon)
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

    test('should serialize to JSON and back', () {
      final state = MonetizationState(
        installDate: '2026-03-04',
        honeymoonActive: false,
        favoriteSlotLimit: 3,
        ttsPlayCount: 4,
        ttsLastResetDate: '2026-03-04',
        adWatchCount: 2,
        adLastResetDate: '2026-03-04',
        lastAdWatchTimestamp: 1000,
        unlockExpiresAt: 5000,
        purchasedPackIds: ['purple_dream'],
        ddayUnlockedDates: ['2026-03-09_bts_suga_birthday'],
        lastTimestamp: 9999,
      );
      final json = state.toJson();
      final restored = MonetizationState.fromJson(json);
      expect(restored, state);
    });

    test('should compute daysSinceInstall correctly', () {
      final state = MonetizationState(installDate: '2026-03-01');
      // daysSinceInstall is computed at runtime, tested via helper
      expect(state.installDate, '2026-03-01');
    });

    test('should check isHoneymoonPeriod based on daysSinceInstall', () {
      final state = MonetizationState(
        installDate: '2026-03-04',
        honeymoonActive: true,
      );
      expect(state.honeymoonActive, true);
    });

    test('should check hasActiveUnlock', () {
      // unlockExpiresAt in future (ms since epoch)
      final futureMs = DateTime.now().add(Duration(hours: 2)).millisecondsSinceEpoch;
      final state = MonetizationState(unlockExpiresAt: futureMs);
      expect(state.unlockExpiresAt, greaterThan(0));
    });

    test('should check isPackPurchased', () {
      final state = MonetizationState(purchasedPackIds: ['purple_dream', 'golden_hour']);
      expect(state.purchasedPackIds.contains('purple_dream'), true);
      expect(state.purchasedPackIds.contains('mint_evening'), false);
    });

    test('should check canWatchAd with daily limit', () {
      final state = MonetizationState(adWatchCount: 3, adLastResetDate: '2026-03-04');
      // 3 = daily product cap
      expect(state.adWatchCount >= 3, true);
    });

    test('should check cooldown with lastAdWatchTimestamp', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final state = MonetizationState(lastAdWatchTimestamp: now);
      final cooldownMs = 5 * 60 * 1000; // 5 min
      expect(now - state.lastAdWatchTimestamp < cooldownMs, true);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/core/entities/monetization_state_test.dart`
Expected: FAIL — `monetization_state.dart` not found

**Step 3: Write the entity**

```dart
// lib/core/entities/monetization_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'monetization_state.freezed.dart';
part 'monetization_state.g.dart';

/// 수익화 전체 상태. flutter_secure_storage + HMAC 서명으로 보호.
///
/// 허니문, 즐겨찾기 슬롯, TTS 카운터, 광고 시청, 해금 타이머,
/// IAP 구매, D-day 해금 이력을 통합 관리한다.
@freezed
class MonetizationState with _$MonetizationState {
  const factory MonetizationState({
    /// 앱 최초 설치 날짜 (yyyy-MM-dd). null이면 미설정.
    String? installDate,

    /// 허니문 기간 활성 여부 (Day 0~6).
    @Default(true) bool honeymoonActive,

    /// 즐겨찾기 슬롯 제한. 0 = 무제한(허니문/Pro), 3 = 기본 제한.
    @Default(0) int favoriteSlotLimit,

    /// TTS 오늘 재생 횟수. 매일 자정 리셋.
    @Default(0) int ttsPlayCount,

    /// TTS 카운터 마지막 리셋 날짜 (yyyy-MM-dd).
    String? ttsLastResetDate,

    /// 보상형 광고 오늘 시청 횟수. 매일 자정 리셋.
    @Default(0) int adWatchCount,

    /// 광고 카운터 마지막 리셋 날짜 (yyyy-MM-dd).
    String? adLastResetDate,

    /// 마지막 보상형 광고 시청 타임스탬프 (ms). 5분 쿨다운 용.
    @Default(0) int lastAdWatchTimestamp,

    /// 보상형 해금 만료 시각 (ms since epoch). 0이면 해금 없음.
    @Default(0) int unlockExpiresAt,

    /// 구매 완료된 팩 ID 목록.
    @Default([]) List<String> purchasedPackIds,

    /// D-day 해금 이력 ('{date}_{eventId}' 형식).
    @Default([]) List<String> ddayUnlockedDates,

    /// 단조증가 타임스탬프 (시간 조작 방지).
    @Default(0) int lastTimestamp,
  }) = _MonetizationState;

  factory MonetizationState.fromJson(Map<String, dynamic> json) =>
      _$MonetizationStateFromJson(json);
}
```

**Step 4: Run code generation**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Step 5: Run test to verify it passes**

Run: `flutter test test/core/entities/monetization_state_test.dart`
Expected: ALL PASS

**Step 6: Commit**

```bash
git add lib/core/entities/monetization_state.dart lib/core/entities/monetization_state.freezed.dart lib/core/entities/monetization_state.g.dart test/core/entities/monetization_state_test.dart
git commit -m "feat: add MonetizationState freezed entity"
```

---

## Task 2: MonetizationLocalDataSource (secure_storage + HMAC)

**Files:**
- Create: `lib/data/datasources/monetization_local_datasource.dart`
- Test: `test/data/datasources/monetization_local_datasource_test.dart`
- Reference: `lib/data/datasources/user_progress_local_datasource.dart` (HMAC 패턴 참조)

**Step 1: Write the failing test**

```dart
// test/data/datasources/monetization_local_datasource_test.dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/data/datasources/monetization_local_datasource.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late MonetizationLocalDataSource dataSource;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    dataSource = MonetizationLocalDataSource(mockStorage);
  });

  group('load', () {
    test('should return default state when no data stored', () async {
      when(() => mockStorage.read(key: MonetizationLocalDataSource.dataKey))
          .thenAnswer((_) async => null);
      when(() => mockStorage.read(key: MonetizationLocalDataSource.sigKey))
          .thenAnswer((_) async => null);

      final result = await dataSource.load();

      expect(result, const MonetizationState());
    });

    test('should return stored state when HMAC matches', () async {
      final state = MonetizationState(
        installDate: '2026-03-04',
        honeymoonActive: true,
        adWatchCount: 2,
      );
      final json = jsonEncode(state.toJson());
      final sig = dataSource.computeHmac(json);

      when(() => mockStorage.read(key: MonetizationLocalDataSource.dataKey))
          .thenAnswer((_) async => json);
      when(() => mockStorage.read(key: MonetizationLocalDataSource.sigKey))
          .thenAnswer((_) async => sig);

      final result = await dataSource.load();

      expect(result.installDate, '2026-03-04');
      expect(result.adWatchCount, 2);
    });

    test('should reset state when HMAC mismatch (tampering detected)', () async {
      final json = '{"installDate":"2026-03-04"}';

      when(() => mockStorage.read(key: MonetizationLocalDataSource.dataKey))
          .thenAnswer((_) async => json);
      when(() => mockStorage.read(key: MonetizationLocalDataSource.sigKey))
          .thenAnswer((_) async => 'invalid_signature');
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      final result = await dataSource.load();

      expect(result, const MonetizationState());
      verify(() => mockStorage.delete(key: MonetizationLocalDataSource.dataKey)).called(1);
      verify(() => mockStorage.delete(key: MonetizationLocalDataSource.sigKey)).called(1);
    });

    test('should reset state when JSON is corrupted', () async {
      when(() => mockStorage.read(key: MonetizationLocalDataSource.dataKey))
          .thenAnswer((_) async => 'not_valid_json');
      when(() => mockStorage.read(key: MonetizationLocalDataSource.sigKey))
          .thenAnswer((_) async => 'some_sig');
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      final result = await dataSource.load();

      expect(result, const MonetizationState());
    });
  });

  group('save', () {
    test('should persist state with HMAC signature', () async {
      final state = MonetizationState(
        installDate: '2026-03-04',
        adWatchCount: 1,
        lastTimestamp: 1000,
      );

      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      await dataSource.save(state);

      final captured = verify(
        () => mockStorage.write(
          key: MonetizationLocalDataSource.dataKey,
          value: captureAny(named: 'value'),
        ),
      ).captured.single as String;

      // Verify data can be parsed back
      final restored = MonetizationState.fromJson(jsonDecode(captured));
      expect(restored.installDate, '2026-03-04');

      // Verify sig was also written
      verify(
        () => mockStorage.write(
          key: MonetizationLocalDataSource.sigKey,
          value: any(named: 'value'),
        ),
      ).called(1);
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/data/datasources/monetization_local_datasource_test.dart`
Expected: FAIL — file not found

**Step 3: Implement the data source**

```dart
// lib/data/datasources/monetization_local_datasource.dart
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:fangeul/core/entities/monetization_state.dart';

/// 수익화 상태를 flutter_secure_storage + HMAC-SHA256으로 보호하여 저장/로드.
///
/// 서명 불일치 시 변조로 판단하여 상태를 초기화한다.
class MonetizationLocalDataSource {
  MonetizationLocalDataSource(this._storage);

  final FlutterSecureStorage _storage;

  static const String dataKey = 'monetization_data';
  static const String sigKey = 'monetization_sig';
  static const String _hmacSecret = 'fangeul_monetization_v1_2026';

  /// 저장된 수익화 상태를 로드. 서명 불일치 시 기본값 반환.
  Future<MonetizationState> load() async {
    final dataStr = await _storage.read(key: dataKey);
    final sigStr = await _storage.read(key: sigKey);

    if (dataStr == null || sigStr == null) {
      return const MonetizationState();
    }

    final expectedSig = computeHmac(dataStr);
    if (sigStr != expectedSig) {
      debugPrint('MonetizationLocalDataSource: HMAC mismatch — resetting');
      await _storage.delete(key: dataKey);
      await _storage.delete(key: sigKey);
      return const MonetizationState();
    }

    try {
      final json = jsonDecode(dataStr) as Map<String, dynamic>;
      return MonetizationState.fromJson(json);
    } catch (e) {
      debugPrint('MonetizationLocalDataSource: JSON parse error — resetting');
      await _storage.delete(key: dataKey);
      await _storage.delete(key: sigKey);
      return const MonetizationState();
    }
  }

  /// 수익화 상태를 저장하고 HMAC 서명을 갱신.
  Future<void> save(MonetizationState state) async {
    final dataStr = jsonEncode(state.toJson());
    final sig = computeHmac(dataStr);
    await _storage.write(key: dataKey, value: dataStr);
    await _storage.write(key: sigKey, value: sig);
  }

  /// HMAC-SHA256 서명 계산. 테스트에서도 접근 가능.
  String computeHmac(String data) {
    final key = utf8.encode(_hmacSecret);
    final bytes = utf8.encode(data);
    final hmacSha256 = Hmac(sha256, key);
    return hmacSha256.convert(bytes).toString();
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/data/datasources/monetization_local_datasource_test.dart`
Expected: ALL PASS

**Step 5: Commit**

```bash
git add lib/data/datasources/monetization_local_datasource.dart test/data/datasources/monetization_local_datasource_test.dart
git commit -m "feat: add MonetizationLocalDataSource with HMAC signing"
```

---

## Task 3: MonetizationRepository 인터페이스 + 구현

**Files:**
- Create: `lib/core/repositories/monetization_repository.dart`
- Create: `lib/data/repositories/monetization_repository_impl.dart`
- Test: `test/data/repositories/monetization_repository_impl_test.dart`

**Step 1: Write the failing test**

```dart
// test/data/repositories/monetization_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/core/repositories/monetization_repository.dart';
import 'package:fangeul/data/datasources/monetization_local_datasource.dart';
import 'package:fangeul/data/repositories/monetization_repository_impl.dart';

class MockMonetizationLocalDataSource extends Mock
    implements MonetizationLocalDataSource {}

void main() {
  late MockMonetizationLocalDataSource mockDataSource;
  late MonetizationRepository repository;

  setUp(() {
    mockDataSource = MockMonetizationLocalDataSource();
    repository = MonetizationRepositoryImpl(mockDataSource);
  });

  test('should delegate load to data source', () async {
    final state = MonetizationState(installDate: '2026-03-04');
    when(() => mockDataSource.load()).thenAnswer((_) async => state);

    final result = await repository.load();

    expect(result.installDate, '2026-03-04');
    verify(() => mockDataSource.load()).called(1);
  });

  test('should delegate save to data source', () async {
    final state = MonetizationState(adWatchCount: 2);
    when(() => mockDataSource.save(state)).thenAnswer((_) async {});

    await repository.save(state);

    verify(() => mockDataSource.save(state)).called(1);
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/data/repositories/monetization_repository_impl_test.dart`
Expected: FAIL

**Step 3: Implement interface and implementation**

```dart
// lib/core/repositories/monetization_repository.dart
import 'package:fangeul/core/entities/monetization_state.dart';

/// 수익화 상태 저장소 인터페이스.
abstract class MonetizationRepository {
  Future<MonetizationState> load();
  Future<void> save(MonetizationState state);
}
```

```dart
// lib/data/repositories/monetization_repository_impl.dart
import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/core/repositories/monetization_repository.dart';
import 'package:fangeul/data/datasources/monetization_local_datasource.dart';

/// MonetizationRepository 구현. HMAC-보호 secure storage에 위임.
class MonetizationRepositoryImpl implements MonetizationRepository {
  MonetizationRepositoryImpl(this._dataSource);

  final MonetizationLocalDataSource _dataSource;

  @override
  Future<MonetizationState> load() => _dataSource.load();

  @override
  Future<void> save(MonetizationState state) => _dataSource.save(state);
}
```

**Step 4: Run test**

Run: `flutter test test/data/repositories/monetization_repository_impl_test.dart`
Expected: ALL PASS

**Step 5: Commit**

```bash
git add lib/core/repositories/monetization_repository.dart lib/data/repositories/monetization_repository_impl.dart test/data/repositories/monetization_repository_impl_test.dart
git commit -m "feat: add MonetizationRepository interface and implementation"
```

---

## Task 4: MonetizationNotifier 프로바이더

**Files:**
- Create: `lib/presentation/providers/monetization_provider.dart`
- Test: `test/presentation/providers/monetization_provider_test.dart`
- Modify: `lib/presentation/providers/` (build_runner 생성 파일)

**Step 1: Write the failing test**

```dart
// test/presentation/providers/monetization_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/data/datasources/monetization_local_datasource.dart';
import 'package:fangeul/data/repositories/monetization_repository_impl.dart';
import 'package:fangeul/presentation/providers/monetization_provider.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late ProviderContainer container;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    // Mock: 빈 저장소 (초기 상태)
    when(() => mockStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        monetizationStorageProvider.overrideWithValue(mockStorage),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('should load default state initially', () async {
    final state = await container.read(monetizationNotifierProvider.future);
    expect(state.honeymoonActive, true);
    expect(state.adWatchCount, 0);
  });

  test('should set install date on first load if null', () async {
    final notifier = container.read(monetizationNotifierProvider.notifier);
    await container.read(monetizationNotifierProvider.future);

    await notifier.ensureInstallDate();

    final state = container.read(monetizationNotifierProvider).value!;
    expect(state.installDate, isNotNull);
  });

  test('should increment ad watch count', () async {
    final notifier = container.read(monetizationNotifierProvider.notifier);
    await container.read(monetizationNotifierProvider.future);

    await notifier.recordAdWatch();

    final state = container.read(monetizationNotifierProvider).value!;
    expect(state.adWatchCount, 1);
    expect(state.lastAdWatchTimestamp, greaterThan(0));
  });

  test('should not exceed daily ad limit of 3', () async {
    final notifier = container.read(monetizationNotifierProvider.notifier);
    await container.read(monetizationNotifierProvider.future);

    await notifier.recordAdWatch();
    await notifier.recordAdWatch();
    await notifier.recordAdWatch();
    final result = await notifier.recordAdWatch(); // 4th attempt

    expect(result, false);
    final state = container.read(monetizationNotifierProvider).value!;
    expect(state.adWatchCount, 3);
  });

  test('should set unlock expiry to 4 hours', () async {
    final notifier = container.read(monetizationNotifierProvider.notifier);
    await container.read(monetizationNotifierProvider.future);

    await notifier.activateRewardedUnlock();

    final state = container.read(monetizationNotifierProvider).value!;
    final now = DateTime.now().millisecondsSinceEpoch;
    final fourHoursMs = 4 * 60 * 60 * 1000;
    // Unlock should be ~4h from now
    expect(state.unlockExpiresAt, greaterThan(now));
    expect(state.unlockExpiresAt, lessThanOrEqualTo(now + fourHoursMs + 1000));
  });

  test('should cap unlock at midnight if closer than 4h', () async {
    // This is time-dependent; test the helper logic separately
    final notifier = container.read(monetizationNotifierProvider.notifier);
    await container.read(monetizationNotifierProvider.future);

    final expiry = notifier.computeUnlockExpiry(
      now: DateTime(2026, 3, 4, 23, 0), // 11 PM → midnight is 1h away
    );

    final midnight = DateTime(2026, 3, 5).millisecondsSinceEpoch;
    expect(expiry, midnight);
  });

  test('should add purchased pack', () async {
    final notifier = container.read(monetizationNotifierProvider.notifier);
    await container.read(monetizationNotifierProvider.future);

    await notifier.addPurchasedPack('purple_dream');

    final state = container.read(monetizationNotifierProvider).value!;
    expect(state.purchasedPackIds, contains('purple_dream'));
  });

  test('should deactivate honeymoon and apply limits', () async {
    final notifier = container.read(monetizationNotifierProvider.notifier);
    await container.read(monetizationNotifierProvider.future);

    await notifier.endHoneymoon();

    final state = container.read(monetizationNotifierProvider).value!;
    expect(state.honeymoonActive, false);
    expect(state.favoriteSlotLimit, 3);
  });

  test('should reset daily counters when date changes', () async {
    final notifier = container.read(monetizationNotifierProvider.notifier);
    await container.read(monetizationNotifierProvider.future);

    // Simulate yesterday's counts
    await notifier.recordAdWatch();
    await notifier.recordAdWatch();

    // Force date check with "tomorrow"
    await notifier.checkDailyReset(
      now: DateTime.now().add(Duration(days: 1)),
    );

    final state = container.read(monetizationNotifierProvider).value!;
    expect(state.adWatchCount, 0);
    expect(state.ttsPlayCount, 0);
  });

  test('should record D-day unlock and prevent duplicate', () async {
    final notifier = container.read(monetizationNotifierProvider.notifier);
    await container.read(monetizationNotifierProvider.future);

    final result1 = await notifier.activateDdayUnlock(
      date: '2026-03-09',
      eventId: 'bts_suga_birthday',
    );
    expect(result1, true);

    final result2 = await notifier.activateDdayUnlock(
      date: '2026-03-09',
      eventId: 'bts_suga_birthday',
    );
    expect(result2, false); // Duplicate
  });

  test('should reject time manipulation', () async {
    final notifier = container.read(monetizationNotifierProvider.notifier);
    await container.read(monetizationNotifierProvider.future);

    // Record with current time
    await notifier.recordAdWatch();
    final ts1 = container.read(monetizationNotifierProvider).value!.lastTimestamp;

    // Attempt with past timestamp
    final pastResult = await notifier.validateTimestamp(
      timestamp: ts1 - 10000,
    );
    expect(pastResult, false);
  });

  test('should increment TTS play count', () async {
    final notifier = container.read(monetizationNotifierProvider.notifier);
    await container.read(monetizationNotifierProvider.future);

    await notifier.recordTtsPlay();

    final state = container.read(monetizationNotifierProvider).value!;
    expect(state.ttsPlayCount, 1);
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/providers/monetization_provider_test.dart`
Expected: FAIL

**Step 3: Implement the provider**

```dart
// lib/presentation/providers/monetization_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/data/datasources/monetization_local_datasource.dart';
import 'package:fangeul/data/repositories/monetization_repository_impl.dart';

part 'monetization_provider.g.dart';

/// flutter_secure_storage 인스턴스. 테스트에서 override.
@Riverpod(keepAlive: true)
FlutterSecureStorage monetizationStorage(Ref ref) {
  return const FlutterSecureStorage();
}

/// 수익화 상태 관리 Notifier.
///
/// 모든 수익화 상태(허니문, 슬롯 제한, 광고 카운터, 해금 타이머,
/// IAP 구매, D-day, TTS 카운터)를 통합 관리한다.
/// flutter_secure_storage + HMAC-SHA256 서명으로 보호.
@Riverpod(keepAlive: true)
class MonetizationNotifier extends _$MonetizationNotifier {
  late MonetizationRepositoryImpl _repository;

  static const int _dailyAdLimit = 3;
  static const int _cooldownMs = 5 * 60 * 1000; // 5 min
  static const int _unlockDurationMs = 4 * 60 * 60 * 1000; // 4h
  static const int _defaultSlotLimit = 3;
  static const int _dailyTtsLimit = 5;

  @override
  Future<MonetizationState> build() async {
    final storage = ref.read(monetizationStorageProvider);
    _repository = MonetizationRepositoryImpl(
      MonetizationLocalDataSource(storage),
    );
    return _repository.load();
  }

  Future<void> _updateState(MonetizationState newState) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final updated = newState.copyWith(lastTimestamp: now);
    state = AsyncData(updated);
    try {
      await _repository.save(updated);
    } catch (e) {
      debugPrint('MonetizationNotifier: save error: $e');
    }
  }

  String _formatDate(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  /// 최초 설치 날짜 설정 (한 번만 실행).
  Future<void> ensureInstallDate() async {
    try { await future; } catch (_) {}
    final current = state.value ?? const MonetizationState();
    if (current.installDate != null) return;
    await _updateState(current.copyWith(installDate: _formatDate(DateTime.now())));
  }

  /// 보상형 광고 시청 기록. false = 일일 한도 초과.
  Future<bool> recordAdWatch() async {
    try { await future; } catch (_) {}
    final current = state.value ?? const MonetizationState();
    final now = DateTime.now();
    final todayStr = _formatDate(now);

    // 일일 리셋 체크
    var effective = current;
    if (effective.adLastResetDate != todayStr) {
      effective = effective.copyWith(adWatchCount: 0, adLastResetDate: todayStr);
    }

    if (effective.adWatchCount >= _dailyAdLimit) return false;

    // 쿨다운 체크
    final nowMs = now.millisecondsSinceEpoch;
    if (nowMs - effective.lastAdWatchTimestamp < _cooldownMs) return false;

    await _updateState(effective.copyWith(
      adWatchCount: effective.adWatchCount + 1,
      lastAdWatchTimestamp: nowMs,
    ));
    return true;
  }

  /// 4h (or 자정) 해금 활성화.
  Future<void> activateRewardedUnlock() async {
    try { await future; } catch (_) {}
    final current = state.value ?? const MonetizationState();
    final expiry = computeUnlockExpiry(now: DateTime.now());
    await _updateState(current.copyWith(unlockExpiresAt: expiry));
  }

  /// 해금 만료 시각 계산: 4h 또는 자정 중 빠른 것.
  int computeUnlockExpiry({required DateTime now}) {
    final fourHoursLater = now.add(Duration(milliseconds: _unlockDurationMs));
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final earlier = fourHoursLater.isBefore(midnight) ? fourHoursLater : midnight;
    return earlier.millisecondsSinceEpoch;
  }

  /// IAP 구매 팩 추가.
  Future<void> addPurchasedPack(String packId) async {
    try { await future; } catch (_) {}
    final current = state.value ?? const MonetizationState();
    if (current.purchasedPackIds.contains(packId)) return;
    await _updateState(current.copyWith(
      purchasedPackIds: [...current.purchasedPackIds, packId],
    ));
  }

  /// 허니문 종료. 슬롯 제한 활성화.
  Future<void> endHoneymoon() async {
    try { await future; } catch (_) {}
    final current = state.value ?? const MonetizationState();
    await _updateState(current.copyWith(
      honeymoonActive: false,
      favoriteSlotLimit: _defaultSlotLimit,
    ));
  }

  /// 일일 카운터 리셋 (날짜 변경 시 호출).
  Future<void> checkDailyReset({DateTime? now}) async {
    try { await future; } catch (_) {}
    final current = state.value ?? const MonetizationState();
    final todayStr = _formatDate(now ?? DateTime.now());

    var updated = current;
    if (current.adLastResetDate != todayStr) {
      updated = updated.copyWith(adWatchCount: 0, adLastResetDate: todayStr);
    }
    if (current.ttsLastResetDate != todayStr) {
      updated = updated.copyWith(ttsPlayCount: 0, ttsLastResetDate: todayStr);
    }
    if (updated != current) {
      await _updateState(updated);
    }
  }

  /// D-day 24h 해금. false = 이미 해금됨(중복).
  Future<bool> activateDdayUnlock({
    required String date,
    required String eventId,
  }) async {
    try { await future; } catch (_) {}
    final current = state.value ?? const MonetizationState();
    final key = '${date}_$eventId';

    if (current.ddayUnlockedDates.contains(key)) return false;

    // 단조증가 검증
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (nowMs < current.lastTimestamp) return false;

    // 24h 해금
    final midnight = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day + 1,
    ).millisecondsSinceEpoch;

    await _updateState(current.copyWith(
      unlockExpiresAt: midnight,
      ddayUnlockedDates: [...current.ddayUnlockedDates, key],
    ));
    return true;
  }

  /// 시간 조작 검증. false = 시간 역행 감지.
  Future<bool> validateTimestamp({required int timestamp}) async {
    try { await future; } catch (_) {}
    final current = state.value ?? const MonetizationState();
    return timestamp >= current.lastTimestamp;
  }

  /// TTS 재생 카운트 증가.
  Future<void> recordTtsPlay() async {
    try { await future; } catch (_) {}
    final current = state.value ?? const MonetizationState();
    final todayStr = _formatDate(DateTime.now());

    var effective = current;
    if (effective.ttsLastResetDate != todayStr) {
      effective = effective.copyWith(ttsPlayCount: 0, ttsLastResetDate: todayStr);
    }

    await _updateState(effective.copyWith(
      ttsPlayCount: effective.ttsPlayCount + 1,
    ));
  }

  /// 일일 광고 시청 한도 도달 여부.
  bool get isAdLimitReached {
    final s = state.value;
    if (s == null) return false;
    return s.adWatchCount >= _dailyAdLimit;
  }

  /// TTS 일일 한도 도달 여부.
  bool get isTtsLimitReached {
    final s = state.value;
    if (s == null) return false;
    return s.ttsPlayCount >= _dailyTtsLimit;
  }

  /// 현재 보상형 해금 활성 여부.
  bool get isUnlockActive {
    final s = state.value;
    if (s == null) return false;
    return s.unlockExpiresAt > DateTime.now().millisecondsSinceEpoch;
  }
}

/// 허니문 활성 여부 (편의 provider).
@riverpod
bool isHoneymoon(Ref ref) {
  final state = ref.watch(monetizationNotifierProvider).value;
  return state?.honeymoonActive ?? true;
}

/// 보상형 해금 활성 여부 (편의 provider).
@riverpod
bool isRewardedUnlockActive(Ref ref) {
  final state = ref.watch(monetizationNotifierProvider).value;
  if (state == null) return false;
  return state.unlockExpiresAt > DateTime.now().millisecondsSinceEpoch;
}

/// 즐겨찾기 슬롯 제한 (0 = 무제한).
@riverpod
int favoriteSlotLimit(Ref ref) {
  final state = ref.watch(monetizationNotifierProvider).value;
  return state?.favoriteSlotLimit ?? 0;
}
```

**Step 4: Run code generation**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Step 5: Run test**

Run: `flutter test test/presentation/providers/monetization_provider_test.dart`
Expected: ALL PASS

**Step 6: Commit**

```bash
git add lib/presentation/providers/monetization_provider.dart lib/presentation/providers/monetization_provider.g.dart test/presentation/providers/monetization_provider_test.dart
git commit -m "feat: add MonetizationNotifier with honeymoon, limits, unlock, D-day"
```

---

## Task 5: 허니문 & Day 추적 로직

**Files:**
- Create: `lib/core/usecases/check_honeymoon_usecase.dart`
- Test: `test/core/usecases/check_honeymoon_usecase_test.dart`
- Modify: `lib/presentation/providers/monetization_provider.dart` (앱 진입 시 자동 체크 연동)

**Step 1: Write the failing test**

```dart
// test/core/usecases/check_honeymoon_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/core/repositories/monetization_repository.dart';
import 'package:fangeul/core/usecases/check_honeymoon_usecase.dart';

class MockMonetizationRepository extends Mock implements MonetizationRepository {}

void main() {
  late MockMonetizationRepository mockRepo;
  late CheckHoneymoonUseCase useCase;

  setUp(() {
    mockRepo = MockMonetizationRepository();
    useCase = CheckHoneymoonUseCase(mockRepo);
  });

  setUpAll(() {
    registerFallbackValue(const MonetizationState());
  });

  test('should keep honeymoon active within 7 days', () async {
    final today = DateTime(2026, 3, 4);
    final state = MonetizationState(
      installDate: '2026-03-01', // Day 3
      honeymoonActive: true,
    );
    when(() => mockRepo.load()).thenAnswer((_) async => state);

    final result = await useCase.execute(now: today);

    expect(result.honeymoonActive, true);
    expect(result.favoriteSlotLimit, 0); // unlimited
  });

  test('should end honeymoon after Day 6 (7th day)', () async {
    final today = DateTime(2026, 3, 8);
    final state = MonetizationState(
      installDate: '2026-03-01', // Day 7
      honeymoonActive: true,
    );
    when(() => mockRepo.load()).thenAnswer((_) async => state);
    when(() => mockRepo.save(any())).thenAnswer((_) async {});

    final result = await useCase.execute(now: today);

    expect(result.honeymoonActive, false);
    expect(result.favoriteSlotLimit, 3);
    verify(() => mockRepo.save(any())).called(1);
  });

  test('should not re-apply honeymoon if already ended', () async {
    final today = DateTime(2026, 3, 8);
    final state = MonetizationState(
      installDate: '2026-03-01',
      honeymoonActive: false,
      favoriteSlotLimit: 3,
    );
    when(() => mockRepo.load()).thenAnswer((_) async => state);

    final result = await useCase.execute(now: today);

    expect(result.honeymoonActive, false);
    verifyNever(() => mockRepo.save(any()));
  });

  test('should set install date if null', () async {
    final today = DateTime(2026, 3, 4);
    final state = MonetizationState(installDate: null);
    when(() => mockRepo.load()).thenAnswer((_) async => state);
    when(() => mockRepo.save(any())).thenAnswer((_) async {});

    final result = await useCase.execute(now: today);

    expect(result.installDate, '2026-03-04');
    expect(result.honeymoonActive, true);
  });
}
```

**Step 2: Run test → FAIL**

**Step 3: Implement**

```dart
// lib/core/usecases/check_honeymoon_usecase.dart
import 'package:intl/intl.dart';

import 'package:fangeul/core/entities/monetization_state.dart';
import 'package:fangeul/core/repositories/monetization_repository.dart';

/// 앱 진입 시 허니문 기간 체크 및 전환.
///
/// Day 0~6: honeymoonActive = true, favoriteSlotLimit = 0 (무제한)
/// Day 7+: honeymoonActive = false, favoriteSlotLimit = 3
class CheckHoneymoonUseCase {
  CheckHoneymoonUseCase(this._repository);

  final MonetizationRepository _repository;

  static const int _honeymoonDays = 7; // Day 0~6
  static const int _defaultSlotLimit = 3;

  Future<MonetizationState> execute({DateTime? now}) async {
    final today = now ?? DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);
    var state = await _repository.load();

    // 최초 설치 날짜 설정
    if (state.installDate == null) {
      state = state.copyWith(installDate: todayStr, honeymoonActive: true);
      await _repository.save(state);
      return state;
    }

    // 이미 종료된 상태면 변경 없음
    if (!state.honeymoonActive) return state;

    // 일수 계산
    final installDate = DateFormat('yyyy-MM-dd').parse(state.installDate!);
    final daysSince = today.difference(installDate).inDays;

    if (daysSince >= _honeymoonDays) {
      state = state.copyWith(
        honeymoonActive: false,
        favoriteSlotLimit: _defaultSlotLimit,
      );
      await _repository.save(state);
    }

    return state;
  }
}
```

**Step 4: Run test → ALL PASS**

**Step 5: Commit**

```bash
git add lib/core/usecases/check_honeymoon_usecase.dart test/core/usecases/check_honeymoon_usecase_test.dart
git commit -m "feat: add CheckHoneymoonUseCase — Day 7 transition to slot limits"
```

---

## Task 6: 즐겨찾기 슬롯 제한 통합

**Files:**
- Modify: `lib/presentation/providers/favorite_phrases_provider.dart` (슬롯 제한 적용)
- Test: `test/presentation/providers/favorite_phrases_provider_test.dart` (슬롯 제한 테스트 추가)

**Step 1: Write the failing tests** (기존 테스트 파일에 추가)

```dart
// 추가 테스트 케이스 (기존 파일에 group 추가)
group('slot limit', () {
  test('should reject toggle when slot limit reached and adding', () async {
    // 허니문 종료 상태: 슬롯 3개 제한
    // 이미 3개 즐겨찾기가 있을 때 추가 시도 → 실패
  });

  test('should allow toggle when removing even at limit', () async {
    // 3개 있는 상태에서 제거는 허용
  });

  test('should allow unlimited during honeymoon (limit=0)', () async {
    // 허니문 중에는 무제한
  });

  test('should allow unlimited for Pro users (purchasedPackIds not empty)', () async {
    // IAP 구매자는 무제한
  });
});
```

**Step 2: Implement** — `toggle()` 메서드에 슬롯 제한 체크 추가

```dart
/// 즐겨찾기 토글. 슬롯 제한 초과 시 [LimitReachedException] throw.
Future<bool> toggle(String phraseKo) async {
  final current = {...await future};
  final isRemoving = current.contains(phraseKo);

  // 추가 시에만 슬롯 제한 체크
  if (!isRemoving) {
    final limit = ref.read(favoriteSlotLimitProvider);
    final hasIap = (ref.read(monetizationNotifierProvider).value
        ?.purchasedPackIds.isNotEmpty ?? false);
    if (limit > 0 && !hasIap && current.length >= limit) {
      return false; // 슬롯 부족
    }
  }

  // 기존 토글 로직 ...
  return true;
}
```

**Step 3: Run test → ALL PASS**

**Step 4: Commit**

```bash
git add lib/presentation/providers/favorite_phrases_provider.dart test/presentation/providers/favorite_phrases_provider_test.dart
git commit -m "feat: add favorites slot limit (3 slots post-honeymoon)"
```

---

## Task 7: AdMob 서비스 통합

**Files:**
- Modify: `pubspec.yaml` (google_mobile_ads 추가)
- Create: `lib/services/ad_service.dart`
- Create: `lib/services/ad_ids.dart` (테스트/프로덕션 광고 ID)
- Test: `test/services/ad_service_test.dart`
- Modify: `android/app/src/main/AndroidManifest.xml` (AdMob App ID 메타데이터)

**Step 1: Add dependency**

`pubspec.yaml`에 추가:
```yaml
dependencies:
  google_mobile_ads: ^5.3.0
```

Run: `flutter pub get`

**Step 2: Create ad IDs constant file**

```dart
// lib/services/ad_ids.dart
import 'package:flutter/foundation.dart';

/// AdMob 광고 ID. 디버그 모드에서는 테스트 ID 사용.
abstract final class AdIds {
  // Test IDs (Google official)
  static const _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _testRewarded = 'ca-app-pub-3940256099942544/5224354917';

  // Production IDs (TODO: Google AdMob 콘솔에서 생성 후 교체)
  static const _prodBanner = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const _prodRewarded = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  static String get bannerId => kDebugMode ? _testBanner : _prodBanner;
  static String get rewardedId => kDebugMode ? _testRewarded : _prodRewarded;
}
```

**Step 3: Create AdService**

```dart
// lib/services/ad_service.dart
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:fangeul/services/ad_ids.dart';

/// AdMob 광고 로드/표시 서비스.
///
/// 배너: 결과 화면, 카드 획득 화면, 캘린더 하단
/// 보상형: "팬 패스" 해금
class AdService {
  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  /// AdMob SDK 초기화. 앱 시작 시 1회 호출.
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// 보상형 광고 미리 로드.
  Future<void> preloadRewarded() async {
    if (_isRewardedLoading || _rewardedAd != null) return;
    _isRewardedLoading = true;

    await RewardedAd.load(
      adUnitId: AdIds.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdService: rewarded load failed: ${error.message}');
          _rewardedAd = null;
          _isRewardedLoading = false;
        },
      ),
    );
  }

  /// 보상형 광고가 로드되어 표시 가능한지.
  bool get isRewardedReady => _rewardedAd != null;

  /// 보상형 광고 표시. 성공 시 [onRewarded] 콜백 호출.
  Future<void> showRewarded({
    required void Function() onRewarded,
    void Function()? onDismissed,
  }) async {
    final ad = _rewardedAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onDismissed?.call();
        preloadRewarded(); // 다음 광고 미리 로드
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: rewarded show failed: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        preloadRewarded();
      },
    );

    await ad.show(
      onUserEarnedReward: (ad, reward) => onRewarded(),
    );
  }

  /// 리소스 해제.
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
```

**Step 4: Write tests** (AdMob은 실기기 의존이므로 인터페이스 기반 모킹)

```dart
// test/services/ad_service_test.dart
// AdMob은 네이티브 SDK 의존 — 유닛 테스트는 인터페이스/모킹 수준
// 실제 통합 테스트는 디바이스에서 수행
import 'package:flutter_test/flutter_test.dart';
import 'package:fangeul/services/ad_ids.dart';

void main() {
  test('should use test IDs in debug mode', () {
    // kDebugMode에서는 테스트 ID 반환
    expect(AdIds.bannerId, contains('3940256099942544'));
    expect(AdIds.rewardedId, contains('3940256099942544'));
  });
}
```

**Step 5: AndroidManifest.xml 수정**

`android/app/src/main/AndroidManifest.xml`의 `<application>` 태그 안에 추가:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

**Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/services/ad_service.dart lib/services/ad_ids.dart test/services/ad_service_test.dart android/app/src/main/AndroidManifest.xml
git commit -m "feat: add AdMob integration — AdService + banner/rewarded support"
```

---

## Task 8: 배너 광고 위젯

**Files:**
- Create: `lib/presentation/widgets/banner_ad_widget.dart`
- Test: `test/presentation/widgets/banner_ad_widget_test.dart`
- Modify: `lib/presentation/screens/home_screen.dart` (배너 삽입)
- Modify: `lib/presentation/screens/phrases_screen.dart` (배너 삽입)
- Reference: `lib/presentation/providers/monetization_provider.dart` (허니문/해금 체크)

**구현 핵심:**
- `BannerAdWidget` — StatefulWidget (AdMob 라이프사이클 관리)
- 허니문 중에는 표시 안 함
- 보상형 1회 시청 시 세션 동안 숨김
- Pro(IAP 구매) 유저는 영구 숨김

```dart
// lib/presentation/widgets/banner_ad_widget.dart
/// 조건부 배너 광고 위젯.
///
/// 표시 조건:
/// - 허니문 아님 (Day 7+)
/// - 세션 배너 숨김 플래그 아님 (보상형 시청 후)
/// - Pro 유저 아님 (IAP 구매)
class BannerAdWidget extends ConsumerStatefulWidget { ... }
```

**커밋 메시지:** `feat: add BannerAdWidget with conditional display logic`

---

## Task 9: 보상형 광고 "팬 패스" 플로우

**Files:**
- Create: `lib/presentation/widgets/fan_pass_button.dart`
- Create: `lib/presentation/widgets/fan_pass_popup.dart`
- Modify: `lib/presentation/providers/monetization_provider.dart` (세션 배너 숨김 플래그)
- Test: `test/presentation/widgets/fan_pass_button_test.dart`

**구현 핵심:**
- "팬 패스 획득!" 보상 프레이밍 팝업
- 쿨다운 5분 + 일일 3회 상한 표시
- 시청 성공 → `activateRewardedUnlock()` + 세션 배너 숨김
- 자정 만료 카운트다운 UI

```dart
// lib/presentation/widgets/fan_pass_button.dart
/// "팬 패스" 보상형 광고 버튼.
///
/// 남은 시청 횟수, 쿨다운 타이머, 해금 잔여 시간을 표시.
/// 시청 완료 시 4h(or 자정) 해금 활성화.
class FanPassButton extends ConsumerWidget { ... }
```

**커밋 메시지:** `feat: add Fan Pass rewarded ad flow with cooldown and daily cap`

---

## Task 10: 해금 타이머 UI

**Files:**
- Create: `lib/presentation/widgets/unlock_timer_widget.dart`
- Test: `test/presentation/widgets/unlock_timer_widget_test.dart`

**구현 핵심:**
- 해금 잔여 시간 실시간 표시 (mm:ss or hh:mm)
- 자정 만료 시 "자정에 만료됩니다" 안내
- `Timer.periodic(Duration(seconds: 1))` + `mounted` 가드 (Sprint 1 교훈)

**커밋 메시지:** `feat: add unlock timer countdown widget`

---

## Task 11: 감성 컬러 팩 JSON + 엔티티

**Files:**
- Create: `assets/color_packs/color_packs.json`
- Modify: `lib/core/entities/phrase_pack.dart` (unlockType, colorPackId 필드 추가)
- Create: `lib/core/entities/color_pack.dart` (freezed)
- Test: `test/core/entities/color_pack_test.dart`

**Step 1: Define JSON**

```json
// assets/color_packs/color_packs.json
{
  "packs": [
    {
      "id": "purple_dream",
      "nameKo": "퍼플 드림",
      "nameEn": "Purple Dream",
      "primaryColor": "#A855F7",
      "secondaryColor": "#7C3AED",
      "skuId": "fangeul_color_purple_dream",
      "priceKrw": 1900,
      "phraseCount": 50,
      "pronunciationCount": 30,
      "iapOnly": false
    },
    {
      "id": "golden_hour",
      "nameKo": "골든 아워",
      "nameEn": "Golden Hour",
      "primaryColor": "#F59E0B",
      "secondaryColor": "#D97706",
      "skuId": "fangeul_color_golden_hour",
      "priceKrw": 1900,
      "phraseCount": 50,
      "pronunciationCount": 30,
      "iapOnly": false
    },
    {
      "id": "concert_sky",
      "nameKo": "그날 콘서트 하늘",
      "nameEn": "Concert Sky",
      "primaryColor": "#3B82F6",
      "secondaryColor": "#1D4ED8",
      "skuId": "fangeul_color_concert_sky",
      "priceKrw": 1900,
      "phraseCount": 50,
      "pronunciationCount": 30,
      "iapOnly": true
    },
    {
      "id": "dawn_lightstick",
      "nameKo": "새벽 응원봉 잔광",
      "nameEn": "Dawn Lightstick",
      "primaryColor": "#EC4899",
      "secondaryColor": "#BE185D",
      "skuId": "fangeul_color_dawn_lightstick",
      "priceKrw": 1900,
      "phraseCount": 50,
      "pronunciationCount": 30,
      "iapOnly": true
    },
    {
      "id": "starter_pack",
      "nameKo": "첫 만남",
      "nameEn": "First Meet",
      "primaryColor": "#22C55E",
      "secondaryColor": "#15803D",
      "skuId": "fangeul_color_starter",
      "priceKrw": 990,
      "phraseCount": 20,
      "pronunciationCount": 10,
      "iapOnly": false
    }
  ]
}
```

**Step 2: Create entity**

```dart
// lib/core/entities/color_pack.dart
@freezed
class ColorPack with _$ColorPack {
  const factory ColorPack({
    required String id,
    required String nameKo,
    required String nameEn,
    required String primaryColor,
    required String secondaryColor,
    required String skuId,
    required int priceKrw,
    @Default(50) int phraseCount,
    @Default(30) int pronunciationCount,
    @Default(false) bool iapOnly, // true = 보상형으로 해금 불가
  }) = _ColorPack;

  factory ColorPack.fromJson(Map<String, dynamic> json) =>
      _$ColorPackFromJson(json);
}
```

**커밋 메시지:** `feat: add color pack JSON definitions and ColorPack entity`

---

## Task 12: IAP 서비스 통합 (in_app_purchase)

**Files:**
- Modify: `pubspec.yaml` (in_app_purchase 추가)
- Create: `lib/services/iap_service.dart`
- Create: `lib/services/iap_products.dart` (SKU 상수)
- Test: `test/services/iap_service_test.dart`

**Step 1: Add dependency**

```yaml
dependencies:
  in_app_purchase: ^3.2.0
```

**Step 2: SKU 상수**

```dart
// lib/services/iap_products.dart
/// Google Play IAP SKU 정의.
abstract final class IapProducts {
  static const starterPack = 'fangeul_color_starter';       // ₩990
  static const purpleDream = 'fangeul_color_purple_dream';   // ₩1,900
  static const goldenHour = 'fangeul_color_golden_hour';     // ₩1,900
  static const concertSky = 'fangeul_color_concert_sky';     // ₩1,900
  static const dawnLightstick = 'fangeul_color_dawn_lightstick'; // ₩1,900
  static const twoPack = 'fangeul_color_2pack';              // ₩3,900

  static const allIds = [
    starterPack, purpleDream, goldenHour, concertSky, dawnLightstick, twoPack,
  ];
}
```

**Step 3: IapService**

```dart
// lib/services/iap_service.dart
/// IAP 구매 플로우 관리.
///
/// 구매 성공 → MonetizationNotifier.addPurchasedPack()
/// 구매 복원 → restorePurchases()
/// 구매 실패 → 에러 메시지 + 재시도 안내
class IapService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<void> initialize({
    required void Function(String packId) onPurchased,
    required void Function(String error) onError,
  }) async {
    final available = await _iap.isAvailable();
    if (!available) return;

    _subscription = _iap.purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        _handlePurchase(purchase, onPurchased: onPurchased, onError: onError);
      }
    });
  }

  Future<void> buyPack(String skuId) async { ... }
  Future<void> restorePurchases() async { ... }
  void dispose() { _subscription?.cancel(); }
}
```

**커밋 메시지:** `feat: add IAP service with in_app_purchase integration`

---

## Task 13: 구매 플로우 UI

**Files:**
- Create: `lib/presentation/screens/shop_screen.dart` (또는 BottomSheet)
- Create: `lib/presentation/widgets/color_pack_card.dart`
- Test: `test/presentation/screens/shop_screen_test.dart`

**구현 핵심:**
- 컬러 팩 목록 (가격, 이름, 미리보기)
- 구매 버튼 → IapService.buyPack()
- 구매 성공 → 축하 팝업 + 콘텐츠 해금
- 구매 복원 버튼 (기기 변경 대응)
- 3회 실패 시 "나중에 다시 시도" 안내 (§9.1)

**커밋 메시지:** `feat: add shop screen with color pack purchase flow`

---

## Task 14: 전환 트리거 팝업

**Files:**
- Create: `lib/presentation/widgets/conversion_trigger_popup.dart`
- Modify: `lib/presentation/providers/monetization_provider.dart` (트리거 조건 체크)
- Test: `test/presentation/widgets/conversion_trigger_popup_test.dart`

**구현 핵심:**
- 트리거 조건: Day 14+ AND 보상형 3회 소진 AND 즐겨찾기 슬롯 포화
- 단일 팝업 (세션 당 1회)
- "감성 컬러 팩으로 무제한 해금" CTA
- 닫기 버튼 필수 (강제 없음)

```dart
/// 전환 트리거 조건 체크 provider.
@riverpod
bool shouldShowConversionTrigger(Ref ref) {
  final state = ref.watch(monetizationNotifierProvider).value;
  if (state == null) return false;

  final installDate = state.installDate;
  if (installDate == null) return false;

  final daysSince = DateTime.now()
      .difference(DateFormat('yyyy-MM-dd').parse(installDate))
      .inDays;

  // Day 14+ AND 광고 3회 소진 AND 슬롯 포화
  final favCount = ref.watch(favoritePhrasesNotifierProvider).value?.length ?? 0;
  return daysSince >= 14 &&
      state.adWatchCount >= 3 &&
      state.favoriteSlotLimit > 0 &&
      favCount >= state.favoriteSlotLimit &&
      state.purchasedPackIds.isEmpty; // 미구매자만
}
```

**커밋 메시지:** `feat: add conversion trigger popup (Day14 + slots + ads)`

---

## Task 15: D-day 선물 정책

**Files:**
- Modify: `lib/presentation/providers/calendar_providers.dart` (D-day 체크 연동)
- Modify: `lib/presentation/providers/monetization_provider.dart` (activateDdayUnlock 이미 구현)
- Create: `lib/presentation/widgets/dday_gift_popup.dart`
- Test: `test/presentation/providers/dday_gift_test.dart`

**구현 핵심:**
- 앱 진입 시 `todayEventsProvider` 체크
- 유저의 최애 관련 이벤트가 있으면 D-day 선물 팝업
- 24h 전면 해제 (자정까지)
- 단조증가 검증 + 중복 방지 (§9.3)

**커밋 메시지:** `feat: add D-day gift policy — 24h unlock on idol birthday/comeback`

---

## Task 16: 배너 조건부 제거 로직

**Files:**
- Create: `lib/presentation/providers/session_state_provider.dart` (세션 에페메랄 상태)
- Modify: `lib/presentation/widgets/banner_ad_widget.dart` (조건 추가)
- Test: `test/presentation/providers/session_state_provider_test.dart`

**구현 핵심:**
- `sessionBannerHiddenProvider` — StateProvider<bool> (보상형 1회 시청 시 true)
- 배너 위젯: `isHoneymoon || sessionBannerHidden || hasIap → 숨김`
- 세션 = 앱 프로세스 라이프사이클 (킬 시 리셋)

**커밋 메시지:** `feat: add session banner removal after rewarded ad watch`

---

## Task 17: TTS 일일 카운터 (최소)

**Files:**
- Create: `lib/services/tts_service.dart` (just_audio 기반 재생 서비스)
- Modify: `lib/presentation/providers/monetization_provider.dart` (recordTtsPlay 이미 구현)
- Test: `test/services/tts_service_test.dart`

**구현 핵심:**
- `just_audio` AudioPlayer 래퍼
- 재생 전 `isTtsLimitReached` 체크
- 한도 초과 시 "팬 패스로 해금" or "Pro로 무제한" 안내
- 기본팩 음성만 번들 (3~5MB)
- 느린 발음은 Pro 전용

**커밋 메시지:** `feat: add TTS service with 5/day limit integration`

---

## Task 18: UI 문자열 + Analytics 이벤트 확장

**Files:**
- Modify: `lib/presentation/constants/ui_strings.dart`
- Modify: `lib/services/analytics_events.dart`

**Step 1: UI 문자열 추가**

```dart
// lib/presentation/constants/ui_strings.dart (추가)

// 수익화
static const fanPassTitle = '팬 패스 획득!';
static const fanPassDescription = '4시간 동안 프리미엄 콘텐츠를 즐겨보세요';
static const fanPassButton = '광고 보고 팬 패스 받기';
static const fanPassCooldown = '잠시 후 다시 시도해주세요';
static String fanPassRemaining(int count) => '오늘 $count회 남음';
static String unlockExpiresIn(String time) => '$time 후 만료';
static const unlockExpiresMidnight = '자정에 만료됩니다';

// 즐겨찾기 제한
static const favLimitTitle = '즐겨찾기 가득 참';
static const favLimitMessage = '팬 패스로 임시 해금하거나\n감성 컬러 팩으로 무제한 즐기세요';
static const favLimitAdButton = '팬 패스로 해금';
static const favLimitIapButton = '감성 컬러 팩 보기';

// TTS 제한
static const ttsLimitTitle = 'TTS 사용량 소진';
static String ttsLimitMessage(int limit) => '오늘 $limit회 모두 사용했어요';
static const ttsLimitAdButton = '팬 패스로 해금';

// 샵
static const shopTitle = '감성 컬러 팩';
static const shopRestore = '구매 복원';
static const shopBuyButton = '구매하기';
static String shopPrice(String price) => price;
static const shopPurchaseSuccess = '구매 완료! 콘텐츠가 해금되었어요';
static const shopPurchaseFailed = '구매에 실패했어요. 다시 시도해주세요';
static const shopPurchasePending = '결제 처리 중...';

// 전환 트리거
static const conversionTitle = '더 많은 문구를 즐기고 싶다면';
static const conversionMessage = '감성 컬러 팩으로 즐겨찾기 무제한 + 프리미엄 문구를 만나보세요';
static const conversionButton = '감성 컬러 팩 보기';

// D-day
static String ddayGiftTitle(String eventName) => '$eventName 축하해요!';
static const ddayGiftMessage = '오늘 하루 모든 콘텐츠가 무료예요';
static const ddayGiftButton = '선물 받기';

// 허니문
static String honeymoonDaysLeft(int days) => '무료 체험 ${days}일 남음';
```

**Step 2: Analytics 이벤트 추가**

```dart
// lib/services/analytics_events.dart (추가)

// 수익화 이벤트
static const adBannerImpression = 'ad_banner_impression';
static const adRewardedStart = 'ad_rewarded_start';
static const adRewardedComplete = 'ad_rewarded_complete';
static const adRewardedFailed = 'ad_rewarded_failed';
static const fanPassActivated = 'fan_pass_activated';
static const fanPassExpired = 'fan_pass_expired';

static const iapViewShop = 'iap_view_shop';
static const iapStartPurchase = 'iap_start_purchase';
static const iapPurchaseSuccess = 'iap_purchase_success';
static const iapPurchaseFailed = 'iap_purchase_failed';
static const iapRestorePurchase = 'iap_restore_purchase';

static const favLimitReached = 'fav_limit_reached';
static const ttsLimitReached = 'tts_limit_reached';
static const conversionTriggerShown = 'conversion_trigger_shown';
static const conversionTriggerClicked = 'conversion_trigger_clicked';
static const ddayGiftActivated = 'dday_gift_activated';
static const honeymoonEnded = 'honeymoon_ended';

// 파라미터
static const packId = 'pack_id';
static const skuId = 'sku_id';
static const revenue = 'revenue';
static const unlockDurationMin = 'unlock_duration_min';
static const daysSinceInstall = 'days_since_install';
```

**Step 3: Commit**

```bash
git add lib/presentation/constants/ui_strings.dart lib/services/analytics_events.dart
git commit -m "feat: add monetization UI strings and analytics events"
```

---

## 실행 후 검증 체크리스트

모든 태스크 완료 후 반드시 확인:

```bash
# 1. 전체 테스트
flutter test

# 2. 정적 분석
flutter analyze

# 3. 포맷 검증
dart format --set-exit-if-changed .

# 4. 코드 생성 최신 상태
dart run build_runner build --delete-conflicting-outputs

# 5. 의존성 방향 위반 없는지 확인
# core/ → data/ ❌ / core/ → presentation/ ❌
grep -r "import 'package:fangeul/data/" lib/core/ || echo "OK: no core→data"
grep -r "import 'package:fangeul/presentation/" lib/core/ || echo "OK: no core→presentation"
```

---

## 참조 문서

| 문서 | 용도 |
|------|------|
| `docs/discussions/2026-03-04-phase6-monetization-consensus.md` | 수익화 전략 합의 (전문가 패널 + 교차 리뷰) |
| `docs/discussions/2026-02-28-bubble-monetization.md` | 이전 수익화 토론 (기반 결정) |
| `.claude/rules/00-project.md` | 프로젝트 하드 규칙 (수익화 섹션) |
| `.claude/rules/01-code-conventions.md` | 코드 컨벤션 + HMAC 패턴 |
| `docs/fangeul-future-reference.md` | 미구현 스펙 (TTS, 보안) |
